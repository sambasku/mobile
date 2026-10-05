import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/ulid.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../review/domain/review_access.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../../../bookmark/presentation/providers/bookmark_providers.dart';
import '../../../bookmark/presentation/widgets/bookmark_button.dart';
import '../../../comment/presentation/widgets/word_comments_section.dart';
import '../../../comment/presentation/providers/comment_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/in_app_review_service.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../../core/widgets/verified_badge_icon.dart';
import '../../../../shared/widgets/image_credit.dart';
import '../../../../shared/widgets/word_image_view.dart';
import '../../../vote/domain/entities/vote_target.dart';
import '../../../vote/domain/failures/vote_failure.dart';
import '../../../vote/presentation/providers/vote_providers.dart';
import '../../../vote/presentation/widgets/vote_buttons.dart';
import '../../domain/entities/word_detail.dart';
import '../../domain/failures/dictionary_failure.dart';
import '../../domain/providers/dictionary_domain_providers.dart';
import '../providers/word_detail_providers.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../share/data/share_background_repository.dart';
import '../../../share/presentation/share_sheet.dart';
import '../../../../core/network/network_providers.dart';
import '../../application/word_clipboard.dart';
import '../widgets/audio_player_tile.dart';
import '../widgets/pronunciation_section.dart';
import '../../../word_report/presentation/report_word_sheet.dart';
import '../../../suggest_edit/domain/suggest_edit_feedback.dart';

/// Halaman detail kata publik - GET /api/v1/words/:id.
class WordDetailPage extends HookConsumerWidget {
  const WordDetailPage({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      AnalyticsService.instance.logWordOpen(wordId: wordId, source: 'detail');
      return null;
    }, [wordId]);

    final async = ref.watch(wordDetailProvider(wordId));
    final theme = context.theme;

