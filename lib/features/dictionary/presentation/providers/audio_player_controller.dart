import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';

part 'audio_player_controller.g.dart';

enum AudioTilePlaybackState { idle, loading, playing, paused, error }

class WordDetailAudioView {
  const WordDetailAudioView({
    this.activeAudioId,
    this.playbackState = AudioTilePlaybackState.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  final String? activeAudioId;
  final AudioTilePlaybackState playbackState;
  final Duration position;
  final Duration duration;

  AudioTilePlaybackState stateFor(String audioId) {
    if (activeAudioId != audioId) return AudioTilePlaybackState.idle;
    return playbackState;
  }

  /// 0..1 untuk progress bar; 0 jika durasi belum diketahui.
  double get progress {
    final total = duration.inMilliseconds;
    if (total <= 0) return 0;
    return (position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  /// Track tetap tampil untuk tile terakhir (termasuk idle setelah selesai).
  bool get showProgress =>
      activeAudioId != null && playbackState != AudioTilePlaybackState.error;

  bool get canSeek =>
      playbackState == AudioTilePlaybackState.playing ||
      playbackState == AudioTilePlaybackState.paused;

  WordDetailAudioView copyWith({
    String? activeAudioId,
    AudioTilePlaybackState? playbackState,
    Duration? position,
    Duration? duration,
    bool clearActive = false,
  }) {
    return WordDetailAudioView(
      activeAudioId: clearActive ? null : (activeAudioId ?? this.activeAudioId),
      playbackState: playbackState ?? this.playbackState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

/// Satu [AudioPlayer] per halaman detail kata.
@riverpod
class WordDetailAudioPlayer extends _$WordDetailAudioPlayer {
  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _sub;
  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration?>? _durSub;

  /// Hindari race: seek setelah completed jangan dianggap "masih playing".
  bool _endingPlayback = false;

  /// Batalkan hasil async lama saat toggle/play berganti cepat.
  int _opId = 0;

  DateTime? _lastPosEmit;
  Duration? _pendingPos;
  Timer? _posThrottle;

  static const _posThrottleInterval = Duration(milliseconds: 120);

  @override
  WordDetailAudioView build(String wordId) {
    ref.onDispose(_disposePlayer);
    return const WordDetailAudioView();
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
    if (!ref.mounted) return;
    _lastPosEmit = DateTime.now();
    final dur = _player?.duration ?? state.duration;
    // Hindari rebuild no-op.
    if (pos == state.position && dur == state.duration) return;
    state = state.copyWith(position: pos, duration: dur);
  }

  void _onDuration(Duration? dur) {
    if (!ref.mounted || dur == null || state.activeAudioId == null) return;
    if (dur == state.duration) return;
    state = state.copyWith(duration: dur);
  }

  void _onPlayerState(PlayerState playerState) {
    if (!ref.mounted) return;
    final id = state.activeAudioId;
    if (id == null) return;

    if (playerState.processingState == ProcessingState.completed) {
      _endingPlayback = true;
      final dur = _player?.duration ?? state.duration;
      // Akhir: bar penuh dulu, lalu seek(0) di background.
      state = WordDetailAudioView(
        activeAudioId: id,
        playbackState: AudioTilePlaybackState.idle,
        position: dur,
        duration: dur,
      );
      unawaited(_resetAfterCompleted());
      return;
    }

    if (_endingPlayback) {
      if (!playerState.playing &&
          playerState.processingState == ProcessingState.ready) {
        _endingPlayback = false;
      }
      return;
    }

    if (playerState.processingState == ProcessingState.loading ||
        playerState.processingState == ProcessingState.buffering) {
      state = state.copyWith(
        activeAudioId: id,
        playbackState: AudioTilePlaybackState.loading,
      );
      return;
    }

    if (playerState.processingState == ProcessingState.ready) {
      state = state.copyWith(
        activeAudioId: id,
        playbackState: playerState.playing
            ? AudioTilePlaybackState.playing
            : AudioTilePlaybackState.paused,
        duration: _player?.duration ?? state.duration,
      );
    }
  }

  Future<void> _resetAfterCompleted() async {
    final p = _player;
    if (p == null) return;
    try {
      await p.pause();
      await p.seek(Duration.zero);
      await p.pause();
    } catch (_) {
      // ignore
    }
    _endingPlayback = false;
    if (!ref.mounted) return;
    final id = state.activeAudioId;
    if (id == null) return;
    // Track kosong tetap terlihat sampai user ganti tile / play lagi.
    state = WordDetailAudioView(
      activeAudioId: id,
      playbackState: AudioTilePlaybackState.idle,
      position: Duration.zero,
      duration: state.duration,
    );
  }

  /// [seedDuration] dari metadata API agar bar tidak loncat 0 → durasi stream.
  Future<void> toggle(
    String audioId,
    String url, {
    Duration? seedDuration,
  }) async {
    _endingPlayback = false;
    final op = ++_opId;
    final current = state;

    if (current.activeAudioId == audioId &&
        current.playbackState == AudioTilePlaybackState.playing) {
      await _player?.pause();
      if (!_isCurrentOp(op)) return;
      state = current.copyWith(playbackState: AudioTilePlaybackState.paused);
      return;
    }

    // Play (bukan pause) → analytics sekali per tap play.
    AnalyticsService.instance.log(
      AnalyticsEvents.audioPlay,
      params: {'word_id': wordId, 'has_audio': 1},
    );

    if (current.activeAudioId == audioId &&
        (current.playbackState == AudioTilePlaybackState.paused ||
            current.playbackState == AudioTilePlaybackState.idle ||
            current.playbackState == AudioTilePlaybackState.error)) {
      _ensurePlayer();
      if (current.playbackState == AudioTilePlaybackState.idle ||
          current.playbackState == AudioTilePlaybackState.error) {
        // Error: muat ulang URL.
        if (current.playbackState == AudioTilePlaybackState.error) {
          state = WordDetailAudioView(
            activeAudioId: audioId,
            playbackState: AudioTilePlaybackState.loading,
            duration: seedDuration ?? current.duration,
          );
          try {
            await _player!.stop();
            await _player!.setLoopMode(LoopMode.off);
            await _player!.setUrl(url);
            if (!_isCurrentOp(op)) return;
            await _player!.play();
            if (!_isCurrentOp(op)) return;
            state = WordDetailAudioView(
              activeAudioId: audioId,
              playbackState: AudioTilePlaybackState.playing,
              duration: _player!.duration ?? seedDuration ?? Duration.zero,
            );
          } catch (_) {
            if (!_isCurrentOp(op)) return;
            state = WordDetailAudioView(
              activeAudioId: audioId,
              playbackState: AudioTilePlaybackState.error,
              duration: seedDuration ?? Duration.zero,
            );
          }
          return;
        }
        await _player?.seek(Duration.zero);
      }
      if (!_isCurrentOp(op)) return;
      await _player?.play();
      if (!_isCurrentOp(op)) return;
      state = current.copyWith(
        playbackState: AudioTilePlaybackState.playing,
        position: current.playbackState == AudioTilePlaybackState.idle
            ? Duration.zero
            : current.position,
        duration: seedDuration ?? current.duration,
      );
      return;
    }

    state = WordDetailAudioView(
      activeAudioId: audioId,
      playbackState: AudioTilePlaybackState.loading,
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
      state = WordDetailAudioView(
        activeAudioId: audioId,
        playbackState: AudioTilePlaybackState.playing,
        duration: _player!.duration ?? seedDuration ?? Duration.zero,
      );
    } catch (_) {
      if (!_isCurrentOp(op)) return;
      state = WordDetailAudioView(
        activeAudioId: audioId,
        playbackState: AudioTilePlaybackState.error,
        duration: seedDuration ?? Duration.zero,
      );
    }
  }

  Future<void> playLocalFile(String tag, String path) async {
    _endingPlayback = false;
    final op = ++_opId;
    state = WordDetailAudioView(
      activeAudioId: tag,
      playbackState: AudioTilePlaybackState.loading,
    );
    try {
      _ensurePlayer();
      await _player!.stop();
      if (!_isCurrentOp(op)) return;
      await _player!.setLoopMode(LoopMode.off);
      await _player!.setFilePath(path);
      if (!_isCurrentOp(op)) return;
      await _player!.play();
      if (!_isCurrentOp(op)) return;
      state = WordDetailAudioView(
        activeAudioId: tag,
        playbackState: AudioTilePlaybackState.playing,
        duration: _player!.duration ?? Duration.zero,
      );
    } catch (_) {
      if (!_isCurrentOp(op)) return;
      state = WordDetailAudioView(
        activeAudioId: tag,
        playbackState: AudioTilePlaybackState.error,
      );
    }
  }

  Future<void> playLocalClip(
    String tag,
    String path, {
    required double startSec,
    required double endSec,
  }) async {
    _endingPlayback = false;
    final op = ++_opId;
    state = WordDetailAudioView(
      activeAudioId: tag,
      playbackState: AudioTilePlaybackState.loading,
    );
    try {
      _ensurePlayer();
      await _player!.stop();
      if (!_isCurrentOp(op)) return;
      await _player!.setLoopMode(LoopMode.off);
      final start = Duration(milliseconds: (startSec * 1000).round());
      final end = Duration(milliseconds: (endSec * 1000).round());
      await _player!.setAudioSource(
        ClippingAudioSource(
          start: start,
          end: end,
          child: AudioSource.file(path),
        ),
      );
      if (!_isCurrentOp(op)) return;
      await _player!.play();
      if (!_isCurrentOp(op)) return;
      state = WordDetailAudioView(
        activeAudioId: tag,
        playbackState: AudioTilePlaybackState.playing,
        duration: end - start,
      );
    } catch (_) {
      if (!_isCurrentOp(op)) return;
      state = WordDetailAudioView(
        activeAudioId: tag,
        playbackState: AudioTilePlaybackState.error,
      );
    }
  }

  /// Seek relatif (0..1) pada audio aktif - dipakai tap pada progress bar.
  Future<void> seekRatio(double ratio) async {
    if (!state.canSeek) return;
    final p = _player;
    final dur = p?.duration ?? state.duration;
    if (p == null || dur.inMilliseconds <= 0) return;
    final target = Duration(
      milliseconds: (dur.inMilliseconds * ratio.clamp(0.0, 1.0)).round(),
    );
    await p.seek(target);
    if (!ref.mounted) return;
    state = state.copyWith(position: target);
  }

  Future<void> stop() async {
    _opId++;
    _endingPlayback = false;
    _posThrottle?.cancel();
    _posThrottle = null;
    _pendingPos = null;
    // Lepas instance sepenuhnya: sumber lokal (pratinjau lama) / URL
    // yang gagal tidak boleh menempel ke player berikutnya.
    await _tearDownPlayer();
    // Halaman sudah lepas: provider auto-dispose di tengah await ini.
    if (!ref.mounted) return;
    state = const WordDetailAudioView();
  }

  Future<void> _tearDownPlayer() async {
    final sub = _sub;
    final posSub = _posSub;
    final durSub = _durSub;
    final player = _player;
    _sub = null;
    _posSub = null;
    _durSub = null;
    _player = null;
    _endingPlayback = false;
    try {
      await sub?.cancel();
    } catch (_) {}
    try {
      await posSub?.cancel();
    } catch (_) {}
    try {
      await durSub?.cancel();
    } catch (_) {}
    try {
      await player?.stop();
    } catch (_) {}
    try {
      await player?.dispose();
    } catch (_) {}
  }

  void _disposePlayer() {
    _opId++;
    _posThrottle?.cancel();
    _posThrottle = null;
    _pendingPos = null;
    unawaited(_tearDownPlayer());
  }
}
