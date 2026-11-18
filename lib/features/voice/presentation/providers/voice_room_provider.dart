import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/voice_repository.dart';

enum VoiceRoomPhase { idle, connecting, connected, error }

class VoiceRoomState {
  const VoiceRoomState({
    this.phase = VoiceRoomPhase.idle,
    this.muted = false,
    this.participantCount = 0,
    this.errorMessage,
  });

  final VoiceRoomPhase phase;
  final bool muted;
  final int participantCount;
  final String? errorMessage;

  bool get isConnected => phase == VoiceRoomPhase.connected;

  VoiceRoomState copyWith({
    VoiceRoomPhase? phase,
    bool? muted,
    int? participantCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VoiceRoomState(
      phase: phase ?? this.phase,
      muted: muted ?? this.muted,
      participantCount: participantCount ?? this.participantCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final voiceRepositoryProvider = Provider<VoiceRepository>(
  (ref) => VoiceRepository(ref.watch(dioProvider)),
);

final voiceRoomProvider =
    NotifierProvider.autoDispose<VoiceRoomController, VoiceRoomState>(
      VoiceRoomController.new,
    );

class VoiceRoomController extends Notifier<VoiceRoomState> {
  Room? _room;

  @override
  VoiceRoomState build() {
    ref.onDispose(() {
      _disconnectSilent();
    });
    return const VoiceRoomState();
  }

  Future<void> join(AppLocalizations l10n) async {
    if (state.phase == VoiceRoomPhase.connecting || state.isConnected) return;

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      state = state.copyWith(
        phase: VoiceRoomPhase.error,
        errorMessage: l10n.voiceMicDenied,
      );
      return;
    }

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
      return;
    }

    try {
      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );
      _room = room;
      room.addListener(_onRoomChanged);
      await room.connect(token!.url, token!.token);
      await room.localParticipant?.setMicrophoneEnabled(true);
      if (!ref.mounted) {
        await room.disconnect();
        await room.dispose();
        return;
      }
      state = state.copyWith(
        phase: VoiceRoomPhase.connected,
        muted: false,
        participantCount: _countParticipants(room),
        clearError: true,
      );
    } catch (e, st) {
      debugPrint('VoiceRoom join failed: $e\n$st');
      await _disconnectSilent();
      if (!ref.mounted) return;
      state = state.copyWith(
        phase: VoiceRoomPhase.error,
        errorMessage: l10n.voiceJoinFailed,
      );
    }
  }

  Future<void> leave() async {
    await _disconnectSilent();
    if (!ref.mounted) return;
    state = const VoiceRoomState();
  }

  Future<void> toggleMute() async {
    final room = _room;
    final lp = room?.localParticipant;
    if (lp == null || !state.isConnected) return;
    final nextMuted = !state.muted;
    await lp.setMicrophoneEnabled(!nextMuted);
    if (!ref.mounted) return;
    state = state.copyWith(muted: nextMuted);
  }

  void clearError() {
    state = state.copyWith(clearError: true, phase: VoiceRoomPhase.idle);
  }

  void _onRoomChanged() {
    final room = _room;
    if (!ref.mounted || room == null) return;
    state = state.copyWith(participantCount: _countParticipants(room));
  }

  int _countParticipants(Room room) {
    return 1 + room.remoteParticipants.length;
  }

  Future<void> _disconnectSilent() async {
    final room = _room;
    _room = null;
    if (room == null) return;
    try {
      room.removeListener(_onRoomChanged);
      await room.disconnect();
      await room.dispose();
    } catch (e, st) {
      debugPrint('VoiceRoom disconnect: $e\n$st');
    }
  }
}
