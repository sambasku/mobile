import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_noise_filter/livekit_noise_filter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/thread_audio_player_provider.dart';
import '../../data/voice_repository.dart';

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
  String? _msgDisconnected;
  String? _msgConnectTimeout;
  String _roomName = 'sambasku-global';

  @override
  VoiceRoomState build() {
    ref.onDispose(() {
      _intentionalLeave = true;
      _disconnectSilent();
    });
    return const VoiceRoomState();
  }

  Future<void> _ensureLiveKit() async {
    if (_lkReady) return;
    await LiveKitClient.initialize();
    _lkReady = true;
  }

  Future<void> join(AppLocalizations l10n) async {
    if (state.phase == VoiceRoomPhase.connecting || state.isInSession) return;

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
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
      _syncParticipants(forceConnected: true);
      _scheduleTokenRefresh(jwt);
      _trackVoiceEvent(VoiceRoomEventKind.joined);
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
    final platform = defaultTargetPlatform.name;
    unawaited(
      ref.read(voiceRepositoryProvider).reportEvent(
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
    _trackVoiceEvent(VoiceRoomEventKind.left);
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
    state = state.copyWith(clearError: true, phase: VoiceRoomPhase.idle);
  }

  void _syncParticipants({bool forceConnected = false}) {
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
    for (final p in room.remoteParticipants.values) {
      list.add(mapParticipant(p, isLocal: false));
    }

    list.sort((a, b) {
      if (a.speaking != b.speaking) return a.speaking ? -1 : 1;
      if (a.isLocal != b.isLocal) return a.isLocal ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    state = state.copyWith(
      phase: forceConnected ? VoiceRoomPhase.connected : null,
      muted: local != null ? !local.isMicrophoneEnabled() : state.muted,
      participants: list,
      participantCount: list.length,
      clearError: forceConnected,
    );
  }

  Future<void> _disconnectSilent() async {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
    _tokenRefreshInFlight = false;
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