    // Deep link lemma → ganti URL ke ULID kanonis supaya history/bookmark
    // dan navigasi internal selalu pakai id.
    useEffect(() {
      final detail = async.asData?.value;
      if (detail == null) return null;
      if (looksLikeUlid(wordId) && detail.id == wordId) return null;
      if (detail.id == wordId) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.replace('/words/${detail.id}');
      });
      return null;
    }, [async, wordId]);

    final resolvedId = async.asData?.value.id ?? wordId;

    return StopAudioOnLeave(
      wordId: resolvedId,
      child: FScaffold(
        // childPad false: carousel foto full-bleed selebar layar; padding
        // horizontal konten lain di-handle [_DetailBody].
        childPad: false,
        header: FHeader.nested(
          title: Text(
            async.maybeWhen(data: (d) => d.lemma, orElse: () => 'Detail kata'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
          suffixes: [
            FHeaderAction(
              icon: const Icon(FLucideIcons.history),
              semanticsLabel: 'Riwayat perubahan',
              onPress: () => context.push('/words/$resolvedId/history'),
            ),
            _WordBookmarkHeaderAction(wordId: resolvedId),
          ],
        ),
        child: async.when(
          loading: () => const _DetailSkeleton(),
          error: (error, _) {
            final failure = error is DictionaryFailure
                ? error
                : DictionaryFailure(error.toString());
            final isNotFound = failure.errorCode == 'WORD_NOT_FOUND';
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isNotFound
                          ? FLucideIcons.searchX
                          : FLucideIcons.circleAlert,
                      size: 40,
                      color: theme.colors.mutedForeground,
                    ),
                    const Gap(10),
                    Text(
                      isNotFound
                          ? 'Kata tidak ditemukan'
                          : 'Gagal memuat detail',
                      style: theme.typography.md.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(6),
                    Text(
                      failure.message,
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () => ref.invalidate(wordDetailProvider(wordId)),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          },
          data: (detail) => _DetailBody(detail: detail, wordId: detail.id),
        ),
      ),
    );
  }
}

void openWordShareSheet(
  BuildContext context,
  WidgetRef ref,
  WordDetail detail,
) {
  final repo = ShareBackgroundRepository(ref.read(dioProvider));
  final isAuth = ref.read(authStatusProvider).value?.isAuth ?? false;
  showWordShareSheet(
    context,
    detail: detail,
    backgrounds: repo,
    onShared: isAuth ? () => repo.recordCardShare(detail.id) : null,
  );
}

/// Pull-to-refresh: hard miss L1 detail dulu, lalu invalidate family
/// (+ vote/bookmark/komentar) dan tunggu fetch supaya indikator selesai.
Future<void> _refreshWordDetail(WidgetRef ref, String wordId) async {
  final key = wordId.trim();
  if (looksLikeUlid(key)) {
    await ref.read(getWordByIdUseCaseProvider)(key, forceRefresh: true);
  } else {
    await ref.read(getWordByLemmaUseCaseProvider)(key, forceRefresh: true);
  }
  final voteTarget = VoteTarget(type: 'word', id: wordId);
  ref.invalidate(wordDetailProvider(wordId));
  ref.invalidate(voteControllerProvider(voteTarget));
  ref.invalidate(bookmarkToggleControllerProvider(wordId));
  ref.invalidate(commentListControllerProvider(wordId));
  await Future.wait([
    ref.read(wordDetailProvider(wordId).future),
    ref.read(commentListControllerProvider(wordId).future),
  ]);
}

Future<void> _openWordReview(
  BuildContext context,
  WidgetRef ref,
  String wordId,
) async {
  final result = await ref
      .read(reviewRepositoryProvider)
      .list(status: 'pending', wordId: wordId, limit: 20);
  if (!context.mounted) return;
  result.match(
    (failure) {
      final message = failure.isForbidden
          ? 'Kamu tidak berwenang meninjau usulan.'
          : failure.message;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    },
    (page) {
      if (page.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada usulan yang menunggu untuk kata ini.'),
          ),
        );
        return;
      }
      if (page.items.length == 1) {
        context.push('/review/${page.items.first.id}');
        return;
      }
      context.push('/review/queue?wordId=$wordId');
    },
  );
}

/// Ikon menunggu pengecekan. Untuk verifikator, aksi Tinjau ada di bottom
/// sheet yang sama polanya dengan [showVerifierAttributionSheet].
class _PendingStatusBadge extends StatelessWidget {
  const _PendingStatusBadge({
    required this.offerReview,
    required this.onReview,
  });

  final bool offerReview;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Menunggu pengecekan',
      child: GestureDetector(
        onTap: () {
          if (offerReview) {
            showPendingReviewSheet(context, onReview: onReview);
            return;
          }
          showPendingReviewInfo(context);
        },
        child: const PendingReviewBadgeIcon(),
      ),
    );
  }
}

