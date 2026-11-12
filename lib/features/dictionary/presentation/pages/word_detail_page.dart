import 'dart:async';
import '../dictionary_labels.dart';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/ulid.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../review/domain/review_access.dart';
import '../../../review/presentation/providers/review_providers.dart';
import '../../../review/presentation/utils/open_pending_word_review.dart';
import '../../../review/presentation/providers/review_submit_queue.dart';
import '../../../review/presentation/widgets/reject_reason_sheet.dart';
import '../../../bookmark/presentation/providers/bookmark_providers.dart';
import '../../../bookmark/presentation/widgets/bookmark_button.dart';
import '../../../comment/presentation/widgets/word_comments_section.dart';
import '../../../comment/presentation/providers/comment_providers.dart';
import '../../../jinye/presentation/widgets/jinye_used_in_word_section.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/in_app_review_service.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../../core/widgets/verified_badge_icon.dart';
import '../../../../core/widgets/word_approved_badge_icon.dart';
import '../../../../shared/widgets/image_credit.dart';
import '../../../../shared/widgets/word_image_view.dart';
import '../../../vote/presentation/providers/meaning_vote_providers.dart';
import '../../../vote/presentation/widgets/meaning_vote_row.dart';
import '../../domain/entities/word_detail.dart';
import '../../domain/failures/dictionary_failure.dart';
import '../../domain/providers/dictionary_domain_providers.dart';
import '../providers/word_detail_providers.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../share/data/share_background_repository.dart';
import '../../../share/domain/word_public_url.dart';
import '../../../share/presentation/share_sheet.dart';
import '../../../../core/network/network_providers.dart';
import '../../application/word_clipboard.dart';
import '../widgets/audio_player_tile.dart';
import '../widgets/pronunciation_section.dart';
import '../widgets/written_pronunciation_line.dart';
import '../../../word_report/data/word_report_providers.dart';
import '../../../word_report/presentation/report_word_sheet.dart';
import '../../data/meaning_moderation_repository.dart';
import '../../../contribution/presentation/utils/invalidate_word_detail.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../l10n/app_localizations.dart';

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
        // childPad false: padding horizontal di-handle [_DetailBody].
        childPad: false,
        header: FHeader.nested(
          title: Text(
            async.maybeWhen(
              data: (d) => d.lemma,
              orElse: () => AppLocalizations.of(context).dictDetailTitle,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
          suffixes: [
            FHeaderAction(
              icon: const Icon(FLucideIcons.history),
              semanticsLabel: AppLocalizations.of(context).dictChangeHistory,
              onPress: () => context.push('/words/$resolvedId/history'),
            ),
            _WordBookmarkHeaderAction(wordId: resolvedId),
            if (async.asData?.value case final detail?)
              FHeaderAction(
                icon: const Icon(FLucideIcons.ellipsis),
                semanticsLabel: AppLocalizations.of(context).dictActionMore,
                onPress: () => _showWordActionsSheet(
                  context,
                  ref: ref,
                  detail: detail,
                  wordId: resolvedId,
                ),
              ),
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
                          ? AppLocalizations.of(context).dictWordNotFound
                          : AppLocalizations.of(context).commonLoadFailed,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(6),
                    Text(
                      failure.message,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () => ref.invalidate(wordDetailProvider(wordId)),
                      child: Text(AppLocalizations.of(context).commonRetry),
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

/// Share teks + URL kanonik `/id/words/<lemma>` ke sheet sistem.
Future<void> shareWordPublicLink(
  BuildContext context,
  WordDetail detail,
) async {
  final text = wordShareLinkMessage(detail.lemma);
  if (text.trim().isEmpty) return;
  AnalyticsService.instance.log(
    AnalyticsEvents.shareStart,
    params: {'word_id': detail.id, 'surface': 'link'},
  );
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      text: text,
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
  AnalyticsService.instance.log(
    AnalyticsEvents.shareComplete,
    params: {'word_id': detail.id, 'surface': 'link'},
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
  ref.invalidate(wordDetailProvider(wordId));
  ref.invalidate(bookmarkToggleControllerProvider(wordId));
  ref.invalidate(commentListControllerProvider(wordId));
  final detailFuture = ref.read(wordDetailProvider(wordId).future);
  final commentsFuture = ref.read(commentListControllerProvider(wordId).future);
  final detail = await detailFuture;
  await commentsFuture;
  // Vote menempel di MAKNA (0101), bukan kata: muat ulang counts makna
  // setelah detail segar diketahui. Tanpa ini tarik-refresh tidak
  // memperbarui angka vote yang tampil.
  final meaningIds = detail.meanings.map((m) => m.id).toList(growable: false);
  if (meaningIds.isNotEmpty) {
    await ref.read(meaningVotesControllerProvider.notifier).load(meaningIds);
  }
}

Future<void> _openWordReview(
  BuildContext context,
  WidgetRef ref,
  String wordId,
) => openPendingWordReview(context, ref, wordId);

Future<void> _approveInPlace(
  BuildContext context,
  WidgetRef ref,
  String wordId,
) async {
  final connection = await ref
      .read(reviewRepositoryProvider)
      .list(status: 'pending', wordId: wordId, limit: 20);
  if (!context.mounted) return;
  final pendingId = connection.match((failure) {
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
    return null;
  }, (page) => page.items.firstOrNull?.id);
  if (pendingId == null) return;
  final queue = ref.read(reviewSubmitQueueProvider.notifier);
  queue.enqueueApprove(pendingId);
  await queue.waitUntilDone(pendingId);
  if (!context.mounted) return;
  showFToast(
    context: context,
    title: Text(AppLocalizations.of(context).reviewSuggestionApprovedToast),
    variant: FToastVariant.primary,
  );
  await _refreshDetailAfterDecision(ref, wordId);
}

Future<void> _rejectInPlace(
  BuildContext context,
  WidgetRef ref,
  String wordId,
) async {
  final comment = await showRejectReasonSheet(context);
  if (comment == null || !context.mounted) return;
  final connection = await ref
      .read(reviewRepositoryProvider)
      .list(status: 'pending', wordId: wordId, limit: 20);
  if (!context.mounted) return;
  final pendingId = connection.match((failure) {
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
    return null;
  }, (page) => page.items.firstOrNull?.id);
  if (pendingId == null) return;
  final queue = ref.read(reviewSubmitQueueProvider.notifier);
  queue.enqueueReject(pendingId, comment: comment);
  await queue.waitUntilDone(pendingId);
  if (!context.mounted) return;
  showFToast(
    context: context,
    title: Text(AppLocalizations.of(context).reviewSuggestionRejectedToast),
    variant: FToastVariant.primary,
  );
  await _refreshDetailAfterDecision(ref, wordId);
}

/// Bypass L1 cache (forceRefresh) lalu invalidate family + await — persis
/// pola `_refreshWordDetail` tapi tanpa invalidasi provider lain (vote/
/// bookmark/komentar) yang bukan bagian dari keputusan review.
Future<void> _refreshDetailAfterDecision(WidgetRef ref, String wordId) async {
  final key = wordId.trim();
  if (looksLikeUlid(key)) {
    await ref.read(getWordByIdUseCaseProvider)(key, forceRefresh: true);
  } else {
    await ref.read(getWordByLemmaUseCaseProvider)(key, forceRefresh: true);
  }
  ref.invalidate(wordDetailProvider(wordId));
  await ref.read(wordDetailProvider(wordId).future);
}

/// Ikon menunggu pengecekan. Untuk verifikator, aksi Tinjau ada di bottom
/// sheet yang sama polanya dengan [showVerifierAttributionSheet].
class _PendingStatusBadge extends StatelessWidget {
  const _PendingStatusBadge({
    required this.offerReview,
    required this.onReview,
    required this.onApprove,
    required this.onReject,
  });

  final bool offerReview;
  final VoidCallback onReview;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocalizations.of(context).dictPendingCheck,
      child: GestureDetector(
        onTap: () {
          if (offerReview) {
            showPendingReviewSheet(
              context,
              onReview: onReview,
              onApprove: onApprove,
              onReject: onReject,
            );
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
  VoidCallback? onApprove,
  VoidCallback? onReject,
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
                        AppLocalizations.of(sheetContext).dictPendingCheck,
                        style: theme.typography.body.lg.copyWith(
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
                  AppLocalizations.of(sheetContext).dictUnverifiedWarning,
                  style: theme.typography.body.sm,
                ),
                const Gap(12),
                if (onApprove != null && onReject != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: FButton(
                          variant: FButtonVariant.outline,
                          onPress: () {
                            Navigator.of(sheetContext).pop();
                            onReject();
                          },
                          child: Text(
                            AppLocalizations.of(sheetContext).commonReject,
                          ),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: FButton(
                          onPress: () {
                            Navigator.of(sheetContext).pop();
                            onApprove();
                          },
                          child: Text(
                            AppLocalizations.of(sheetContext).commonApprove,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                ],
                FButton(
                  onPress: () {
                    Navigator.of(sheetContext).pop();
                    onReview();
                  },
                  child: Text(AppLocalizations.of(sheetContext).dictReview),
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

    // Vote per makna: 1 batch (counts + my-votes) untuk semua makna kata
    // ini. Gagal load tidak boleh blok halaman - tombol vote tetap tampil
    // dengan angka 0 dan toggle tetap jalan (server yang-source state).
    useEffect(() {
      final ids = detail.meanings.map((m) => m.id).toList(growable: false);
      if (ids.isEmpty) return null;
      ref
          .read(meaningVotesControllerProvider.notifier)
          .load(ids)
          .catchError((_) {});
      return null;
    }, [detail.id]);

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
          title: Text(AppLocalizations.of(context).dictImageUnderReview),
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
          title: Text(AppLocalizations.of(context).dictLoginToReportPhoto),
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
        title: Text(AppLocalizations.of(context).dictPhotoReportSent),
      );
    }

    // Per-makna "oleh X" hanya jika multi-makna dan kontributornya beda.
    final meaningContributorKeys = detail.meanings
        .map(
          (m) => (m.createdBy ?? detail.createdBy)?.username.trim().toLowerCase(),
        )
        .whereType<String>()
        .where((u) => u.isNotEmpty)
        .toSet();
    final showPerMeaningBy =
        detail.meanings.length > 1 && meaningContributorKeys.length > 1;

    final primaryImage = orderedImages.isEmpty ? null : orderedImages.first;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refreshWordDetail(ref, wordId),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        detail.lemma,
                                        style: theme.typography.body.xl
                                            .copyWith(
                                              fontWeight: FontWeight.w700,
                                              height: 1.15,
                                            ),
                                      ),
                                    ),
                                    if (detail.isVerified)
                                      Semantics(
                                        button: true,
                                        label: AppLocalizations.of(
                                          context,
                                        ).dictSeeVerifiers,
                                        child: GestureDetector(
                                          onTap: () =>
                                              showVerifierAttributionSheet(
                                                context,
                                                detail,
                                              ),
                                          child: const WordApprovedBadgeIcon(),
                                        ),
                                      )
                                    else
                                      _PendingStatusBadge(
                                        offerReview:
                                            detail.status == 'published' &&
                                            canReviewQueue(
                                              ref
                                                  .watch(authStatusProvider)
                                                  .value
                                                  ?.role,
                                            ),
                                        onReview: () => _openWordReview(
                                          context,
                                          ref,
                                          wordId,
                                        ),
                                        onApprove: () => _approveInPlace(
                                          context,
                                          ref,
                                          wordId,
                                        ),
                                        onReject: () => _rejectInPlace(
                                          context,
                                          ref,
                                          wordId,
                                        ),
                                      ),
                                  ],
                                ),
                                const Gap(4),
                                WrittenPronunciationLine(
                                  wordId: wordId,
                                  detail: detail,
                                ),
                                const Gap(6),
                                Text(
                                  wordDetailTypeLabel(
                                    detail,
                                    AppLocalizations.of(context),
                                  ),
                                  style: theme.typography.body.sm.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                                const Gap(12),
                                PronunciationSection(
                                  wordId: wordId,
                                  languageId: detail.languageId,
                                  audios: detail.audios,
                                  spokenText: detail.lemma,
                                  compact: true,
                                ),
                              ],
                            ),
                          ),
                          if (primaryImage != null) ...[
                            const Gap(16),
                            _LemmaImageThumb(
                              image: primaryImage,
                              imageCount: orderedImages.length,
                              revealed: violenceRevealed.value,
                              onRequestReveal: requestRevealViolence,
                              onOpenPreview: () => openPreview(primaryImage),
                              onReportImage: () =>
                                  reportImageViolence(primaryImage),
                            ),
                          ],
                        ],
                      ),
                      if (primaryImage case final img?
                          when !img.isPendingReview &&
                              img.attribution != null) ...[
                        const Gap(8),
                        ImageCredit(
                          attribution: img.attribution!,
                          fontSize: 11,
                        ),
                      ],

                      if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                        const Gap(12),
                        Text(
                          detail.notes!,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ],

                      if (detail.usageLabels.isNotEmpty ||
                          detail.categories.isNotEmpty) ...[
                        const Gap(12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final code in detail.usageLabels)
                              FBadge(
                                variant: isProminentUsageLabel(code)
                                    ? FBadgeVariant.primary
                                    : FBadgeVariant.secondary,
                                child: Text(
                                  usageLabelLabel(
                                    code,
                                    AppLocalizations.of(context),
                                  ),
                                ),
                              ),
                            for (final c in detail.categories)
                              FBadge(
                                variant: FBadgeVariant.secondary,
                                child: Text(c.name),
                              ),
                          ],
                        ),
                      ],

                      if (detail.meanings.isNotEmpty) ...[
                        const Gap(20),
                        ...detail.meanings.asMap().entries.map(
                          (e) => _MeaningBlock(
                            index: e.key + 1,
                            showIndex: detail.meanings.length > 1,
                            lemma: detail.lemma,
                            meaning: e.value,
                            wordId: wordId,
                            languageId: detail.languageId,
                            meaningCount: detail.meanings.length,
                            showPerMeaningBy: showPerMeaningBy,
                            contributor: showPerMeaningBy
                                ? (e.value.createdBy ?? detail.createdBy)
                                : null,
                          ),
                        ),
                      ],

                      if (combinedAttributionLabel(
                                detail,
                                AppLocalizations.of(context),
                              ) !=
                              null ||
                          creatorAttributionLabel(
                                detail,
                                AppLocalizations.of(context),
                              ) !=
                              null ||
                          verifierAttributionLabel(
                                detail,
                                AppLocalizations.of(context),
                              ) !=
                              null) ...[
                        const Gap(20),
                        if (combinedAttributionLabel(
                              detail,
                              AppLocalizations.of(context),
                            ) !=
                            null)
                          _AttributionLine(
                            label: combinedAttributionLabel(
                              detail,
                              AppLocalizations.of(context),
                            )!,
                            username:
                                detail.verifiedBy?.username ??
                                detail.createdBy!.username,
                            showCheck: detail.combinedByVerifier,
                          )
                        else ...[
                          if (creatorAttributionLabel(
                                detail,
                                AppLocalizations.of(context),
                              ) !=
                              null)
                            _AttributionLine(
                              label: creatorAttributionLabel(
                                detail,
                                AppLocalizations.of(context),
                              )!,
                              username: detail.createdBy!.username,
                              showCheck: isVerifierRole(detail.createdBy!.role),
                            ),
                          if (verifierAttributionLabel(
                                detail,
                                AppLocalizations.of(context),
                              ) !=
                              null) ...[
                            const Gap(4),
                            _AttributionLine(
                              label: verifierAttributionLabel(
                                detail,
                                AppLocalizations.of(context),
                              )!,
                              username: detail.verifiedBy!.username,
                              showCheck: isVerifierRole(
                                detail.verifiedBy!.role,
                              ),
                            ),
                          ],
                        ],
                      ],

                      if (detail.variants.isNotEmpty) ...[
                        const Gap(24),
                        _SectionLabel(
                          allSpelling
                              ? AppLocalizations.of(context).dictVariantsTitle
                              : AppLocalizations.of(
                                  context,
                                ).dictVariantsAndDerived,
                        ),
                        const Gap(8),
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

                      ..._relatedSections(
                        detail.relatedWords,
                        AppLocalizations.of(context),
                      ),

                      ..._meaningGroupSections(
                        detail.meaningGroups,
                        AppLocalizations.of(context),
                      ),

                      ..._appearsInSections(
                        detail.appearsIn,
                        AppLocalizations.of(context),
                      ),

                      JinyeUsedInWordSection(wordId: wordId),
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

  /// PRD relasi-lemma 8.3: render kelompok makna ("Makna terkait").
  /// Grup kosong tidak dirender; label = nama grup bila >1 grup, kalau
  /// satu pakai label tetap "Makna terkait".
  static List<Widget> _meaningGroupSections(
    List<MeaningGroup> groups,
    AppLocalizations l10n,
  ) {
    if (groups.isEmpty) return const [];
    final useGroupNames = groups.length > 1;
    return [
      for (final g in groups) ...[
        const Gap(20),
        _SectionLabel(useGroupNames ? g.name : l10n.dictRelatedMeanings),
        const Gap(8),
        _MeaningGroupChipWrap(members: g.members),
      ],
    ];
  }

  /// Kelompokkan relasi per tipe (Sinonim, Antonim, …) supaya jelas di UI.
  static List<Widget> _relatedSections(
    List<RelatedWord> related,
    AppLocalizations l10n,
  ) => _groupedRelationSections(related, l10n, labelFor: relationLabel);

  /// Relasi masuk (`appears_in`) - label arah kebalikan dari related_words.
  static List<Widget> _appearsInSections(
    List<RelatedWord> related,
    AppLocalizations l10n,
  ) =>
      _groupedRelationSections(related, l10n, labelFor: appearsInRelationLabel);

  static List<Widget> _groupedRelationSections(
    List<RelatedWord> related,
    AppLocalizations l10n, {
    required String Function(String, AppLocalizations) labelFor,
  }) {
    if (related.isEmpty) return const [];

    const order = [
      // PRD relasi-lemma 8.1/8.2: bentuk tidak baku & variasi paling atas,
      // lalu turunan, baru sinonim/antonim dan sisanya.
      'nonstandard_of',
      'variant_of',
      'derived_from',
      'synonym',
      'antonym',
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
        const Gap(20),
        _SectionLabel(labelFor(grouped[key]!.first.relationType, l10n)),
        const Gap(8),
        _RelatedChipWrap(items: grouped[key]!),
      ],
    ];
  }
}

/// Thumbnail 72px di kanan lemma. Tap buka gallery; badge jumlah bila >1 foto.
class _LemmaImageThumb extends StatelessWidget {
  const _LemmaImageThumb({
    required this.image,
    required this.imageCount,
    required this.revealed,
    required this.onRequestReveal,
    required this.onOpenPreview,
    required this.onReportImage,
  });

  final WordImage image;
  final int imageCount;
  final bool revealed;
  final Future<void> Function() onRequestReveal;
  final VoidCallback onOpenPreview;
  final VoidCallback onReportImage;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final pending =
        image.isPendingReview || isKnownPendingPlaceholderUrl(image.url);
    return Semantics(
      button: !pending,
      label: pending
          ? l10n.dictImagePendingReview
          : image.hasViolenceWarning && !revealed
          ? l10n.dictViolenceImage
          : l10n.dictImagePreview,
      child: GestureDetector(
        onTap: onOpenPreview,
        onLongPress: pending ? null : onReportImage,
        child: SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: WordImageView(
                  image: image,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  revealed: revealed,
                  onRequestReveal: onRequestReveal,
                ),
              ),
              if (imageCount > 1)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.dictPhotoCountBadge(imageCount),
                      style: theme.typography.body.xs.copyWith(
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
    );
  }
}

/// Tombol bookmark di header detail kata (16-api-bookmark.md). Widget
/// tombolnya murni tampilan - guard login + toast failure ada di sini
/// (pola _vote pada vote per makna).
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
        title: Text(AppLocalizations.of(context).dictLoginToSave),
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

Future<void> _openSuggestEdit(
  BuildContext context,
  WidgetRef ref,
  String wordId,
) async {
  final auth = await ref.read(authStatusProvider.future);
  if (!context.mounted) return;
  if (!auth.isAuth) {
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).dictLoginToSuggest),
    );
    context.push('/login');
    return;
  }
  await context.push('/suggest-edit/$wordId');
  if (context.mounted) {
    ref.invalidate(wordDetailProvider(wordId));
  }
}

