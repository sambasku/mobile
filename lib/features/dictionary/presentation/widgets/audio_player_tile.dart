import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../../shared/widgets/audio_player_surface.dart';
import '../../domain/entities/word_detail.dart';
import '../dictionary_labels.dart';
import '../providers/audio_player_controller.dart';

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
    final l10n = AppLocalizations.of(context);
    final WordDetailAudioView view = ref.watch(
      wordDetailAudioPlayerProvider(wordId),
    );
    final AudioTilePlaybackState playback = view.stateFor(audio.id);
    final isActive = view.activeAudioId == audio.id;
    final showBar = isActive && view.showProgress;
    final canSeek = isActive && view.canSeek;

    final durationLabel = audio.formattedDuration;
    final metaParts = <String>[
      displaySpeaker(audio, l10n),
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
      AudioTilePlaybackState.error =>
        'Gagal memutar $meta, ketuk untuk coba lagi',
      AudioTilePlaybackState.idle => 'Putar audio $meta',
    };

    return AudioPlayerSurface(
      semanticsLabel: semanticsLabel,
      label: meta,
      isLoading: playback == AudioTilePlaybackState.loading,
      isPlaying: playback == AudioTilePlaybackState.playing,
      isError: playback == AudioTilePlaybackState.error,
      showBar: showBar,
      canSeek: canSeek,
      position: isActive ? view.position : Duration.zero,
      duration: effectiveDuration,
      timeLabel: timeLabel,
      progressSemanticsLabel: l10n.dictAudioProgress,
      trailing: audio.isPendingReview
          ? Semantics(
              button: true,
              label: l10n.dictPendingCheck,
              child: GestureDetector(
                onTap: () => showPendingAudioReviewInfo(context),
                child: const PendingReviewBadgeIcon(size: 14),
              ),
            )
          : null,
      onTap: () => _onTap(context, ref),
      onSeek: (ratio) {
        ref
            .read(wordDetailAudioPlayerProvider(wordId).notifier)
            .seekRatio(ratio);
      },
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
          'Gagal memutar audio. Coba lagi dalam beberapa saat.',
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