void showPendingReviewSheet(
  BuildContext context, {
  required VoidCallback onReview,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      return Material(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Menunggu pengecekan',
                        style: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  'Kata ini belum dicek tim SambasKu, jadi makna atau terjemahannya bisa saja kurang pas.',
                  style: theme.typography.sm,
                ),
                const Gap(12),
                FButton(
                  onPress: () {
                    Navigator.of(sheetContext).pop();
                    onReview();
                  },
                  child: const Text('Tinjau'),
                ),
                const Gap(8),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _DetailBody extends HookConsumerWidget {
  const _DetailBody({required this.detail, required this.wordId});

  final WordDetail detail;
  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final violenceRevealed = useState(false);
    useEffect(() {
      violenceRevealed.value = false;
      return null;
    }, [wordId]);

    // Foto utama dulu, sisanya urutan API.
    final orderedImages = [
      ...detail.images.where((i) => i.isPrimary),
      ...detail.images.where((i) => !i.isPrimary),
    ];
    final allSpelling = detail.variants.every((v) => v.isSpellingVariant);
    // Ejaan alternatif hanya form pendek, tanpa afiks. Badge-nya mengalir
    // horizontal. Catatan (jarang) tetap satu baris supaya teksnya tidak hilang.
    final compactSpelling =
        allSpelling &&
        detail.variants.every((v) => v.notes == null || v.notes!.isEmpty);

    Future<void> requestRevealViolence() async {
      final ok = await confirmRevealViolenceImage(context);
      if (ok) {
        violenceRevealed.value = true;
        AnalyticsService.instance.log(
          AnalyticsEvents.imageViolenceReveal,
          params: {'word_id': wordId},
        );
      }
    }

    Future<void> openPreview(WordImage source) async {
      // Pending images have no real URL - don't open gallery.
      if (source.isPendingReview || isKnownPendingPlaceholderUrl(source.url)) {
        showFToast(
          context: context,
          title: const Text('Gambar sedang dalam peninjauan.'),
        );
        return;
      }
      if (source.hasViolenceWarning && !violenceRevealed.value) {
        await requestRevealViolence();
        if (!violenceRevealed.value) return;
      }
      if (!context.mounted) return;
      // Preview list: exclude pending images (no valid URL).
      final previewImages = detail.images
          .where(
            (i) => !i.isPendingReview && !isKnownPendingPlaceholderUrl(i.url),
          )
          .toList(growable: false);
      if (previewImages.isEmpty) return;
      final idx = previewImages.indexWhere((i) => i.id == source.id);
      await showImagePreview(
        context,
        urls: previewImages.map((i) => i.url).toList(growable: false),
        credits: previewImages
            .map((i) => i.attribution)
            .toList(growable: false),
        initialIndex: idx < 0 ? 0 : idx,
      );
    }

    Future<void> reportImageViolence(WordImage image) async {
      final auth = await ref.read(authStatusProvider.future);
      if (!context.mounted) return;
      if (!auth.isAuth) {
        showFToast(
          context: context,
          title: const Text('Masuk dulu untuk melaporkan foto'),
        );
        context.push('/login');
        return;
      }
      final sent = await showReportWordSheet(
        context,
        wordId,
        imageId: image.id,
      );
      if (!context.mounted || !sent) return;
      showFToast(
        context: context,
        title: const Text(
          'Laporan terkirim. Foto tetap tayang sampai ditinjau.',
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refreshWordDetail(ref, wordId),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
              children: [
                if (orderedImages.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _WordImageCarousel(
                      images: orderedImages,
                      revealed: violenceRevealed.value,
                      onRequestReveal: requestRevealViolence,
                      onOpenPreview: openPreview,
                      onReportImage: reportImageViolence,
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header meta: lemma + badge + tipe + pelafalan.
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              detail.lemma,
                              style: theme.typography.xl.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                          ),
                          if (detail.isVerified)
                            Semantics(
                              button: true,
                              label: 'Lihat verifikator',
                              child: GestureDetector(
                                onTap: () => showVerifierAttributionSheet(
                                  context,
                                  detail,
                                ),
                                child: const VerifiedBadgeIcon(),
                              ),
                            )
                          else
                            _PendingStatusBadge(
                              offerReview:
                                  detail.status == 'published' &&
                                  canReviewQueue(
                                    ref.watch(authStatusProvider).value?.role,
                                  ),
                              onReview: () =>
                                  _openWordReview(context, ref, wordId),
                            ),
                        ],
                      ),
                      const Gap(2),
                      Text(
                        detail.wordTypeLabel,
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      if (detail.pronunciations.isNotEmpty) ...[
                        const Gap(4),
                        Text(
                          detail.pronunciations
                              .map((p) => '${p.notation} ${p.value}')
                              .join(' · '),
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const Gap(10),
                      PronunciationSection(
                        wordId: wordId,
                        languageId: detail.languageId,
                        audios: detail.audios,
                        spokenText: detail.lemma,
                      ),

                      if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                        const Gap(8),
                        Text(
                          detail.notes!,
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ],

                      if (detail.usageLabels.isNotEmpty ||
                          detail.categories.isNotEmpty) ...[
                        const Gap(8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final code in detail.usageLabels)
                              FBadge(
                                variant: isProminentUsageLabel(code)
                                    ? FBadgeVariant.primary
                                    : FBadgeVariant.secondary,
                                child: Text(usageLabelLabel(code)),
                              ),
                            for (final c in detail.categories)
                              FBadge(
                                variant: FBadgeVariant.secondary,
                                child: Text(c.name),
                              ),
                          ],
                        ),
                      ],

                      const Gap(10),
                      _WordVoteBar(wordId: wordId),

                      if (detail.meanings.isNotEmpty) ...[
                        const Gap(16),
                        const _SectionLabel('Makna'),
                        const Gap(6),
                        ...detail.meanings.asMap().entries.map(
                          (e) => _MeaningBlock(
                            index: e.key + 1,
                            lemma: detail.lemma,
                            meaning: e.value,
                            wordId: wordId,
                            languageId: detail.languageId,
                          ),
                        ),
                      ],

                      if (detail.variants.isNotEmpty) ...[
                        const Gap(14),
                        _SectionLabel(
                          allSpelling
                              ? 'Variasi penulisan'
                              : 'Variasi & bentuk turunan',
                        ),
                        const Gap(6),
                        if (compactSpelling)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final variant in detail.variants)
                                FBadge(
                                  variant: FBadgeVariant.secondary,
                                  child: Text(variant.form),
                                ),
                            ],
                          )
                        else
                          ...detail.variants.map(
                            (v) => _VariantRow(variant: v),
                          ),
                      ],

                      ..._relatedSections(detail.relatedWords),

                      if (detail.appearsIn.isNotEmpty) ...[
                        const Gap(14),
                        const _SectionLabel('Muncul dalam'),
                        const Gap(4),
                        ...detail.appearsIn.map((r) => _RelatedRow(related: r)),
                      ],

                      if (detail.combinedAttributionLabel != null ||
                          detail.creatorAttributionLabel != null ||
                          detail.verifierAttributionLabel != null) ...[
                        const Gap(18),
                        if (detail.combinedAttributionLabel != null)
                          _AttributionLine(
                            label: detail.combinedAttributionLabel!,
                            username:
                                detail.verifiedBy?.username ??
                                detail.createdBy!.username,
                            badge: detail.combinedByVerifier
                                ? 'Verifikator'
                                : null,
                          )
                        else ...[
                          if (detail.creatorAttributionLabel != null)
                            _AttributionLine(
                              label: detail.creatorAttributionLabel!,
                              username: detail.createdBy!.username,
                            ),
                          if (detail.verifierAttributionLabel != null) ...[
                            const Gap(2),
                            _AttributionLine(
                              label: detail.verifierAttributionLabel!,
                              username: detail.verifiedBy!.username,
                            ),
                          ],
                        ],
                      ],

                      const Gap(16),
                      _WordActionTileGroup(detail: detail, wordId: wordId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        WordCommentEntryBar(wordId: wordId),
      ],
    );
  }

  /// Kelompokkan relasi per tipe (Sinonim, Antonim, …) supaya jelas di UI.
  static List<Widget> _relatedSections(List<RelatedWord> related) {
    if (related.isEmpty) return const [];

    const order = [
      'synonym',
      'antonym',
      'derived_from',
      'has_component',
      'see_also',
    ];
    final grouped = <String, List<RelatedWord>>{};
    for (final r in related) {
      grouped.putIfAbsent(r.relationType, () => []).add(r);
    }

    final keys = [
      ...order.where(grouped.containsKey),
      ...grouped.keys.where((k) => !order.contains(k)),
    ];

    return [
      for (final key in keys) ...[
        const Gap(14),
        _SectionLabel(grouped[key]!.first.relationLabel),
        const Gap(4),
        ...grouped[key]!.map((r) => _RelatedRow(related: r)),
      ],
    ];
  }
}

/// Carousel foto selebar layar di atas detail kata. Kredit per foto mengikuti
/// foto yang sedang tampil; pending review tampil sebagai placeholder, foto
/// kekerasan di-blur sampai di-reveal.
class _WordImageCarousel extends StatefulWidget {
  const _WordImageCarousel({
    required this.images,
    required this.revealed,
    required this.onRequestReveal,
    required this.onOpenPreview,
    required this.onReportImage,
  });

  final List<WordImage> images;
  final bool revealed;
  final Future<void> Function() onRequestReveal;
  final Future<void> Function(WordImage) onOpenPreview;
  final Future<void> Function(WordImage) onReportImage;

  @override
  State<_WordImageCarousel> createState() => _WordImageCarouselState();
}

class _WordImageCarouselState extends State<_WordImageCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final images = widget.images;
    final current = images[_index.clamp(0, images.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final img = images[i];
                    final pending =
                        img.isPendingReview ||
                        isKnownPendingPlaceholderUrl(img.url);
                    return Semantics(
                      button: !pending,
                      label: pending
                          ? 'Gambar menunggu tinjauan'
                          : img.hasViolenceWarning && !widget.revealed
                          ? 'Foto berisi kekerasan, ketuk untuk menampilkan'
                          : 'Pratinjau gambar',
                      child: GestureDetector(
                        onTap: () => widget.onOpenPreview(img),
                        onLongPress: pending
                            ? null
                            : () => widget.onReportImage(img),
                        child: WordImageView(
                          image: img,
                          fit: BoxFit.cover,
                          revealed: widget.revealed,
                          onRequestReveal: widget.onRequestReveal,
                        ),
                      ),
                    );
                  },
                ),
                if (images.length > 1)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${_index + 1}/${images.length}',
                        style: theme.typography.xs.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (current.attribution case final credit?
            when !current.isPendingReview) ...[
          const Gap(6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ImageCredit(attribution: credit, fontSize: 11),
          ),
        ],
      ],
    );
  }
}