Future<void> _reportEntry(
  BuildContext context,
  WidgetRef ref,
  String wordId,
) async {
  final auth = await ref.read(authStatusProvider.future);
  if (!context.mounted) return;
  if (!auth.isAuth) {
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).dictLoginToReportEntry),
    );
    context.push('/login');
    return;
  }
  final sent = await showReportWordSheet(context, wordId);
  if (!context.mounted || !sent) return;
  showFToast(
    context: context,
    title: Text(AppLocalizations.of(context).dictEntryReportSent),
  );
}

Future<void> _reportMeaning(
  BuildContext context,
  WidgetRef ref,
  String wordId,
  String meaningId,
) async {
  final auth = await ref.read(authStatusProvider.future);
  if (!context.mounted) return;
  if (!auth.isAuth) {
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).dictLoginToReportMeaning),
    );
    context.push('/login');
    return;
  }
  final sent = await showReportWordSheet(
    context,
    wordId,
    meaningId: meaningId,
  );
  if (!context.mounted || !sent) return;
  showFToast(
    context: context,
    title: Text(AppLocalizations.of(context).dictMeaningReportSent),
  );
}

Future<void> _confirmDeleteMeaning(
  BuildContext context,
  WidgetRef ref, {
  required String wordId,
  required String meaningId,
  required String lemma,
  required int meaningCount,
}) async {
  final l10n = AppLocalizations.of(context);
  if (meaningCount <= 1) {
    showFToast(
      context: context,
      title: Text(l10n.dictDeleteMeaningLastBlocked),
    );
    return;
  }
  final ok = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: MediaQuery.of(sheetContext).viewInsets,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTileGroup(
              children: [
                FTile(
                  title: Text(l10n.dictDeleteMeaningConfirmTitle),
                  subtitle: Text(l10n.dictDeleteMeaningConfirmBody),
                ),
                FTile(
                  title: Text(l10n.dictDeleteMeaningConfirm),
                  onPress: () => Navigator.pop(sheetContext, true),
                ),
                FTile(
                  title: Text(l10n.dictDeleteMeaningCancel),
                  onPress: () => Navigator.pop(sheetContext, false),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref
        .read(meaningModerationRepositoryProvider)
        .softDelete(wordId: wordId, meaningId: meaningId);
    if (!context.mounted) return;
    await invalidateWordDetailCaches(ref, wordId, lemma);
    if (!context.mounted) return;
    showFToast(
      context: context,
      title: Text(l10n.dictDeleteMeaningSuccess),
    );
  } on MeaningModerationFailure catch (error) {
    if (!context.mounted) return;
    await showAppErrorSheet(context, message: error.message);
  }
}

Future<void> _showMeaningActionsSheet(
  BuildContext context,
  WidgetRef ref, {
  required String wordId,
  required String lemma,
  required WordMeaning meaning,
  required int meaningCount,
}) async {
  final l10n = AppLocalizations.of(context);
  final role = ref.read(authStatusProvider).value?.role;
  final canDelete = canReviewQueue(role);
  final action = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      var handled = false;
      void go(String value) {
        if (handled) return;
        handled = true;
        Navigator.of(sheetContext).pop(value);
      }

      return Padding(
        padding: MediaQuery.of(sheetContext).viewInsets,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FTileGroup(
                label: Text(l10n.dictMeaningActionsTitle),
                children: [
                  FTile(
                    prefix: const Icon(FLucideIcons.copy),
                    title: Text(l10n.dictCopyMeaning),
                    onPress: () => go('copy'),
                  ),
                  if (canDelete)
                    FTile(
                      prefix: Icon(
                        FLucideIcons.trash2,
                        color: context.theme.colors.destructive,
                      ),
                      title: Text(l10n.dictDeleteMeaning),
                      subtitle: Text(l10n.dictDeleteMeaningSubtitle),
                      onPress: () => go('delete'),
                    )
                  else
                    FTile(
                      prefix: const Icon(FLucideIcons.flag),
                      title: Text(l10n.dictReportMeaning),
                      subtitle: Text(l10n.dictReportMeaningSubtitle),
                      onPress: () => go('report'),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  if (!context.mounted || action == null) return;
  switch (action) {
    case 'copy':
      await copyWordMeaningToClipboard(
        context,
        lemma: lemma,
        meaning: meaning,
      );
    case 'report':
      await _reportMeaning(context, ref, wordId, meaning.id);
    case 'delete':
      await _confirmDeleteMeaning(
        context,
        ref,
        wordId: wordId,
        meaningId: meaning.id,
        lemma: lemma,
        meaningCount: meaningCount,
      );
  }
}

Future<void> _reportPrimaryPhoto(
  BuildContext context,
  WidgetRef ref,
  WordDetail detail,
  String wordId,
) async {
  final auth = await ref.read(authStatusProvider.future);
  if (!context.mounted) return;
  if (!auth.isAuth) {
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).dictLoginToReportPhoto),
    );
    context.push('/login');
    return;
  }
  final imageId =
      (detail.images.where((i) => i.isPrimary).firstOrNull ??
              detail.images.first)
          .id;
  final sent = await showReportWordSheet(context, wordId, imageId: imageId);
  if (!context.mounted || !sent) return;
  showFToast(
    context: context,
    title: Text(AppLocalizations.of(context).dictPhotoReportThanks),
  );
}

/// Sheet aksi detail kata (header ⋯): bagikan, usulkan, lapor, kartu, foto.
Future<void> _showWordActionsSheet(
  BuildContext context, {
  required WidgetRef ref,
  required WordDetail detail,
  required String wordId,
}) {
  final l10n = AppLocalizations.of(context);
  final muted = context.theme.colors.mutedForeground;
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final viewInsets = MediaQuery.viewInsetsOf(sheetContext);
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            16 + viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.dictWordActionsTitle,
                style: sheetContext.theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(8),
              FTileGroup(
                children: [
                  FTile(
                    prefix: const Icon(FLucideIcons.link),
                    title: Text(l10n.dictShareLink),
                    subtitle: Text(l10n.dictShareLinkSubtitle),
                    suffix: Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: muted,
                    ),
                    onPress: () {
                      Navigator.pop(sheetContext);
                      shareWordPublicLink(context, detail);
                    },
                  ),
                  FTile(
                    prefix: const Icon(FLucideIcons.image),
                    title: Text(l10n.dictShareCard),
                    subtitle: Text(l10n.dictShareCardSubtitle),
                    suffix: Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: muted,
                    ),
                    onPress: () {
                      Navigator.pop(sheetContext);
                      openWordShareSheet(context, ref, detail);
                    },
                  ),
                  FTile(
                    prefix: const Icon(FLucideIcons.penLine),
                    title: Text(l10n.dictActionSuggest),
                    subtitle: Text(l10n.dictSuggestEditSubtitle),
                    suffix: Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: muted,
                    ),
                    onPress: () {
                      Navigator.pop(sheetContext);
                      _openSuggestEdit(context, ref, wordId);
                    },
                  ),
                  FTile(
                    prefix: const Icon(FLucideIcons.flag),
                    title: Text(l10n.dictReportEntry),
                    subtitle: Text(l10n.dictReportEntrySubtitle),
                    suffix: Icon(
                      FLucideIcons.chevronRight,
                      size: 16,
                      color: muted,
                    ),
                    onPress: () {
                      Navigator.pop(sheetContext);
                      _reportEntry(context, ref, wordId);
                    },
                  ),
                  if (detail.images.isNotEmpty)
                    FTile(
                      prefix: const Icon(FLucideIcons.imageOff),
                      title: Text(l10n.dictReportPhoto),
                      subtitle: Text(l10n.dictReportPhotoSubtitle),
                      suffix: Icon(
                        FLucideIcons.chevronRight,
                        size: 16,
                        color: muted,
                      ),
                      onPress: () {
                        Navigator.pop(sheetContext);
                        _reportPrimaryPhoto(context, ref, detail, wordId);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      text.toUpperCase(),
      style: theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.06,
        color: theme.colors.mutedForeground,
        fontSize: 11,
      ),
    );
  }
}

class _MeaningBlock extends ConsumerWidget {
  const _MeaningBlock({
    required this.index,
    required this.showIndex,
    required this.lemma,
    required this.meaning,
    required this.wordId,
    required this.languageId,
    required this.meaningCount,
    required this.showPerMeaningBy,
    this.contributor,
  });

  final int index;
  final bool showIndex;
  final String lemma;
  final WordMeaning meaning;
  final String wordId;
  final String languageId;
  final int meaningCount;

  /// Multi-makna + kontributor beda: tampilkan "oleh …" di bawah contoh.
  final bool showPerMeaningBy;

  final WordVerifier? contributor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final definition = meaning.definition?.trim();
    final classLabel =
        meaning.wordClassBracket ??
        (meaning.wordClassName != null && meaning.wordClassName!.isNotEmpty
            ? meaning.wordClassName
            : null);
    final username = contributor?.username;
    final showByLine =
        showPerMeaningBy && isLinkablePublicUsername(username);
    final byLabel = showByLine
        ? l10n.dictContributionBy(
            displayPublicAccountLabel(
              displayName: contributor?.displayName,
              username: username,
            ),
          )
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIndex)
            SizedBox(
              width: 22,
              child: Text(
                '$index.',
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (classLabel != null) ...[
                  Text(
                    classLabel,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Gap(4),
                ],
                if (definition != null && definition.isNotEmpty)
                  Text(
                    definition,
                    style: theme.typography.body.md.copyWith(height: 1.5),
                  ),
                if (meaning.translations.isNotEmpty) ...[
                  const Gap(6),
                  ...meaning.translations.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '→ ${t.text}',
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                if (meaning.examples.isNotEmpty) ...[
                  const Gap(8),
                  ...meaning.examples.map((e) {
                    final translation = e.targetSentence?.trim();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.sourceSentence,
                            style: theme.typography.body.sm.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.35,
                            ),
                          ),
                          if (translation != null && translation.isNotEmpty)
                            Text(
                              translation,
                              style: theme.typography.body.sm.copyWith(
                                color: theme.colors.mutedForeground,
                                height: 1.35,
                              ),
                            ),
                          const Gap(6),
                          PronunciationSection(
                            wordId: wordId,
                            languageId: languageId,
                            audios: e.audios,
                            exampleId: e.id,
                            compact: true,
                            sectionLabel: l10n.dictExampleAudio,
                            spokenText: e.sourceSentence,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
                if (byLabel != null) ...[
                  const Gap(8),
                  Semantics(
                    button: true,
                    label: byLabel,
                    child: FTappable(
                      onPress: () =>
                          UserProfileRouter.open(context, username!),
                      child: Text(
                        byLabel,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ],
                const Gap(8),
                MeaningVoteRow(meaningId: meaning.id),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: l10n.dictMeaningActionsTitle,
            onPressed: () => _showMeaningActionsSheet(
              context,
              ref,
              wordId: wordId,
              lemma: lemma,
              meaning: meaning,
              meaningCount: meaningCount,
            ),
            icon: Icon(
              FLucideIcons.ellipsisVertical,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedChipWrap extends StatelessWidget {
  const _RelatedChipWrap({required this.items});

  final List<RelatedWord> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final related in items)
          FTappable(
            onPress: () => context.push('/words/${related.wordId}'),
            child: FBadge(
              variant: FBadgeVariant.secondary,
              child: Text(related.lemma),
            ),
          ),
      ],
    );
  }
}

class _MeaningGroupChipWrap extends StatelessWidget {
  const _MeaningGroupChipWrap({required this.members});

  final List<MeaningGroupMember> members;

  @override
  Widget build(BuildContext context) {
    final withNotes = members.any(
      (m) => m.notes != null && m.notes!.trim().isNotEmpty,
    );
    if (withNotes) {
      return Column(
        children: [for (final m in members) _MeaningGroupRow(member: m)],
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final member in members)
          FTappable(
            onPress: () => context.push('/words/${member.wordId}'),
            child: FBadge(
              variant: FBadgeVariant.secondary,
              child: Text(member.lemma),
            ),
          ),
      ],
    );
  }
}

class _MeaningGroupRow extends StatelessWidget {
  const _MeaningGroupRow({required this.member});

  final MeaningGroupMember member;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final notes = member.notes;
    return GestureDetector(
      onTap: () => context.push('/words/${member.wordId}'),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.lemma,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (notes != null && notes.isNotEmpty)
                    Text(
                      notes,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                ],
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
      if (!variant.isSpellingVariant)
        variantTypeLabel(variant.variantType, AppLocalizations.of(context)),
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
                style: theme.typography.body.sm.copyWith(
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
    PaintingEffect shimmerResolver(Brightness brightness) => ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    // Mirror struktur [_DetailBody]: lemma + thumb → makna → atribusi.
    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effectResolver: shimmerResolver),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
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
                                AppLocalizations.of(context).dictSkeletonLemma,
                                style: theme.typography.body.xl.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                '/ma.kan/',
                                style: GoogleFonts.charisSil(
                                  fontSize: theme.typography.body.sm.fontSize,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.italic,
                                  height: 1.3,
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                              const Gap(6),
                              Text(
                                AppLocalizations.of(
                                  context,
                                ).dictSkeletonWordClass,
                                style: theme.typography.body.sm.copyWith(
                                  color: theme.colors.mutedForeground,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        Bone(
                          width: 72,
                          height: 72,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ],
                    ),
                    const Gap(12),
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
                    const Gap(20),
                    _SectionLabel(
                      AppLocalizations.of(context).reviewEntityMeaning,
                    ),
                    const Gap(8),
                    const _MeaningSkeletonBlock(index: 1),
                    const _MeaningSkeletonBlock(index: 2),
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
              style: theme.typography.body.sm.copyWith(
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
                  AppLocalizations.of(context).dictSkeletonWordClass,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.primary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).dictSkeletonDefinition,
                  style: theme.typography.body.sm.copyWith(height: 1.35),
                ),
                const Gap(4),
                Text(
                  '→ terjemahan contoh',
                  style: theme.typography.body.sm.copyWith(
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

class _AttributionLine extends StatelessWidget {
  const _AttributionLine({
    required this.label,
    required this.username,
    this.showCheck = false,
  });

  final String label;
  final String username;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final tappable = isLinkablePublicUsername(username);
    final textStyle = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w500,
    );
    return Semantics(
      button: tappable,
      label: showCheck ? '$label, Verifikator' : label,
      child: GestureDetector(
        onTap: tappable
            ? () => UserProfileRouter.open(context, username)
            : null,
        child: Text.rich(
          TextSpan(
            style: textStyle,
            children: _attributionSpans(label, showCheck: showCheck),
          ),
        ),
      ),
    );
  }
}

/// Kalimat atribusi + centang. Menggantikan chip teks "Verifikator".
List<InlineSpan> _attributionSpans(String label, {required bool showCheck}) {
  return [
    TextSpan(text: label),
    if (showCheck)
      const WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Padding(
          padding: EdgeInsets.only(left: 4),
          child: VerifiedBadgeIcon(size: 14),
        ),
      ),
  ];
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
                        AppLocalizations.of(sheetContext).dictAttribution,
                        style: theme.typography.body.lg.copyWith(
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
                if (combinedAttributionLabel(
                      detail,
                      AppLocalizations.of(context),
                    ) !=
                    null)
                  Text.rich(
                    TextSpan(
                      style: theme.typography.body.sm,
                      children: _attributionSpans(
                        combinedAttributionLabel(
                          detail,
                          AppLocalizations.of(context),
                        )!,
                        showCheck: detail.combinedByVerifier,
                      ),
                    ),
                  )
                else ...[
                  if (creatorAttributionLabel(
                        detail,
                        AppLocalizations.of(context),
                      ) !=
                      null)
                    Text.rich(
                      TextSpan(
                        style: theme.typography.body.sm,
                        children: _attributionSpans(
                          creatorAttributionLabel(
                            detail,
                            AppLocalizations.of(context),
                          )!,
                          showCheck: isVerifierRole(detail.createdBy!.role),
                        ),
                      ),
                    ),
                  if (verifierAttributionLabel(
                        detail,
                        AppLocalizations.of(context),
                      ) !=
                      null) ...[
                    const Gap(4),
                    Text.rich(
                      TextSpan(
                        style: theme.typography.body.sm,
                        children: _attributionSpans(
                          verifierAttributionLabel(
                            detail,
                            AppLocalizations.of(context),
                          )!,
                          showCheck: isVerifierRole(detail.verifiedBy!.role),
                        ),
                      ),
                    ),
                  ],
                ],
                if (verifiedAt.isNotEmpty) ...[
                  const Gap(4),
                  Text(
                    verifiedAt,
                    style: theme.typography.body.sm.copyWith(
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
                          ? AppLocalizations.of(sheetContext).dictSeeProfile
                          : AppLocalizations.of(
                              sheetContext,
                            ).dictProfileOf(username),
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
