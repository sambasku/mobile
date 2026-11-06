import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import '../review_labels.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/gestures/swipe_exempt.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/reference/reference_data.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../../domain/review_access.dart';
import '../../review_router.dart';
import '../providers/review_providers.dart';
import '../providers/review_submit_queue.dart';
import '../widgets/reject_reason_sheet.dart';
import '../widgets/review_correct_form.dart';
import '../widgets/review_entity_preview.dart';
import '../widgets/review_swipe_card.dart';
import 'review_forbidden_page.dart';

/// Aksi yang memblokir gesture (correct form saja).
/// Approve/reject optimistic - tidak pakai pending busy penuh.
enum ReviewPendingAction { correct }

/// Sesi tinjau satu layar: preview + aksi + koreksi inline, auto-advance.
class ReviewSessionPage extends ConsumerStatefulWidget {
  const ReviewSessionPage({
    super.key,
    this.startId,
    this.wordId,
    this.openCorrect = false,
  });

  final String? startId;
  final String? wordId;
  final bool openCorrect;

  @override
  ConsumerState<ReviewSessionPage> createState() => _ReviewSessionPageState();
}

class _ReviewSessionPageState extends ConsumerState<ReviewSessionPage> {
  ReviewPendingAction? _pendingAction;
  bool _correctMode = false;
  bool _bootstrapped = false;
  String? _formKeyId;

  bool get _busy => _pendingAction != null;

  ReviewQueueQuery get _query => ReviewQueueQuery(wordId: widget.wordId);

  @override
  void initState() {
    super.initState();
    _correctMode = widget.openCorrect;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    // Panaskan data referensi (kelas kata, bahasa) sebelum kartu pertama
    // dirender supaya preview tidak sempat menampilkan id mentah.
    prefetchReferenceData(ref);

    final session = ref.read(reviewSessionProvider);
    final startId = widget.startId;

    if (session != null && (startId == null || session.ids.contains(startId))) {
      if (startId != null && session.currentId != startId) {
        final index = session.ids.indexOf(startId);
        if (index >= 0) {
          ref
              .read(reviewSessionProvider.notifier)
              .start(
                ids: session.ids,
                index: index,
                query: session.query,
                hasMore: session.hasMore,
                nextCursor: session.nextCursor,
              );
        }
      }
      return;
    }

    final queue = ref.read(reviewQueueProvider(_query)).value;
    if (queue != null && queue.items.isNotEmpty) {
      ref
          .read(reviewSessionProvider.notifier)
          .startFromQueue(queue, query: _query, startId: startId);
      return;
    }

    if (startId != null) {
      await ref
          .read(reviewSessionProvider.notifier)
          .startWithId(startId, query: _query);
      return;
    }

    // Tunggu antrean lalu mulai dari awal.
    try {
      final loaded = await ref.read(reviewQueueProvider(_query).future);
      if (!mounted) return;
      if (loaded.items.isEmpty) {
        _exitToQueue(refresh: false);
        return;
      }
      ref
          .read(reviewSessionProvider.notifier)
          .startFromQueue(loaded, query: _query);
    } catch (_) {
      if (!mounted) return;
      _exitToQueue(refresh: true);
    }
  }

  void _exitToQueue({required bool refresh}) {
    ref.read(reviewSessionProvider.notifier).clear();
    if (refresh) invalidateReviewQueue(ref);
    // pop menjaga history Profil di bawah antrean; go hanya untuk
    // cold/deep-link tanpa stack (system back tidak boleh menutup app).
    if (context.canPop()) {
      context.pop();
      return;
    }
    final path = widget.wordId != null
        ? ReviewRouter.queuePath(wordId: widget.wordId)
        : ReviewRouter.queue.path;
    context.go(path);
  }

  void _onBack() {
    if (_correctMode) {
      setState(() => _correctMode = false);
      return;
    }
    _exitToQueue(refresh: false);
  }

