import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import 'smooth_audio_progress_bar.dart';

/// Shell visual seragam untuk semua player audio (detail lemma, pantun,
/// komentar, chat, diskusi, jinye) mengikuti gaya [AudioPlayerTile].
class AudioPlayerSurface extends StatelessWidget {
  const AudioPlayerSurface({
    super.key,
    required this.semanticsLabel,
    required this.label,
    required this.isLoading,
    required this.isPlaying,
    required this.isError,
    required this.showBar,
    required this.canSeek,
    required this.position,
    required this.duration,
    required this.onTap,
    this.timeLabel,
    this.trailing,
    this.progressSemanticsLabel,
    this.onSeek,
  });

  final String semanticsLabel;
  final String label;
  final bool isLoading;
  final bool isPlaying;
  final bool isError;
  final bool showBar;
  final bool canSeek;
  final Duration position;
  final Duration duration;
  final VoidCallback onTap;
  final String? timeLabel;
  final Widget? trailing;
  final String? progressSemanticsLabel;
  final ValueChanged<double>? onSeek;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final disableAnim = MediaQuery.disableAnimationsOf(context);
    final iconColor = isError ? theme.colors.error : theme.colors.primary;
    final icon = isError
        ? FLucideIcons.circleAlert
        : isPlaying
        ? FLucideIcons.pause
        : FLucideIcons.play;

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: theme.colors.secondary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: disableAnim
                              ? Duration.zero
                              : const Duration(milliseconds: 140),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                          child: isLoading
                              ? const FCircularProgress(
                                  key: ValueKey('loading'),
                                  size: .xs,
                                )
                              : Icon(
                                  icon,
                                  key: ValueKey(icon),
                                  size: 18,
                                  color: iconColor,
                                ),
                        ),
                      ),
                    ),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (trailing != null) ...[
                      const Gap(4),
                      trailing!,
                    ],
                    if (timeLabel != null && timeLabel!.isNotEmpty) ...[
                      const Gap(6),
                      Text(
                        timeLabel!,
                        maxLines: 1,
                        softWrap: false,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ],
                ),
                AnimatedSize(
                  duration: disableAnim
                      ? Duration.zero
                      : const Duration(milliseconds: 160),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: showBar
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: SmoothAudioProgressBar(
                            position: position,
                            duration: duration,
                            isPlaying: isPlaying,
                            color: theme.colors.primary,
                            trackColor: theme.colors.border,
                            enabled: canSeek,
                            semanticsLabel: progressSemanticsLabel,
                            onSeek: canSeek ? onSeek : null,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
