import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/voice_room_provider.dart';

class VoiceRoomSummaryState {
  const VoiceRoomSummaryState({
    this.participantCount = 0,
    this.voiceRoomEnabled = false,
    this.loading = false,
  });

  final int participantCount;
  final bool voiceRoomEnabled;
  final bool loading;

  VoiceRoomSummaryState copyWith({
    int? participantCount,
    bool? voiceRoomEnabled,
    bool? loading,
  }) {
    return VoiceRoomSummaryState(
      participantCount: participantCount ?? this.participantCount,
      voiceRoomEnabled: voiceRoomEnabled ?? this.voiceRoomEnabled,
      loading: loading ?? this.loading,
    );
  }
}

/// Jumlah peserta voice room untuk pengamat chat (poll API).
final voiceRoomSummaryProvider =
    NotifierProvider<VoiceRoomSummaryController, VoiceRoomSummaryState>(
  VoiceRoomSummaryController.new,
);

class VoiceRoomSummaryController extends Notifier<VoiceRoomSummaryState> {
  static const _pollInterval = Duration(seconds: 20);
  Timer? _timer;
  var _activeWatchers = 0;

  @override
  VoiceRoomSummaryState build() {
    ref.onDispose(_stopPolling);
    return const VoiceRoomSummaryState();
  }

  void watch() {
    _activeWatchers++;
    if (_activeWatchers == 1) {
      unawaited(refresh());
      _timer ??= Timer.periodic(_pollInterval, (_) {
        unawaited(refresh());
      });
    }
  }

  void unwatch() {
    if (_activeWatchers > 0) _activeWatchers--;
    if (_activeWatchers == 0) _stopPolling();
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh() async {
    if (!ref.mounted) return;
    final inSession = ref.read(voiceRoomProvider).isInSession;
    if (inSession) return;
    state = state.copyWith(loading: true);
    try {
      final summary = await ref.read(voiceRepositoryProvider).fetchRoomSummary();
      if (!ref.mounted) return;
      state = VoiceRoomSummaryState(
        participantCount: summary.participantCount,
        voiceRoomEnabled: summary.voiceRoomEnabled,
        loading: false,
      );
    } catch (e, st) {
      debugPrint('VoiceRoomSummary refresh failed: $e\n$st');
      if (ref.mounted) {
        state = state.copyWith(loading: false);
      }
    }
  }
}