  /// System back = logika app bar yang sama; cegah Activity finish.
  Widget _guardBack(Widget child) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: child,
    );
  }

  Future<void> _afterDecision(String message, String contributionId) async {
    setState(() {
      _correctMode = false;
      _pendingAction = null;
    });
    showFToast(context: context, title: Text(message));
    final hasNext = await ref
        .read(reviewSessionProvider.notifier)
        .advanceAfterDecision(contributionId);
    if (!mounted) return;
    if (!hasNext) {
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).reviewSessionQueueDone),
      );
      _exitToQueue(refresh: true);
    }
  }

  Future<void> _afterSkip(String contributionId) async {
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).reviewSessionSkipped),
    );
    AnalyticsService.instance.log(
      AnalyticsEvents.reviewSkip,
      params: {'contribution_id': contributionId},
    );
    final hasNext = await ref
        .read(reviewSessionProvider.notifier)
        .skipCurrent();
    if (!mounted) return;
    if (!hasNext) {
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).reviewSessionQueueDone),
      );
      _exitToQueue(refresh: true);
    }
  }

  /// `true` = kartu keluar / advance; `false` = kembalikan kartu.
  Future<bool> _approve(ReviewDetail detail) async {
    if (_busy || _correctMode) return false;
    final id = detail.contribution.id;
    AnalyticsService.instance.log(
      AnalyticsEvents.reviewApprove,
      params: {'contribution_id': id},
    );
    ref.read(reviewSubmitQueueProvider.notifier).enqueueApprove(id);
    // Jangan await: swipe harus return segera; advance sync di hot path.
    final l10n = AppLocalizations.of(context);
    _afterDecision(
      detail.wordAlreadyVerified
          ? l10n.reviewSessionQueueClosedToast
          : l10n.reviewSessionApprovedToast,
      id,
    );
    return true;
  }

  /// `true` = ditolak / advance; `false` = batal alasan.
  Future<bool> _reject(ReviewDetail detail) async {
    if (_busy || _correctMode) return false;
    final comment = await _askRejectReason();
    if (comment == null || !mounted) return false;
    final id = detail.contribution.id;
    AnalyticsService.instance.log(
      AnalyticsEvents.reviewReject,
      params: {'contribution_id': id},
    );
    ref
        .read(reviewSubmitQueueProvider.notifier)
        .enqueueReject(id, comment: comment);
    _afterDecision(AppLocalizations.of(context).reviewSessionRejectedToast, id);
    return true;
  }

  Future<bool> _onSwiped(ReviewDetail detail, ReviewSwipeDirection direction) {
    return switch (direction) {
      ReviewSwipeDirection.approve => _approve(detail),
      ReviewSwipeDirection.reject =>
        detail.wordAlreadyVerified
            ? Future<bool>.value(false)
            : _reject(detail),
      ReviewSwipeDirection.skip => _skip(detail),
    };
  }

  Future<bool> _skip(ReviewDetail detail) async {
    if (_busy || _correctMode) return false;
    await _afterSkip(detail.contribution.id);
    return true;
  }

  void _onSubmitQueueFailure(ReviewSubmitQueueState next) {
    final id = next.failedContributionId;
    if (id == null) return;

    if (next.failedIsAlreadyDecided) {
      // Sudah diputus orang lain - kartu tetap di-drop, cukup info.
      showFToast(
        context: context,
        title: Text(
          next.errorMessage ??
              AppLocalizations.of(context).reviewSessionAlreadyProcessed,
        ),
      );
      return;
    }

    if (next.failedIsForbidden) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReviewForbiddenPage(
            message:
                next.errorMessage ??
                AppLocalizations.of(context).reviewSessionAccessDenied,
          ),
        ),
      );
      return;
    }

    ref.read(reviewSessionProvider.notifier).reinsertAtFront(id);
    showFToast(
      context: context,
      title: Text(
        next.errorMessage ??
            AppLocalizations.of(context).reviewSessionSaveFailed,
      ),
      variant: FToastVariant.destructive,
    );
  }

  Future<void> _rewindSkip() async {
    if (_busy) return;
    final ok = await ref.read(reviewSessionProvider.notifier).rewindSkip();
    if (!mounted) return;
    if (!ok) {
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).reviewSessionRestoreFailed),
        variant: FToastVariant.destructive,
      );
      return;
    }
    setState(() => _correctMode = false);
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).reviewSessionRestoredToast),
    );
  }

  Future<String?> _askRejectReason() {
    return showRejectReasonSheet(context);
  }

  /// `true` = sesi lanjut (forbidden / already decided); `false` = tetap di kartu.
  bool _onFailure(ReviewFailure failure, String contributionId) {
    if (failure.isForbidden) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReviewForbiddenPage(message: failure.message),
        ),
      );
      return true;
    }
    if (failure.isAlreadyDecided) {
      // Satu toast via _afterDecision - jangan dobel dengan toast terpisah.
      _afterDecision(
        AppLocalizations.of(context).reviewSessionAlreadyProcessed,
        contributionId,
      );
      return true;
    }
    showFToast(
      context: context,
      title: Text(failure.message),
      variant: FToastVariant.destructive,
    );
    return false;
  }

  void _onCorrectSuccess(ReviewDetail detail, ReviewDecisionResult decision) {
    AnalyticsService.instance.log(
      AnalyticsEvents.reviewCorrect,
      params: {'contribution_id': detail.contribution.id},
    );
    if (decision.status == 'pending') {
      // publish=false: tetap di item yang sama, kembali ke mode lihat.
      ref.invalidate(reviewDetailProvider(detail.contribution.id));
      setState(() => _correctMode = false);
      showFToast(
        context: context,
        title: Text(
          AppLocalizations.of(context).reviewSessionCorrectionSavedPending,
        ),
      );
      return;
    }
    setState(() => _pendingAction = ReviewPendingAction.correct);
    _afterDecision(
      AppLocalizations.of(context).reviewSessionCorrectionSavedClosed,
      detail.contribution.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(reviewSessionProvider);
    final currentId = session?.currentId;

    if (session == null || currentId == null) {
      return _guardBack(
        FScaffold(
          header: FHeader.nested(
            title: Text(AppLocalizations.of(context).commonVerifierArea),
            prefixes: [FHeaderAction.back(onPress: _onBack)],
          ),
          child: const Center(child: FCircularProgress()),
        ),
      );
    }

    final detailAsync = ref.watch(reviewDetailProvider(currentId));
    final failure = detailAsync.hasError ? detailAsync.error : null;
    if (failure is ReviewFailure && failure.isForbidden) {
      return ReviewForbiddenPage(message: failure.message);
    }

    final pending = detailAsync.asData?.value.contribution.isPending ?? false;
    final title = _correctMode
        ? AppLocalizations.of(
            context,
          ).reviewSessionCounterCorrect(session.position, session.total)
        : AppLocalizations.of(
            context,
          ).reviewSessionCounter(session.position, session.total);

    ref.listen(reviewSubmitQueueProvider, (prev, next) {
      if (next.errorSeq == 0) return;
      if (prev != null && prev.errorSeq == next.errorSeq) return;
      if (!mounted) return;
      _onSubmitQueueFailure(next);
    });

    // Prefetch 1-2 kartu ke depan tetap di-watch supaya autoDispose tidak
    // membuang hasil sebelum advance (ganti kartu tanpa cold loading).
    final nextId = session.nextId;
    if (nextId != null) {
      ref.watch(reviewDetailProvider(nextId));
    }
    final afterNext = session.index + 2;
    if (afterNext >= 0 && afterNext < session.ids.length) {
      ref.watch(reviewDetailProvider(session.ids[afterNext]));
    }

    return _guardBack(
      FScaffold(
        childPad: true,
        header: FHeader.nested(
          title: Text(title),
          prefixes: [FHeaderAction.back(onPress: _onBack)],
        ),
        footer: pending && !_correctMode
            ? detailAsync.maybeWhen(
                data: (detail) => ReviewSessionActionBar(
                  pendingAction: _pendingAction,
                  canCorrect: correctableEntityTypes.contains(
                    detail.contribution.entityType,
                  ),
                  canRewind: session.canRewind,
                  closeQueue: detail.wordAlreadyVerified,
                  onApprove: () => _approve(detail),
                  onCorrect: () => setState(() {
                    _formKeyId = detail.contribution.id;
                    _correctMode = true;
                  }),
                  onReject: () => _reject(detail),
                  onSkip: () => _skip(detail),
                  onRewind: _rewindSkip,
                ),
                orElse: () => null,
              )
            : null,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: detailAsync.when(
            loading: () =>
                const _ReviewCardPlaceholder(key: ValueKey('loading')),
            error: (error, _) => Center(
              key: const ValueKey('error'),
              child: Text(
                error is ReviewFailure
                    ? error.message
                    : AppLocalizations.of(context).commonLoadFailed,
              ),
            ),
            data: (detail) {
              if (_correctMode) {
                return ReviewCorrectForm(
                  key: ValueKey(_formKeyId ?? detail.contribution.id),
                  detail: detail,
                  onCancel: () => setState(() => _correctMode = false),
                  onSuccess: (decision) => _onCorrectSuccess(detail, decision),
                  onFailure: (failure) =>
                      _onFailure(failure, detail.contribution.id),
                );
              }
              final canSwipe = detail.contribution.isPending && !_busy;
              return Padding(
                key: ValueKey('card-${detail.contribution.id}'),
                padding: const EdgeInsets.only(top: 20, bottom: 16),
                child: ReviewSwipeCard(
                  itemKey: detail.contribution.id,
                  enabled: canSwipe,
                  positiveLabel: detail.wordAlreadyVerified
                      ? AppLocalizations.of(context).reviewSessionCloseQueue
                      : null,
                  allowReject: !detail.wordAlreadyVerified,
                  onSwiped: (direction) => _onSwiped(detail, direction),
                  child: _ReviewViewBody(detail: detail),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void _showProposalInfo(BuildContext context, ReviewDetail detail) {
  final l10n = AppLocalizations.of(context);
  final item = detail.contribution;
  final when = formatDateTimeIso(item.createdAt);
  final rawNotes = item.entityType == 'word'
      ? detail.entity['notes']?.toString().trim()
      : null;
  final notes = (rawNotes == null || rawNotes.isEmpty) ? null : rawNotes;

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      return Padding(
        padding: MediaQuery.viewInsetsOf(sheetContext),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.reviewSessionProposalInfo,
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(12),
                FTileGroup(
                  children: [
                    FTile(
                      title: Text(l10n.reviewSessionInfoKind),
                      subtitle: Text(reviewEntityLabel(item.entityType, l10n)),
                    ),
                    FTile(
                      title: Text(l10n.reviewSessionInfoContributor),
                      subtitle: Text(
                        item.contributorLabel ?? l10n.reviewContributorFallback,
                      ),
                    ),
                    if (when.isNotEmpty)
                      FTile(
                        title: Text(l10n.reviewSessionInfoSubmitted),
                        subtitle: Text(when),
                      ),
                    if (notes != null)
                      FTile(
                        title: Text(l10n.historyFieldNotes),
                        subtitle: Text(notes),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _ReviewViewBody extends StatelessWidget {
  const _ReviewViewBody({required this.detail});

  final ReviewDetail detail;

  @override
  Widget build(BuildContext context) {
    final item = detail.contribution;
    final l10n = AppLocalizations.of(context);
    // Column (bukan ListView): deck Tinder-like harus bebas gesture swipe,
    // termasuk atas = lewati. Overflow di-clip oleh kartu.
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.body.xl.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Gap(8),
              SwipeExemptRegion(
                child: FButton.icon(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  semanticsLabel: l10n.reviewSessionProposalInfo,
                  onPress: () => _showProposalInfo(context, detail),
                  child: const Icon(FLucideIcons.info),
                ),
              ),
            ],
          ),
          if (detail.wordAlreadyVerified) ...[
            const Gap(14),
            VerifiedQueueNotice(
              message: detail.verifierUsername == null
                  ? l10n.reviewSessionVerifiedSelf
                  : l10n.reviewSessionVerifiedBy(detail.verifierUsername!),
            ),
          ],
          const Gap(10),
          Expanded(
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                child: ReviewEntityPreview(detail: detail, scrollable: false),
              ),
            ),
          ),
          if (!item.isPending &&
              (detail.reviewComment?.trim().isNotEmpty ?? false)) ...[
            const Gap(16),
            _SectionNote(
              title: l10n.reviewSessionVerifierNote,
              body: detail.reviewComment!,
            ),
          ],
        ],
      ),
    );
  }
}

/// Banner "sudah terverifikasi" di kartu tinjau.
///
/// [FAlert] menaruh ikon di tengah tinggi teks. Di sini ikon duduk di
/// kiri atas, sejajar baris pertama (#239).
class VerifiedQueueNotice extends StatelessWidget {
  const VerifiedQueueNotice({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.alertStyles.resolve({
      FAlertVariant.primary,
      context.platformVariant,
    });
    return DecoratedBox(
      decoration: style.decoration,
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Padding(
          padding: style.padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconTheme(
                data: style.iconStyle,
                child: context.theme.icons.circleAlert(context),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: DefaultTextStyle.merge(
                    style: style.titleTextStyle,
                    child: Text(message),
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

/// Kerangka kartu saat detail berikutnya masih dimuat (skeletonizer, bukan spinner penuh).
class _ReviewCardPlaceholder extends StatelessWidget {
  const _ReviewCardPlaceholder({super.key});

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

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colors.border),
        ),
        child: SkeletonizerConfig(
          data: SkeletonizerConfigData(effectResolver: shimmerResolver),
          child: IgnorePointer(
            child: Skeletonizer(
              enabled: true,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Text(
                    AppLocalizations.of(context).reviewSessionSkeletonTitle,
                    style: theme.typography.body.xl.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        icon: FLucideIcons.layers,
                        label: AppLocalizations.of(
                          context,
                        ).reviewSessionEntryType,
                      ),
                      _MetaChip(
                        icon: FLucideIcons.chevronDown,
                        label: AppLocalizations.of(
                          context,
                        ).suggestWordClassLabelShort,
                      ),
                    ],
                  ),
                  const Gap(10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.muted.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).reviewSessionSkeletonSection,
                          ),
                          Gap(10),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).reviewSessionSkeletonBody,
                          ),
                          Gap(8),
                          Text(
                            AppLocalizations.of(
                              context,
                            ).reviewSessionSkeletonMeta,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: theme.colors.mutedForeground),
            const Gap(6),
            Text(
              label,
              style: theme.typography.body.xs.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionNote extends StatelessWidget {
  const _SectionNote({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(6),
            Text(body, style: theme.typography.body.sm),
          ],
        ),
      ),
    );
  }
}

/// Sticky action bar: Koreksi, undo, lewati, tolak, setuju.
///
/// [closeQueue]: kata sudah terverifikasi. Tombol kanan jadi "Tutup antrean".
class ReviewSessionActionBar extends StatelessWidget {
  const ReviewSessionActionBar({
    super.key,
    required this.pendingAction,
    required this.canCorrect,
    required this.canRewind,
    required this.onApprove,
    required this.onCorrect,
    required this.onReject,
    required this.onSkip,
    required this.onRewind,
    this.closeQueue = false,
  });

  final ReviewPendingAction? pendingAction;
  final bool canCorrect;
  final bool canRewind;

  /// Kata sudah terverifikasi: aksi kanan menutup antrean.
  final bool closeQueue;
  final VoidCallback onApprove;
  final VoidCallback onCorrect;
  final VoidCallback onReject;
  final VoidCallback onSkip;
  final VoidCallback onRewind;

  bool get _busy => pendingAction != null;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              if (closeQueue) const Spacer(),
              if (canCorrect && closeQueue) ...[
                FButton.icon(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  semanticsLabel: AppLocalizations.of(
                    context,
                  ).reviewSessionCorrect,
                  onPress: _busy ? null : onCorrect,
                  child: const Icon(FLucideIcons.pencil),
                ),
                const Gap(8),
              ] else if (canCorrect) ...[
                Expanded(
                  child: FButton(
                    variant: FButtonVariant.outline,
                    size: FButtonSizeVariant.sm,
                    onPress: _busy ? null : onCorrect,
                    prefix: const Icon(FLucideIcons.pencil),
                    child: Text(
                      AppLocalizations.of(context).reviewSessionCorrect,
                    ),
                  ),
                ),
                const Gap(8),
              ] else if (!closeQueue)
                const Spacer(),
              FButton.icon(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                semanticsLabel: AppLocalizations.of(context).reviewSessionBack,
                onPress: _busy || !canRewind ? null : onRewind,
                child: const Icon(FLucideIcons.undo),
              ),
              const Gap(8),
              FButton.icon(
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.sm,
                semanticsLabel: AppLocalizations.of(context).commonSkip,
                onPress: _busy ? null : onSkip,
                child: const Icon(FLucideIcons.skipForward),
              ),
              const Gap(12),
              // Tolak / setuju: check/x (bukan ↑↓ vote).
              // Kata yang sudah terverifikasi: tutup antrean. Tolak
              // disembunyikan karena keputusan itu menolak kata yang tayang.
              if (!closeQueue) ...[
                FButton.icon(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  semanticsLabel: AppLocalizations.of(context).commonReject,
                  onPress: _busy ? null : onReject,
                  child: Icon(FLucideIcons.x, color: theme.colors.destructive),
                ),
                const Gap(4),
              ],
              if (closeQueue)
                FButton(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  semanticsLabel: AppLocalizations.of(
                    context,
                  ).reviewSessionCloseQueue,
                  onPress: _busy ? null : onApprove,
                  child: Text(
                    AppLocalizations.of(context).reviewSessionCloseQueueButton,
                  ),
                )
              else
                FButton.icon(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  semanticsLabel: AppLocalizations.of(context).commonApprove,
                  onPress: _busy ? null : onApprove,
                  child: Icon(FLucideIcons.check, color: theme.colors.success),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
