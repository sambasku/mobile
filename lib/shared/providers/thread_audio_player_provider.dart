import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_ui/material_ui.dart';

enum ThreadAudioPlaybackState { idle, loading, playing, paused, error }

class ThreadAudioView {
  const ThreadAudioView({
    this.activeAudioId,
    this.playbackState = ThreadAudioPlaybackState.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  final String? activeAudioId;
  final ThreadAudioPlaybackState playbackState;
  final Duration position;
  final Duration duration;

  ThreadAudioPlaybackState stateFor(String audioId) {
    if (activeAudioId != audioId) return ThreadAudioPlaybackState.idle;
    return playbackState;
  }

  double get progress {
    final total = duration.inMilliseconds;
    if (total <= 0) return 0;
    return (position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  bool get canSeek =>
      playbackState == ThreadAudioPlaybackState.playing ||
      playbackState == ThreadAudioPlaybackState.paused;

  ThreadAudioView copyWith({
    String? activeAudioId,
    ThreadAudioPlaybackState? playbackState,
    Duration? position,
    Duration? duration,
    bool clearActive = false,
  }) {
    return ThreadAudioView(
      activeAudioId: clearActive ? null : (activeAudioId ?? this.activeAudioId),
      playbackState: playbackState ?? this.playbackState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

/// Satu [AudioPlayer] global untuk audio thread (pantun / diskusi / komentar).
/// Exclusive: play item baru menghentikan yang sedang jalan.
final threadAudioPlayerProvider =
    NotifierProvider<ThreadAudioPlayerController, ThreadAudioView>(
      ThreadAudioPlayerController.new,
    );

class ThreadAudioPlayerController extends Notifier<ThreadAudioView> {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _sub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;
  var _endingPlayback = false;
  var _opId = 0;
  DateTime? _lastPosEmit;
  Duration? _pendingPos;
  Timer? _posThrottle;

  static const _posThrottleInterval = Duration(milliseconds: 120);

  @override
  ThreadAudioView build() {
    ref.onDispose(_disposePlayer);
    return const ThreadAudioView();
  }

  void _ensurePlayer() {
    if (_player != null) return;
    final player = AudioPlayer();
    unawaited(player.setLoopMode(LoopMode.off));
    _player = player;
    _sub = player.playerStateStream.listen(_onPlayerState);
    _posSub = player.positionStream.listen(_onPosition);
    _durSub = player.durationStream.listen(_onDuration);
  }

  bool _isCurrentOp(int op) => ref.mounted && op == _opId;

  void _onPosition(Duration pos) {
    if (!ref.mounted || _endingPlayback || state.activeAudioId == null) return;
    final now = DateTime.now();
    final last = _lastPosEmit;
    if (last != null && now.difference(last) < _posThrottleInterval) {
      _pendingPos = pos;
      _posThrottle ??= Timer(_posThrottleInterval, _flushPendingPos);
      return;
    }
    _emitPosition(pos);
  }

  void _flushPendingPos() {
    _posThrottle = null;
    final pending = _pendingPos;
    _pendingPos = null;
    if (!ref.mounted ||
        pending == null ||
        _endingPlayback ||
        state.activeAudioId == null) {
      return;
    }
    _emitPosition(pending);
  }

  void _emitPosition(Duration pos) {
    _lastPosEmit = DateTime.now();
    _pendingPos = null;
    state = state.copyWith(position: pos);
  }

  void _onDuration(Duration? d) {
    if (!ref.mounted || d == null || d <= Duration.zero) return;
    if (d == state.duration) return;
    state = state.copyWith(duration: d);
  }

  void _onPlayerState(PlayerState ps) {
    if (!ref.mounted || state.activeAudioId == null) return;
    if (ps.processingState == ProcessingState.completed) {
      _endingPlayback = true;
      unawaited(_resetAfterCompleted());
      return;
    }
    if (_endingPlayback) return;
    final playing = ps.playing;
    state = state.copyWith(
      playbackState: playing
          ? ThreadAudioPlaybackState.playing
          : ThreadAudioPlaybackState.paused,
      duration: _player?.duration ?? state.duration,
    );
  }

  Future<void> _resetAfterCompleted() async {
    final p = _player;
    if (p == null) return;
    try {
      await p.pause();
      await p.seek(Duration.zero);
    } catch (_) {}
    _endingPlayback = false;
    if (!ref.mounted) return;
    final id = state.activeAudioId;
    if (id == null) return;
    state = ThreadAudioView(
      activeAudioId: id,
      playbackState: ThreadAudioPlaybackState.idle,
      position: Duration.zero,
      duration: state.duration,
    );
  }

  /// Toggle play/pause. Audio lain yang sedang main dihentikan dulu.
  Future<void> toggle(
    String audioId,
    String url, {
    Duration? seedDuration,
  }) async {
    if (!ref.mounted) return;
    _endingPlayback = false;
    final op = ++_opId;
    final current = state;

    if (current.activeAudioId == audioId &&
        current.playbackState == ThreadAudioPlaybackState.playing) {
      await _player?.pause();
      if (!_isCurrentOp(op)) return;
      state = current.copyWith(playbackState: ThreadAudioPlaybackState.paused);
      return;
    }

    if (current.activeAudioId == audioId &&
        (current.playbackState == ThreadAudioPlaybackState.paused ||
            current.playbackState == ThreadAudioPlaybackState.idle ||
            current.playbackState == ThreadAudioPlaybackState.error)) {
      _ensurePlayer();
      if (current.playbackState == ThreadAudioPlaybackState.error ||
          current.playbackState == ThreadAudioPlaybackState.idle) {
        state = ThreadAudioView(
          activeAudioId: audioId,
          playbackState: ThreadAudioPlaybackState.loading,
          duration: seedDuration ?? current.duration,
        );
        try {
          await _player!.stop();
          await _player!.setLoopMode(LoopMode.off);
          await _player!.setUrl(url);
          if (!_isCurrentOp(op)) return;
          await _player!.play();
          if (!_isCurrentOp(op)) return;
          state = ThreadAudioView(
            activeAudioId: audioId,
            playbackState: ThreadAudioPlaybackState.playing,
            duration: _player!.duration ?? seedDuration ?? Duration.zero,
          );
        } catch (_) {
          if (!_isCurrentOp(op)) return;
          state = ThreadAudioView(
            activeAudioId: audioId,
            playbackState: ThreadAudioPlaybackState.error,
            duration: seedDuration ?? Duration.zero,
          );
        }
        return;
      }
      await _player?.play();
      if (!_isCurrentOp(op)) return;
      state = current.copyWith(
        playbackState: ThreadAudioPlaybackState.playing,
        duration: seedDuration ?? current.duration,
      );
      return;
    }

    // Ganti track: stop dulu, lalu mainkan target.
    state = ThreadAudioView(
      activeAudioId: audioId,
      playbackState: ThreadAudioPlaybackState.loading,
      duration: seedDuration ?? Duration.zero,
    );

    try {
      _ensurePlayer();
      await _player!.stop();
      if (!_isCurrentOp(op)) return;
      await _player!.setLoopMode(LoopMode.off);
      await _player!.setUrl(url);
      if (!_isCurrentOp(op)) return;
      await _player!.play();
      if (!_isCurrentOp(op)) return;
      state = ThreadAudioView(
        activeAudioId: audioId,
        playbackState: ThreadAudioPlaybackState.playing,
        duration: _player!.duration ?? seedDuration ?? Duration.zero,
      );
    } catch (_) {
      if (!_isCurrentOp(op)) return;
      state = ThreadAudioView(
        activeAudioId: audioId,
        playbackState: ThreadAudioPlaybackState.error,
        duration: seedDuration ?? Duration.zero,
      );
    }
  }

  Future<void> seekRatio(double ratio) async {
    final total = state.duration;
    if (total <= Duration.zero) return;
    final target = total * ratio.clamp(0.0, 1.0);
    try {
      await _player?.seek(target);
      if (!ref.mounted) return;
      state = state.copyWith(position: target);
    } catch (_) {}
  }

  Future<void> pause() async {
    _opId++;
    try {
      await _player?.pause();
    } catch (_) {}
    if (!ref.mounted) return;
    if (state.activeAudioId == null) return;
    if (state.playbackState == ThreadAudioPlaybackState.playing) {
      state = state.copyWith(playbackState: ThreadAudioPlaybackState.paused);
    }
  }

  Future<void> stop() async {
    _opId++;
    _endingPlayback = false;
    try {
      await _player?.stop();
    } catch (_) {}
    if (!ref.mounted) return;
    state = const ThreadAudioView();
  }

  Future<void> _disposePlayer() async {
    _posThrottle?.cancel();
    try {
      await _sub?.cancel();
    } catch (_) {}
    try {
      await _posSub?.cancel();
    } catch (_) {}
    try {
      await _durSub?.cancel();
    } catch (_) {}
    try {
      await _player?.dispose();
    } catch (_) {}
    _player = null;
  }
}

enum ThreadAudioLeaveAction { stop, pause }

/// Hentikan / jeda audio thread saat widget keluar dari pohon (navigasi).
class StopThreadAudioOnLeave extends ConsumerStatefulWidget {
  const StopThreadAudioOnLeave({
    super.key,
    required this.child,
    this.action = ThreadAudioLeaveAction.stop,
  });

  final Widget child;
  final ThreadAudioLeaveAction action;

  @override
  ConsumerState<StopThreadAudioOnLeave> createState() =>
      _StopThreadAudioOnLeaveState();
}

class _StopThreadAudioOnLeaveState
    extends ConsumerState<StopThreadAudioOnLeave> {
  @override
  void deactivate() {
    try {
      final notifier = ref.read(threadAudioPlayerProvider.notifier);
      if (widget.action == ThreadAudioLeaveAction.pause) {
        unawaited(notifier.pause());
      } else {
        unawaited(notifier.stop());
      }
    } catch (_) {}
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
