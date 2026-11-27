import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/utils/format_number.dart';
import '../../l10n/app_localizations.dart';
import '../providers/thread_audio_player_provider.dart';
import 'audio_player_surface.dart';

/// Player audio thread (pantun / balasan diskusi / komentar / chat / jinye).
///
/// Memakai tampilan seragam [AudioPlayerSurface] (identik detail lemma) dan
/// [threadAudioPlayerProvider] global: satu audio aktif, play item lain
/// menghentikan yang sedang jalan. [audioId] unik per item (default: url).
class ThreadAudioPlayer extends ConsumerWidget {
  const ThreadAudioPlayer({
    super.key,
    required this.url,
    this.audioId,
    this.durationMs,
    this.compact = true,
    this.color,
  });

  final String url;

  /// Kunci exclusive-play. Default [url].
  final String? audioId;
  final int? durationMs;

  /// Dipertahankan untuk kompatibilitas caller lama; seluruh player audio
  /// kini seragam mengikuti tampilan detail lemma ([AudioPlayerSurface]).
  final bool compact;

  /// Dipertahankan untuk kompatibilitas caller lama (diabaikan).
  final Color? color;

  String get _id => (audioId ?? url).trim();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(threadAudioPlayerProvider);
    final playback = view.stateFor(_id);
    final isActive = view.activeAudioId == _id;
    final playing = playback == ThreadAudioPlaybackState.playing;
    final loading = playback == ThreadAudioPlaybackState.loading;
    final error = playback == ThreadAudioPlaybackState.error;
    final pausedOrPlaying =
        playing || playback == ThreadAudioPlaybackState.paused;

    final seed = durationMs != null && durationMs! > 0
        ? Duration(milliseconds: durationMs!)
        : null;
    final effectiveDuration = isActive && view.duration > Duration.zero
        ? view.duration
        : (seed ?? Duration.zero);
    final canSeek = isActive && view.canSeek;
    final showBar =
        isActive && playback != ThreadAudioPlaybackState.error;

    final semanticsLabel = error
        ? l10n.threadAudioRetry
        : playing
        ? l10n.threadAudioPause
        : l10n.threadAudioPlay;

    final statusText = error
        ? l10n.threadAudioRetry
        : playing
        ? l10n.threadAudioPlaying
        : l10n.threadAudioIdle;

    final timeLabel = _timeLabel(
      isActive: isActive,
      playing: pausedOrPlaying,
      position: view.position,
      duration: effectiveDuration,
      durationMs: durationMs,
    );

    return AudioPlayerSurface(
      semanticsLabel: semanticsLabel,
      label: statusText,
      isLoading: loading,
      isPlaying: playing,
      isError: error,
      showBar: showBar,
      canSeek: canSeek,
      position: isActive ? view.position : Duration.zero,
      duration: effectiveDuration,
      timeLabel: timeLabel,
      progressSemanticsLabel: l10n.dictAudioProgress,
      onTap: () => unawaitedToggle(ref, seed),
      onSeek: (ratio) {
        ref.read(threadAudioPlayerProvider.notifier).seekRatio(ratio);
      },
    );
  }

  void unawaitedToggle(WidgetRef ref, Duration? seed) {
    // ignore: discarded_futures
    ref
        .read(threadAudioPlayerProvider.notifier)
        .toggle(_id, url, seedDuration: seed);
  }

  static String _fmt(Duration d) {
    final total = d.inSeconds.clamp(0, 9999);
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  static String _timeLabel({
    required bool isActive,
    required bool playing,
    required Duration position,
    required Duration duration,
    required int? durationMs,
  }) {
    if (duration > Duration.zero) {
      if (isActive && (playing || position > Duration.zero)) {
        return '${_fmt(position)} / ${_fmt(duration)}';
      }
      return _fmt(duration);
    }
    final ms = durationMs;
    if (ms == null || ms <= 0) return '';
    final sec = (ms / 1000).round().clamp(1, 9999);
    if (sec < 60) return '${formatRibuan(sec)}s';
    return _fmt(Duration(seconds: sec));
  }
}