const _votePrompt = 'Vote';

class _WordVoteBar extends ConsumerWidget {
  const _WordVoteBar({required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final target = VoteTarget(type: 'word', id: wordId);
    final async = ref.watch(voteControllerProvider(target));

    ref.listen(voteControllerProvider(target), (prev, next) {
      if (next.hasError && !(prev?.hasError ?? false)) {
        final err = next.error;
        showFToast(
          context: context,
          title: Text(err is VoteFailure ? err.message : 'Gagal memuat vote'),
          variant: FToastVariant.destructive,
        );
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 50) return const SizedBox.shrink();

        return async.when(
          loading: () => Skeletonizer(
            enabled: true,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _votePrompt,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
                const Gap(8),
                const VoteButtonsSkeleton(compact: true),
              ],
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
          data: (view) => Row(
            children: [
              Expanded(
                child: Text(
                  _votePrompt,
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ),
              const Gap(8),
              VoteButtons(
                upvotes: view.upvotes,
                downvotes: view.downvotes,
                myVote: view.myVote,
                compact: true,
                onVote: (value) => _vote(context, ref, target, value),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _vote(
    BuildContext context,
    WidgetRef ref,
    VoteTarget target,
    int value,
  ) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk memberi vote'),
        variant: FToastVariant.primary,
      );
      context.push('/login');
      return;
    }
    final failure = await ref
        .read(voteControllerProvider(target).notifier)
        .toggle(value);
    if (failure != null && context.mounted) {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
    }
  }
}

/// Tombol bookmark di header detail kata (16-api-bookmark.md). Widget
/// tombolnya murni tampilan - guard login + toast failure ada di sini
/// (pola _vote pada _WordVoteBar).
class _WordBookmarkHeaderAction extends ConsumerWidget {
  const _WordBookmarkHeaderAction({required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bookmarkToggleControllerProvider(wordId));

    // Error seed → tetap tampilkan tombol (unbookmarked) supaya user bisa
    // coba toggle; jangan SizedBox.shrink (hilang tanpa pesan).
    return async.when(
      loading: () =>
          const BookmarkButton(isBookmarked: false, busy: true, onPress: _noop),
      error: (_, _) => BookmarkButton(
        isBookmarked: false,
        onPress: () => _toggle(context, ref),
      ),
      data: (status) => BookmarkButton(
        isBookmarked: status.isBookmarked,
        onPress: () => _toggle(context, ref),
      ),
    );
  }

  static Future<void> _noop() async {}

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      showFToast(
        context: context,
        title: const Text('Masuk dulu untuk menyimpan kata'),
        variant: FToastVariant.primary,
      );
      context.push('/login');
      return;
    }
    final failure = await ref
        .read(bookmarkToggleControllerProvider(wordId).notifier)
        .toggle();
    if (failure != null && context.mounted) {
      showFToast(
        context: context,
        title: Text(failure.message),
        variant: FToastVariant.destructive,
      );
      return;
    }
    // Bookmark sukses = momen positif; service memutuskan kapan prompt.
    unawaited(InAppReviewService.maybePrompt());
  }
}

/// Aksi di atas komentar: bagikan kartu + usul perubahan.
class _WordActionTileGroup extends ConsumerWidget {
  const _WordActionTileGroup({required this.detail, required this.wordId});

  final WordDetail detail;
  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = context.theme.colors.mutedForeground;
    final role = ref.watch(authStatusProvider).value?.role;
    final entryCopy = suggestEditEntryTileCopy(role);
    return FTileGroup(
      children: [
        FTile(
          prefix: const Icon(FLucideIcons.image),
          title: const Text('Bagikan kartu'),
          subtitle: const Text(
            'Buat kartu untuk cerita IG, WhatsApp, dan lainnya',
          ),
          suffix: Icon(FLucideIcons.chevronRight, size: 16, color: muted),
          onPress: () => openWordShareSheet(context, ref, detail),
        ),
        FTile(
          prefix: const Icon(FLucideIcons.penLine),
          title: Text(entryCopy.title),
          subtitle: Text(entryCopy.subtitle),
          suffix: Icon(FLucideIcons.chevronRight, size: 16, color: muted),
          onPress: () async {
            final auth = await ref.read(authStatusProvider.future);
            if (!context.mounted) return;
            if (!auth.isAuth) {
              showFToast(
                context: context,
                title: const Text('Masuk dulu untuk mengusulkan perubahan'),
              );
              context.push('/login');
              return;
            }
            context.push('/suggest-edit/$wordId');
          },
        ),
        FTile(
          prefix: const Icon(FLucideIcons.flag),
          title: const Text('Laporkan entri'),
          subtitle: const Text(
            'Untuk entri yang tidak layak tayang, bukan perbaikan isi',
          ),
          suffix: Icon(FLucideIcons.chevronRight, size: 16, color: muted),
          onPress: () async {
            final auth = await ref.read(authStatusProvider.future);
            if (!context.mounted) return;
            if (!auth.isAuth) {
              showFToast(
                context: context,
                title: const Text('Masuk dulu untuk melaporkan entri'),
              );
              context.push('/login');
              return;
            }
            final sent = await showReportWordSheet(context, wordId);
            if (!context.mounted || !sent) return;
            showFToast(
              context: context,
              title: const Text(
                'Laporan terkirim. Entri tetap tayang sampai ditinjau.',
              ),
            );
          },
        ),
        if (detail.images.isNotEmpty)
          FTile(
            prefix: const Icon(FLucideIcons.imageOff),
            title: const Text('Laporkan foto'),
            subtitle: const Text(
              'Foto bermasalah ditandai agar orang lain harus ketuk dulu sebelum melihat',
            ),
            suffix: Icon(FLucideIcons.chevronRight, size: 16, color: muted),
            onPress: () async {
              final auth = await ref.read(authStatusProvider.future);
              if (!context.mounted) return;
              if (!auth.isAuth) {
                showFToast(
                  context: context,
                  title: const Text('Masuk dulu untuk melaporkan foto'),
                );
                context.push('/login');
                return;
              }
              final imageId =
                  (detail.images.where((i) => i.isPrimary).firstOrNull ??
                          detail.images.first)
                      .id;
              final sent = await showReportWordSheet(
                context,
                wordId,
                imageId: imageId,
              );
              if (!context.mounted || !sent) return;
              showFToast(
                context: context,
                title: const Text('Laporan foto terkirim. Terima kasih.'),
              );
            },
          ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      text.toUpperCase(),
      style: theme.typography.sm.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.06,
        color: theme.colors.mutedForeground,
        fontSize: 11,
      ),
    );
  }
}

class _MeaningBlock extends StatelessWidget {
  const _MeaningBlock({
    required this.index,
    required this.lemma,
    required this.meaning,
    required this.wordId,
    required this.languageId,
  });

  final int index;
  final String lemma;
  final WordMeaning meaning;
  final String wordId;
  final String languageId;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final className = meaning.wordClassName;
    final definition = meaning.definition?.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$index.',
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (className != null && className.isNotEmpty)
                  Text(
                    className,
                    style: theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.primary,
                      fontSize: 12,
                    ),
                  ),
                if (definition != null && definition.isNotEmpty)
                  Text(
                    definition,
                    style: theme.typography.sm.copyWith(height: 1.35),
                  ),
                if (meaning.translations.isNotEmpty) ...[
                  const Gap(4),
                  ...meaning.translations.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '→ ${t.text}',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const Gap(4),
                  Text(
                    'Belum ada terjemahan',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (meaning.examples.isNotEmpty) ...[
                  const Gap(4),
                  ...meaning.examples.map((e) {
                    final translation = e.targetSentence?.trim();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.sourceSentence,
                            style: theme.typography.sm.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                          if (translation != null && translation.isNotEmpty)
                            Text(
                              translation,
                              style: theme.typography.sm.copyWith(
                                color: theme.colors.mutedForeground,
                                height: 1.3,
                              ),
                            ),
                          const Gap(4),
                          PronunciationSection(
                            wordId: wordId,
                            languageId: languageId,
                            audios: e.audios,
                            exampleId: e.id,
                            compact: true,
                            sectionLabel: 'Audio contoh',
                            spokenText: e.sourceSentence,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'Salin makna',
            onPressed: () => copyWordMeaningToClipboard(
              context,
              lemma: lemma,
              meaning: meaning,
            ),
            icon: Icon(
              FLucideIcons.copy,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedRow extends StatelessWidget {
  const _RelatedRow({required this.related});

  final RelatedWord related;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: () => context.push('/words/${related.wordId}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                related.lemma,
                style: theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              FLucideIcons.chevronRight,
              size: 14,
              color: theme.colors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({required this.variant});

  final WordVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final meta = [
      if (!variant.isSpellingVariant) variant.variantTypeLabel,
      if (variant.affixValue != null && variant.affixValue!.isNotEmpty)
        '"${variant.affixValue}"',
      if (variant.notes != null && variant.notes!.isNotEmpty) variant.notes!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          FBadge(variant: FBadgeVariant.secondary, child: Text(variant.form)),
          if (meta.isNotEmpty) ...[
            const Gap(8),
            Expanded(
              child: Text(
                meta,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
    final muted = theme.colors.muted;
    final shimmer = ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    // Mirror struktur [_DetailBody]: carousel full-bleed → meta → vote → makna.
    // Komentar ada di bar bawah.
    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shimmer),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Bone(width: double.infinity, height: double.infinity),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'lemma contoh kata',
                                style: theme.typography.xl.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                'Nomina',
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                '/ma.kan/',
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Bone.circle(size: 24),
                      ],
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Bone(
                          width: 56,
                          height: 22,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        Bone(
                          width: 72,
                          height: 22,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _votePrompt,
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                        const Gap(8),
                        const VoteButtonsSkeleton(compact: true),
                      ],
                    ),
                    const Gap(16),
                    const _SectionLabel('Makna'),
                    const Gap(6),
                    const _MeaningSkeletonBlock(index: 1),
                    const _MeaningSkeletonBlock(index: 2),
                    const Gap(16),
                    Text(
                      'Komentar',
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.mutedForeground,
                        fontSize: 11,
                        letterSpacing: 0.06,
                      ),
                    ),
                    const Gap(8),
                    const _CommentSkeletonCard(),
                    const Gap(8),
                    const _CommentSkeletonCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeaningSkeletonBlock extends StatelessWidget {
  const _MeaningSkeletonBlock({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$index.',
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verba',
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.primary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Definisi makna singkat untuk skeleton layout',
                  style: theme.typography.sm.copyWith(height: 1.35),
                ),
                const Gap(4),
                Text(
                  '→ terjemahan contoh',
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentSkeletonCard extends StatelessWidget {
  const _CommentSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'nama pengguna',
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(6),
          Text(
            'isi komentar skeleton beberapa kata di sini',
            style: theme.typography.sm,
          ),
          const Gap(10),
          const VoteButtonsSkeleton(compact: true),
        ],
      ),
    );
  }
}

class _AttributionLine extends StatelessWidget {
  const _AttributionLine({
    required this.label,
    required this.username,
    this.badge,
  });

  final String label;
  final String username;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tappable = isLinkablePublicUsername(username);
    final textStyle = theme.typography.sm.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w500,
    );
    return Semantics(
      button: tappable,
      label: badge == null ? label : '$label, $badge',
      child: GestureDetector(
        onTap: tappable
            ? () => UserProfileRouter.open(context, username)
            : null,
        child: Text.rich(
          TextSpan(
            style: textStyle,
            children: [
              TextSpan(text: label),
              if (badge != null)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge!,
                        style: theme.typography.xs.copyWith(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void showVerifierAttributionSheet(BuildContext context, WordDetail detail) {
  final verifiedAt = formatDateTimeIso(detail.verifiedAt);
  final profiles = <String>{
    if (isLinkablePublicUsername(detail.createdBy?.username))
      detail.createdBy!.username,
    if (isLinkablePublicUsername(detail.verifiedBy?.username))
      detail.verifiedBy!.username,
  };

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      return Material(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Atribusi',
                        style: theme.typography.lg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                if (detail.combinedAttributionLabel != null) ...[
                  Text(
                    detail.combinedAttributionLabel!,
                    style: theme.typography.sm,
                  ),
                  if (detail.combinedByVerifier) ...[
                    const Gap(6),
                    Text(
                      'Verifikator',
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ] else ...[
                  if (detail.creatorAttributionLabel != null)
                    Text(
                      detail.creatorAttributionLabel!,
                      style: theme.typography.sm,
                    ),
                  if (detail.verifierAttributionLabel != null) ...[
                    const Gap(4),
                    Text(
                      detail.verifierAttributionLabel!,
                      style: theme.typography.sm,
                    ),
                  ],
                ],
                if (verifiedAt.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    verifiedAt,
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
                for (final username in profiles) ...[
                  const Gap(12),
                  FButton(
                    onPress: () {
                      Navigator.of(sheetContext).pop();
                      UserProfileRouter.open(context, username);
                    },
                    child: Text(
                      profiles.length == 1
                          ? 'Lihat profil'
                          : 'Profil $username',
                    ),
                  ),
                ],
                const Gap(8),
              ],
            ),
          ),
        ),
      );
    },
  );
}
