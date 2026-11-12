import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/utils/format_number.dart';
import '../../l10n/app_localizations.dart';
import '../providers/thread_audio_player_provider.dart';

/// Player audio thread (pantun / balasan diskusi / komentar).
///
/// Pakai [threadAudioPlayerProvider] global: satu audio aktif, play item
/// lain menghentikan yang sedang jalan. [audioId] unik per item (default: url).
class ThreadAudioPlayer extends ConsumerWidget {
  const ThreadAudioPlayer({
    super.key,
    required this.url,
    this.audioId,
    this.durationMs,
  });

  final String url;

  /// Kunci exclusive-play. Default [url].
  final String? audioId;
  final int? durationMs;

  String get _id => (audioId ?? url).trim();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(threadAudioPlayerProvider);
    final playback = view.stateFor(_id);
    final isActive = view.activeAudioId == _id;
    final playing = playback == ThreadAudioPlaybackState.playing;
    final loading = playback == ThreadAudioPlaybackState.loading;
    final error = playback == ThreadAudioPlaybackState.error;
    final pausedOrPlaying = playing ||
        playback == ThreadAudioPlaybackState.paused;

    final seed = durationMs != null && durationMs! > 0
        ? Duration(milliseconds: durationMs!)
        : null;
    final effectiveDuration = isActive && view.duration > Duration.zero
        ? view.duration
        : (seed ?? Duration.zero);
    final progress = isActive ? view.progress : 0.0;
    final canSeek = isActive && view.canSeek;

    final iconColor = error ? theme.colors.error : theme.colors.primary;
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

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: theme.colors.secondary.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            unawaitedToggle(ref, seed);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: loading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: theme.colors.primary,
                                  ),
                                )
                              : Icon(
                                  error
                                      ? FLucideIcons.circleAlert
                                      : playing
                                      ? FLucideIcons.pause
                                      : FLucideIcons.play,
                                  size: 22,
                                  color: iconColor,
                                ),
                        ),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusText,
                            style: theme.typography.body.sm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            timeLabel,
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (playing || loading) ...[
                      const Gap(8),
                      _PlayingBars(
                        active: playing,
                        color: theme.colors.primary,
                      ),
                    ],
                  ],
                ),
                const Gap(10),
                _ThreadProgressBar(
                  progress: progress,
                  color: theme.colors.primary,
                  trackColor: theme.colors.border,
                  enabled: canSeek,
                  onSeek: canSeek
                      ? (ratio) {
                          ref
                              .read(threadAudioPlayerProvider.notifier)
                              .seekRatio(ratio);
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
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

class _ThreadProgressBar extends StatelessWidget {
  const _ThreadProgressBar({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.enabled,
    this.onSeek,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final bool enabled;
  final ValueChanged<double>? onSeek;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled && onSeek != null
              ? (d) {
                  if (w <= 0) return;
                  onSeek!((d.localPosition.dx / w).clamp(0.0, 1.0));
                }
              : null,
          onHorizontalDragUpdate: enabled && onSeek != null
              ? (d) {
                  if (w <= 0) return;
                  onSeek!((d.localPosition.dx / w).clamp(0.0, 1.0));
                }
              : null,
          child: SizedBox(
            height: 16,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 4,
                  width: w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: trackColor),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: ColoredBox(color: color),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlayingBars extends StatefulWidget {
  const _PlayingBars({required this.active, required this.color});

  final bool active;
  final Color color;

  @override
  State<_PlayingBars> createState() => _PlayingBarsState();
}

class _PlayingBarsState extends State<_PlayingBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.active) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant _PlayingBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.active && _ctrl.isAnimating) {
      _ctrl
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 22,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(4, (i) {
              final wave = math.sin((_ctrl.value * 2 * math.pi) + i * 0.9);
              final h = widget.active ? 6.0 + (wave.abs() * 14.0) : 6.0;
              return Container(
                width: 4,
                height: h,
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: widget.active ? 0.9 : 0.35,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
