import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/word_detail.dart';
import '../providers/audio_player_controller.dart';
import '../../../../core/widgets/pending_review_badge_icon.dart';

/// Tile audio compact (pola contoh kalimat): ikon + meta 1 baris + progress.
class AudioPlayerTile extends ConsumerWidget {
  const AudioPlayerTile({
    super.key,
    required this.wordId,
    required this.audio,
    this.dialectName,
  });

  final String wordId;
  final WordAudio audio;
  final String? dialectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final WordDetailAudioView view =
        ref.watch(wordDetailAudioPlayerProvider(wordId));
    final AudioTilePlaybackState playback = view.stateFor(audio.id);
    final isActive = view.activeAudioId == audio.id;
    final showBar = isActive && view.showProgress;
    final canSeek = isActive && view.canSeek;

    IconData icon;
    Color iconColor = theme.colors.primary;
    switch (playback) {
      case AudioTilePlaybackState.loading:
        icon = FLucideIcons.loader;
      case AudioTilePlaybackState.playing:
        icon = FLucideIcons.pause;
      case AudioTilePlaybackState.paused:
        icon = FLucideIcons.play;
      case AudioTilePlaybackState.error:
        icon = FLucideIcons.circleAlert;
        iconColor = theme.colors.error;
      case AudioTilePlaybackState.idle:
        icon = FLucideIcons.play;
    }

    final durationLabel = audio.formattedDuration;
    final metaParts = <String>[
      audio.displaySpeaker,
      if (dialectName case final d? when d.isNotEmpty) d,
    ];
    final meta = metaParts.join(' · ');

    final effectiveDuration = isActive && view.duration > Duration.zero
        ? view.duration
        : (audio.durationMs != null && audio.durationMs! > 0
            ? Duration(milliseconds: audio.durationMs!)
            : Duration.zero);

    final timeLabel = isActive && effectiveDuration > Duration.zero
        ? '${_fmt(view.position)} / ${_fmt(effectiveDuration)}'
        : durationLabel;

    final semanticsLabel = switch (playback) {
      AudioTilePlaybackState.playing => 'Jeda audio $meta',
      AudioTilePlaybackState.paused => 'Lanjutkan audio $meta',
      AudioTilePlaybackState.loading => 'Memuat audio $meta',
      AudioTilePlaybackState.error => 'Gagal memutar $meta, ketuk untuk coba lagi',
      AudioTilePlaybackState.idle => 'Putar audio $meta',
    };

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: theme.colors.secondary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _onTap(context, ref),
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
                      child: playback == AudioTilePlaybackState.loading
                          ? Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colors.primary,
                                ),
                              ),
                            )
                          : Icon(icon, size: 18, color: iconColor),
                    ),
                    const Gap(6),
                    Expanded(
                      child: Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.xs.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (audio.isPendingReview) ...[
                      const Gap(4),
                      Semantics(
                        button: true,
                        label: 'Menunggu pengecekan',
                        child: GestureDetector(
                          onTap: () => showPendingAudioReviewInfo(context),
                          child: const PendingReviewBadgeIcon(size: 14),
                        ),
                      ),
                    ],
                    if (timeLabel != null && timeLabel.isNotEmpty) ...[
                      const Gap(6),
                      Text(
                        timeLabel,
                        maxLines: 1,
                        softWrap: false,
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ],
                ),
                if (showBar) ...[
                  const Gap(4),
                  _ProgressBar(
                    progress: view.progress,
                    color: theme.colors.primary,
                    trackColor: theme.colors.border,
                    enabled: canSeek,
                    onSeek: canSeek
                        ? (ratio) {
                            ref
                                .read(
                                  wordDetailAudioPlayerProvider(wordId).notifier,
                                )
                                .seekRatio(ratio);
                          }
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _fmt(Duration d) {
    final total = d.inSeconds.clamp(0, 9999);
    final m = total ~/ 60;
    final s = total % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _onTap(BuildContext context, WidgetRef ref) async {
    final seed = audio.durationMs != null && audio.durationMs! > 0
        ? Duration(milliseconds: audio.durationMs!)
        : null;
    final notifier = ref.read(wordDetailAudioPlayerProvider(wordId).notifier);
    await notifier.toggle(audio.id, audio.url, seedDuration: seed);
    final next = ref.read(wordDetailAudioPlayerProvider(wordId));
    if (next.stateFor(audio.id) == AudioTilePlaybackState.error &&
        context.mounted) {
      showFToast(
        context: context,
        title: const Text(
          'Gagal memutar audio. Periksa koneksi lalu coba lagi.',
        ),
        variant: FToastVariant.destructive,
      );
    }
  }
}

/// Hentikan player saat meninggalkan subtree (halaman detail).
class StopAudioOnLeave extends ConsumerStatefulWidget {
  const StopAudioOnLeave({
    super.key,
    required this.wordId,
    required this.child,
  });

  final String wordId;
  final Widget child;

  @override
  ConsumerState<StopAudioOnLeave> createState() => _StopAudioOnLeaveState();
}

class _StopAudioOnLeaveState extends ConsumerState<StopAudioOnLeave> {
  @override
  void deactivate() {
    // Panggil di deactivate (bukan dispose): Ref masih aman dipakai.
    try {
      ref.read(wordDetailAudioPlayerProvider(widget.wordId).notifier).stop();
    } catch (_) {
      // Provider mungkin sudah auto-dispose.
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
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
    return Semantics(
      label: 'Progres pemutaran',
      value: '${(progress * 100).round()} persen',
      slider: enabled,
      child: LayoutBuilder(
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
              height: 14,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 3,
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
      ),
    );
  }
}
