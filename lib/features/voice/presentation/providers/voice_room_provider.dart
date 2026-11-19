import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_noise_filter/livekit_noise_filter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/thread_audio_player_provider.dart';
import '../../data/voice_repository.dart';
import '../voice_room_sfx.dart';

enum VoiceRoomPhase { idle, connecting, connected, reconnecting, error }

class VoiceRoomParticipant {
  const VoiceRoomParticipant({
    required this.identity,
    required this.name,
    required this.isLocal,
    required this.muted,
    required this.speaking,
  });

  final String identity;
  final String name;
  final bool isLocal;
  final bool muted;
  final bool speaking;
}

class VoiceRoomState {
  const VoiceRoomState({
    this.phase = VoiceRoomPhase.idle,
    this.muted = false,
    this.participantCount = 0,
    this.participants = const [],
    this.errorMessage,
  });

  final VoiceRoomPhase phase;
  final bool muted;
  final int participantCount;
  final List<VoiceRoomParticipant> participants;
  final String? errorMessage;

  bool get isConnected => phase == VoiceRoomPhase.connected;

  /// Masih di sesi voice (termasuk reconnect setelah homelab goyang).
  bool get isInSession =>
      phase == VoiceRoomPhase.connected ||
      phase == VoiceRoomPhase.reconnecting;

  /// Ada peserta remote yang deteksi bicara (suara masuk).
  bool get hasIncomingVoice =>
      participants.any((p) => !p.isLocal && p.speaking);

  /// Mic lokal aktif mengirim (tidak mute + VAD bicara).
  bool get isMicSending =>
      !muted && participants.any((p) => p.isLocal && p.speaking);

  /// Nama remote yang sedang bicara (pertama), untuk label strip.
  String? get incomingSpeakerName {
    for (final p in participants) {
      if (!p.isLocal && p.speaking) return p.name;
    }
    return null;
  }

