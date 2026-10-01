import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../../dictionary/presentation/providers/word_detail_providers.dart';
import '../../../dictionary/presentation/widgets/audio_player_tile.dart';
import '../../domain/entities/vote_deck_item.dart';

/// Isi kartu deck: detail lengkap kata (gambar, audio, semua makna + contoh).
///
/// Deck API hanya membawa satu `sense`; detail diambil dari
/// [wordDetailProvider]. Selama loading/gagal, kartu tetap tampil dengan
/// data deck supaya tidak pernah kosong.
class VoteDeckWordCard extends ConsumerWidget {
  const VoteDeckWordCard({super.key, required this.item, this.onOpenDetail});

  final VoteDeckItem item;

  /// Buka halaman detail kata (komentar, riwayat, …). Null = tanpa link.
  final VoidCallback? onOpenDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(wordDetailProvider(item.id)).value;
    final content = detail == null
        ? VoteDeckWordFace(
            lemma: item.lemma,
            sense: item.sense,
            wordType: item.wordType,
          )
        : LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                // Isi pendek tetap di tengah kartu; isi panjang bisa di-scroll.
                constraints: BoxConstraints(
                  minHeight:
                      (constraints.maxHeight - 32).clamp(0, double.infinity),
                ),
                child: _WordDetailBody(detail: detail),
              ),
            ),
          );
    final open = onOpenDetail;
    if (open == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: content),
        _OpenDetailFooter(lemma: item.lemma, onTap: open),
      ],
    );
  }
}

/// Link ke halaman detail di bawah kartu (di luar area scroll): selalu
/// terlihat dan dekat jempol, sedekat action bar.
class _OpenDetailFooter extends StatelessWidget {
  const _OpenDetailFooter({required this.lemma, required this.onTap});

  final String lemma;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final color = theme.colors.primary;
    return Semantics(
      button: true,
      label: 'Lihat detail dan komentar $lemma',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.colors.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FLucideIcons.messageCircle, size: 14, color: color),
                const Gap(6),
                Text(
                  'Lihat detail dan komentar',
                  style: theme.typography.sm.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(2),
                Icon(FLucideIcons.chevronRight, size: 14, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WordDetailBody extends StatelessWidget {
  const _WordDetailBody({required this.detail});

  final WordDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final images = detail.images;
    final image = images.isEmpty
        ? null
        : images.firstWhere((i) => i.isPrimary, orElse: () => images.first);
    final meanings = detail.meanings;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (image != null) ...[
          GestureDetector(
            onTap: () => showImagePreview(
              context,
              urls: [image.url],
              credits: [image.attribution],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImageWithFallback(
                  imageUrl: displayImageUrl(image.url, width: 900) ?? image.url,
                  fallbackUrl: image.url,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const Gap(12),
        ],
        Text(
          detail.lemma,
          style: theme.typography.xl.copyWith(fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const Gap(2),
        Text(
          detail.wordTypeLabel,
          style: theme.typography.xs.copyWith(color: theme.colors.mutedForeground),
          textAlign: TextAlign.center,
        ),
        if (detail.audios.isNotEmpty) ...[
          const Gap(8),
          AudioPlayerTile(wordId: detail.id, audio: detail.audios.first),
        ],
        const Gap(12),
        for (var i = 0; i < meanings.length; i++)
          _MeaningView(
            index: meanings.length > 1 ? i + 1 : null,
            meaning: meanings[i],
            wordId: detail.id,
          ),
      ],
    );
  }
}

class _MeaningView extends StatelessWidget {
  const _MeaningView({
    required this.index,
    required this.meaning,
    required this.wordId,
  });

  /// Null saat kata hanya punya satu makna (nomor tidak perlu).
  final int? index;
  final WordMeaning meaning;
  final String wordId;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final className = meaning.wordClassName?.trim();
    final definition = meaning.definition?.trim();
    final muted = theme.colors.mutedForeground;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (className != null && className.isNotEmpty)
          Text(
            className,
            style: theme.typography.xs.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colors.primary,
            ),
          ),
        if (definition != null && definition.isNotEmpty && definition != '-')
          Text(definition, style: theme.typography.sm.copyWith(height: 1.35)),
        for (final t in meaning.translations)
          Text(
            '→ ${t.text}',
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
          ),
        for (final e in meaning.examples) ...[
          const Gap(6),
          Text(
            e.sourceSentence,
            style: theme.typography.sm.copyWith(fontStyle: FontStyle.italic),
          ),
          if (e.targetSentence?.trim().isNotEmpty ?? false)
            Text(
              e.targetSentence!.trim(),
              style: theme.typography.sm.copyWith(color: muted),
            ),
          for (final audio in e.audios)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: AudioPlayerTile(wordId: wordId, audio: audio),
            ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: index == null
          ? body
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  child: Text(
                    '$index.',
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: muted,
                    ),
                  ),
                ),
                Expanded(child: body),
              ],
            ),
    );
  }
}

/// Tampilan ringkas kartu (lemma, satu arti, jenis kata): guest deck dan
/// kartu yang detailnya belum/gagal dimuat.
class VoteDeckWordFace extends StatelessWidget {
  const VoteDeckWordFace({
    super.key,
    required this.lemma,
    required this.sense,
    required this.wordType,
  });

  final String lemma;
  final String? sense;
  final String wordType;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            lemma,
            style: theme.typography.xl.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          if (sense != null && sense!.trim().isNotEmpty) ...[
            const Gap(10),
            Text(
              sense!,
              style: theme.typography.md.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (wordType.isNotEmpty) ...[
            const Gap(12),
            Text(
              wordType,
              style: theme.typography.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