  VoiceRoomState copyWith({
    VoiceRoomPhase? phase,
    bool? muted,
    int? participantCount,
    List<VoiceRoomParticipant>? participants,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VoiceRoomState(
      phase: phase ?? this.phase,
      muted: muted ?? this.muted,
      participantCount: participantCount ?? this.participantCount,
      participants: participants ?? this.participants,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final voiceRepositoryProvider = Provider<VoiceRepository>(
  (ref) => VoiceRepository(ref.watch(dioProvider)),
);

/// KeepAlive: jangan autoDispose saat rebuild strip / sheet error.
final voiceRoomProvider =
    NotifierProvider<VoiceRoomController, VoiceRoomState>(
      VoiceRoomController.new,
    );

class VoiceRoomController extends Notifier<VoiceRoomState> {
  static const _connectTimeout = Duration(seconds: 20);
  /// Refresh JWT sebelum exp supaya reconnect homelab tidak pakai token basi.
  static const _refreshBeforeExpiry = Duration(minutes: 5);
  static const _refreshFallbackInterval = Duration(minutes: 20);
  static const _refreshRetryOnFail = Duration(minutes: 2);
  static const _refreshMinDelay = Duration(minutes: 1);

  Room? _room;
  EventsListener<RoomEvent>? _listener;
  Timer? _tokenRefreshTimer;
  var _tokenRefreshInFlight = false;
  // Dipegang agar processor tidak di-GC selama room hidup.
  // ignore: unused_field
  LiveKitNoiseFilter? _noiseFilter;
  var _lkReady = false;
  var _intentionalLeave = false;
  /// User ingin tetap di room (bukan leave manual) - recover saat resume.
  var _sessionDesired = false;
  String? _msgDisconnected;
  String? _msgConnectTimeout;
  String _roomName = 'sambasku-global';
  /// Identity remote yang sudah diketahui - deteksi join orang lain.
  Set<String> _knownRemoteIds = {};
  AppLocalizations? _l10n;
  _VoiceLifecycleObserver? _lifecycle;
  var _resumeRecoverInFlight = false;

  @override
  VoiceRoomState build() {
    final life = _VoiceLifecycleObserver(onResumed: () {
      unawaited(_onAppResumed());
    });
    _lifecycle = life;
    WidgetsBinding.instance.addObserver(life);
    ref.onDispose(() {
      final obs = _lifecycle;
      _lifecycle = null;
      if (obs != null) {
        WidgetsBinding.instance.removeObserver(obs);
      }
      _intentionalLeave = true;
      _sessionDesired = false;
      _disconnectSilent();
    });
    return const VoiceRoomState();
  }

  /// Minimize → buka lagi: remint kalau masih sesi, join ulang kalau putus.
  Future<void> _onAppResumed() async {
    if (!ref.mounted || _intentionalLeave || !_sessionDesired) return;
    if (_resumeRecoverInFlight) return;
    if (state.phase == VoiceRoomPhase.connecting) return;

    _resumeRecoverInFlight = true;
    try {
      if (state.isInSession) {
        unawaited(_refreshSessionToken(reason: 'app_resume'));
        await _ensureMicPublishing();
        return;
      }
      final l10n = _l10n;
      if (l10n == null) return;
      debugPrint('VoiceRoom resume: rejoining after drop');
      await join(l10n);
    } finally {
      _resumeRecoverInFlight = false;
    }
  }

  Future<void> _ensureMicPublishing() async {
    if (!ref.mounted || state.muted) return;
    final lp = _room?.localParticipant;
    if (lp == null) return;
    try {
      if (!lp.isMicrophoneEnabled()) {
        await lp.setMicrophoneEnabled(true).timeout(
          const Duration(seconds: 5),
        );
      }
    } catch (e, st) {
      debugPrint('VoiceRoom resume mic restore failed: $e\n$st');
      return;
    }
    if (ref.mounted) _syncParticipants();
  }

  Future<void> _ensureLiveKit() async {
    if (_lkReady) return;
    await LiveKitClient.initialize();
    _lkReady = true;
  }

  Future<void> join(AppLocalizations l10n) async {
    if (state.phase == VoiceRoomPhase.connecting || state.isInSession) return;

    _l10n = l10n;
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      _sessionDesired = false;
      state = state.copyWith(
        phase: VoiceRoomPhase.error,
        errorMessage: l10n.voiceMicDenied,
      );
      _trackVoiceEvent(
        VoiceRoomEventKind.joinFailed,
        errorCode: 'MIC_DENIED',
      );
      return;
    }

    try {
      await ref.read(threadAudioPlayerProvider.notifier).stop();
    } catch (_) {}

    _msgDisconnected = l10n.voiceDisconnected;
    _msgConnectTimeout = l10n.voiceConnectTimeout;
    _intentionalLeave = false;
    _sessionDesired = true;

    state = state.copyWith(
      phase: VoiceRoomPhase.connecting,
      clearError: true,
    );

    final minted = await ref.read(voiceRepositoryProvider).mintToken();
    if (!ref.mounted) return;

    VoiceToken? token;
    VoiceFailure? failure;
    minted.match((f) => failure = f, (t) => token = t);
    if (failure != null || token == null) {
      state = state.copyWith(
        phase: VoiceRoomPhase.error,
        errorMessage: failure?.message ?? l10n.voiceJoinFailed,
      );
      _trackVoiceEvent(
        VoiceRoomEventKind.joinFailed,
        errorCode: failure?.errorCode ?? 'MINT_FAILED',
        detail: failure?.message,
      );
      return;
    }

    final url = token!.url.trim();
    final jwt = token!.token.trim();
    final roomName = token!.room.trim();
    if (url.isEmpty || jwt.isEmpty) {
      state = state.copyWith(
        phase: VoiceRoomPhase.error,
        errorMessage: l10n.voiceJoinFailed,
      );
      _trackVoiceEvent(
        VoiceRoomEventKind.joinFailed,
        errorCode: 'EMPTY_TOKEN',
      );
      return;
    }
    if (roomName.isNotEmpty) _roomName = roomName;

    try {
      await _ensureLiveKit();
      if (!ref.mounted) return;

      await _disconnectSilent();
      _intentionalLeave = false;

      final noise = LiveKitNoiseFilter();
      _noiseFilter = noise;

      final room = Room(
        roomOptions: RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioPublishOptions: const AudioPublishOptions(
            name: 'microphone',
          ),
          defaultAudioCaptureOptions: AudioCaptureOptions(
            processor: noise,
          ),
        ),
      );
      _room = room;
      _listener = room.createListener();
      _listener!
        ..on<ParticipantConnectedEvent>((_) => _syncParticipants())
        ..on<ParticipantDisconnectedEvent>((_) => _syncParticipants())
        ..on<TrackSubscribedEvent>((_) => _syncParticipants())
        ..on<TrackUnsubscribedEvent>((_) => _syncParticipants())
        ..on<TrackMutedEvent>((_) => _syncParticipants())
        ..on<TrackUnmutedEvent>((_) => _syncParticipants())
        ..on<ActiveSpeakersChangedEvent>((_) => _syncParticipants())
        ..on<RoomReconnectingEvent>((_) {
          _markReconnecting();
          // Segera remint bila reconnect - JWT lama sering jadi penyebab gagal.
          unawaited(_refreshSessionToken(reason: 'reconnecting'));
        })
        ..on<RoomResumingEvent>((_) => _markReconnecting())
        ..on<RoomReconnectedEvent>((_) {
          if (!ref.mounted || _intentionalLeave) return;
          _syncParticipants(forceConnected: true);
        })
        ..on<RoomDisconnectedEvent>((_) {
          unawaited(_onUnexpectedDisconnect());
        });

      await room.prepareConnection(url, jwt);
      await room
          .connect(
            url,
            jwt,
            connectOptions: const ConnectOptions(autoSubscribe: true),
            fastConnectOptions: FastConnectOptions(
              microphone: const TrackOption(enabled: true),
            ),
          )
          .timeout(
            _connectTimeout,
            onTimeout: () =>
                throw TimeoutException(_msgConnectTimeout ?? 'timeout'),
          );

      if (!ref.mounted) {
        await room.disconnect();
        await room.dispose();
        return;
      }

      _applySessionToken(jwt);
      _syncParticipants(forceConnected: true, seedPresence: true);
      _scheduleTokenRefresh(jwt);
      _trackVoiceEvent(VoiceRoomEventKind.joined);
      unawaited(VoiceRoomSfx.joinSelf());
    } catch (e, st) {
      debugPrint('VoiceRoom join failed: $e\n$st');
      await _disconnectSilent();
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: VoiceRoomPhase.error,
        errorMessage: _friendlyJoinError(l10n, e),
      );
      _trackVoiceEvent(
        VoiceRoomEventKind.joinFailed,
        errorCode: e.runtimeType.toString(),
        detail: e.toString(),
      );
    }
  }

  void _trackVoiceEvent(
    VoiceRoomEventKind kind, {
    String? errorCode,
    String? detail,
  }) {
    if (!ref.mounted) return;
    final platform = defaultTargetPlatform.name;
    final repo = ref.read(voiceRepositoryProvider);
    unawaited(
      repo.reportEvent(
        kind: kind,
        room: _roomName,
        errorCode: errorCode,
        detail: detail,
        platform: platform,
      ),
    );
    final analytics = AnalyticsService.instance;
    switch (kind) {
      case VoiceRoomEventKind.joined:
        unawaited(analytics.logVoiceJoin(room: _roomName));
      case VoiceRoomEventKind.left:
        unawaited(analytics.logVoiceLeave(room: _roomName));
      case VoiceRoomEventKind.disconnect:
        unawaited(analytics.logVoiceDisconnect(room: _roomName));
      case VoiceRoomEventKind.joinFailed:
        unawaited(analytics.logVoiceJoinFail(errorCode: errorCode));
    }
  }

  void _markReconnecting() {
    if (!ref.mounted || _intentionalLeave) return;
    if (!state.isInSession && state.phase != VoiceRoomPhase.connecting) {
      return;
    }
    state = state.copyWith(phase: VoiceRoomPhase.reconnecting);
  }

  Future<void> _onUnexpectedDisconnect() async {
    if (_intentionalLeave) return;
    _trackVoiceEvent(VoiceRoomEventKind.disconnect);
    unawaited(VoiceRoomSfx.leaveSelf());
    await _disconnectSilent();
    if (!ref.mounted) return;
    state = VoiceRoomState(
      phase: VoiceRoomPhase.error,
      errorMessage: _msgDisconnected,
    );
  }

  /// Tulis JWT ke engine supaya attempt reconnect berikutnya pakai token segar.
  void _applySessionToken(String jwt) {
    final room = _room;
    if (room == null) return;
    // SDK belum punya setter publik; `engine.token` dibaca saat reconnect
    // (Engine.handleReconnect). Tanpa ini remint sia-sia.
    // ignore: invalid_use_of_internal_member
    room.engine.token = jwt;
  }

  void _scheduleTokenRefresh(String jwt) {
    _tokenRefreshTimer?.cancel();
    if (_intentionalLeave || !ref.mounted) return;

    final exp = LiveKitJwtPayload.fromToken(jwt)?.expiresAt;
    Duration delay;
    if (exp != null) {
      delay = exp.toUtc().difference(DateTime.timestamp().toUtc()) -
          _refreshBeforeExpiry;
      if (delay < _refreshMinDelay) delay = _refreshMinDelay;
    } else {
      delay = _refreshFallbackInterval;
    }

    _tokenRefreshTimer = Timer(delay, () {
      unawaited(_refreshSessionToken(reason: 'schedule'));
    });
  }

  Future<void> _refreshSessionToken({required String reason}) async {
    if (_tokenRefreshInFlight || _intentionalLeave || !ref.mounted) return;
    if (!state.isInSession) return;
    final room = _room;
    if (room == null) return;

    _tokenRefreshInFlight = true;
    try {
      final minted = await ref.read(voiceRepositoryProvider).mintToken();
      if (!ref.mounted || _intentionalLeave || _room != room) return;

      VoiceToken? token;
      VoiceFailure? failure;
      minted.match((f) => failure = f, (t) => token = t);
      final jwt = token?.token.trim() ?? '';
      if (failure != null || jwt.isEmpty) {
        debugPrint(
          'VoiceRoom token refresh failed ($reason): ${failure?.errorCode ?? failure?.message}',
        );
        // Jangan putus sesi - coba lagi sebentar.
        _tokenRefreshTimer?.cancel();
        _tokenRefreshTimer = Timer(_refreshRetryOnFail, () {
          unawaited(_refreshSessionToken(reason: 'retry'));
        });
        return;
      }

      _applySessionToken(jwt);
      _scheduleTokenRefresh(jwt);
      debugPrint('VoiceRoom token refreshed ($reason)');
    } catch (e, st) {
      debugPrint('VoiceRoom token refresh error ($reason): $e\n$st');
      _tokenRefreshTimer?.cancel();
      _tokenRefreshTimer = Timer(_refreshRetryOnFail, () {
        unawaited(_refreshSessionToken(reason: 'retry'));
      });
    } finally {
      _tokenRefreshInFlight = false;
    }
  }

  String _friendlyJoinError(AppLocalizations l10n, Object e) {
    if (e is TimeoutException) {
      return l10n.voiceConnectTimeout;
    }
    final raw = e.toString();
    final lower = raw.toLowerCase();
    if (raw.contains('VOICE_ROOM_FULL') ||
        lower.contains('room is full') ||
        lower.contains('max participants')) {
      return l10n.voiceRoomFull;
    }
    // Homelab/proxy sering balas HTTP 200 ke upgrade → WebSocketException.
    if (lower.contains('websocket') ||
        lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('failed host lookup')) {
      return l10n.voiceWsFailed;
    }
    final detail = raw.length > 160 ? '${raw.substring(0, 160)}…' : raw;
    return '${l10n.voiceJoinFailed}\n$detail';
  }

  Future<void> leave() async {
    _intentionalLeave = true;
    _sessionDesired = false;
    _trackVoiceEvent(VoiceRoomEventKind.left);
    unawaited(VoiceRoomSfx.leaveSelf());
    await _disconnectSilent();
    if (!ref.mounted) return;
    state = const VoiceRoomState();
  }

  Future<void> toggleMute() async {
    final room = _room;
    final lp = room?.localParticipant;
    if (lp == null || !state.isInSession) return;
    final nextMuted = !state.muted;
    try {
      await lp.setMicrophoneEnabled(!nextMuted).timeout(
        const Duration(seconds: 5),
      );
    } catch (e, st) {
      debugPrint('VoiceRoom toggleMute failed: $e\n$st');
      return;
    }
    if (!ref.mounted) return;
    _syncParticipants();
  }

  void clearError() {
    // Tutup sheet error = user tidak minta auto-rejoin sampai Gabung lagi.
    _sessionDesired = false;
    state = state.copyWith(clearError: true, phase: VoiceRoomPhase.idle);
  }

  void _syncParticipants({
    bool forceConnected = false,
    bool seedPresence = false,
  }) {
    final room = _room;
    if (!ref.mounted || room == null) return;

    final speakers = {
      for (final p in room.activeSpeakers) p.identity,
    };

    VoiceRoomParticipant mapParticipant(
      Participant p, {
      required bool isLocal,
    }) {
      final rawName = p.name.trim();
      return VoiceRoomParticipant(
        identity: p.identity,
        name: rawName.isEmpty ? p.identity : rawName,
        isLocal: isLocal,
        muted: !p.isMicrophoneEnabled(),
        speaking: speakers.contains(p.identity),
      );
    }

    final list = <VoiceRoomParticipant>[];
    final local = room.localParticipant;
    if (local != null) {
      list.add(mapParticipant(local, isLocal: true));
    }
    final remoteIds = <String>{};
    for (final p in room.remoteParticipants.values) {
      remoteIds.add(p.identity);
      list.add(mapParticipant(p, isLocal: false));
    }

    if (!seedPresence &&
        state.isInSession &&
        remoteIds.difference(_knownRemoteIds).isNotEmpty) {
      unawaited(VoiceRoomSfx.joinOther());
    }
    _knownRemoteIds = remoteIds;

    list.sort((a, b) {
      if (a.speaking != b.speaking) return a.speaking ? -1 : 1;
      if (a.isLocal != b.isLocal) return a.isLocal ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    void apply() {
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: forceConnected ? VoiceRoomPhase.connected : null,
        muted: local != null ? !local.isMicrophoneEnabled() : state.muted,
        participants: list,
        participantCount: list.length,
        clearError: forceConnected,
      );
    }

    // LiveKit event bisa datang di tengah rebuild (pop diskusi + mini bar).
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      apply();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => apply());
    }
  }

  Future<void> _disconnectSilent() async {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    _tokenRefreshInFlight = false;
    _knownRemoteIds = {};
    final listener = _listener;
    _listener = null;
    final room = _room;
    _room = null;
    _noiseFilter = null;
    try {
      await listener?.dispose();
    } catch (_) {}
    if (room == null) return;
    try {
      await room.disconnect();
      await room.dispose();
    } catch (e, st) {
      debugPrint('VoiceRoom disconnect: $e\n$st');
    }
  }
}

class _VoiceLifecycleObserver with WidgetsBindingObserver {
  _VoiceLifecycleObserver({required this.onResumed});

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}
