import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../data/repositories/meaning_report_review_repository_impl.dart';
import '../providers/meaning_report_review_providers.dart';
import '../providers/review_suggestions_providers.dart';

class MeaningReportReviewDetailPage extends ConsumerWidget {
  const MeaningReportReviewDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(meaningReportReviewDetailProvider(id));
    final l10n = AppLocalizations.of(context);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.reviewMeaningReportDetailTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) => Center(
          child: Text(
            error is MeaningReportReviewFailure
                ? error.message
                : l10n.commonLoadFailed,
            textAlign: TextAlign.center,
          ),
        ),
        data: (item) => _Body(item: item),
      ),
    );
  }
}

class _Body extends ConsumerStatefulWidget {
  const _Body({required this.item});

  final MeaningReportReviewItem item;

  @override
  ConsumerState<_Body> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_Body> {
  bool _busy = false;

  MeaningReportReviewItem get item => widget.item;

  Future<void> _remove() async {
    if (_busy || item.status != 'open') return;
    setState(() => _busy = true);
    try {
      await ref
          .read(meaningReportReviewRepositoryProvider)
          .removeMeaning(item.id);
      if (!mounted) return;
      ref.read(meaningReportReviewListProvider.notifier).drop(item.id);
      invalidateMeaningReportReview(ref);
      ref.invalidate(reviewHubHasPendingProvider);
      showFToast(
        context: context,
        title: Text(
          AppLocalizations.of(context).reviewMeaningReportRemovedToast,
        ),
      );
      context.pop();
    } on MeaningReportReviewFailure catch (error) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _dismiss() async {
    if (_busy || item.status != 'open') return;
    setState(() => _busy = true);
    try {
      await ref.read(meaningReportReviewRepositoryProvider).dismiss(item.id);
      if (!mounted) return;
      ref.read(meaningReportReviewListProvider.notifier).drop(item.id);
      invalidateMeaningReportReview(ref);
      ref.invalidate(reviewHubHasPendingProvider);
      showFToast(
        context: context,
        title: Text(
          AppLocalizations.of(context).reviewMeaningReportDismissedToast,
        ),
      );
      context.pop();
    } on MeaningReportReviewFailure catch (error) {
      if (!mounted) return;
      await showAppErrorSheet(context, message: error.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final definition = item.meaningDefinition?.trim();
    final reporter = (item.displayName?.trim().isNotEmpty ?? false)
        ? item.displayName!
        : (item.username ?? '-');

    return ListView(
      children: [
        Text(
          item.lemma,
          style: theme.typography.body.lg.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        if (definition != null && definition.isNotEmpty)
          Text(definition, style: theme.typography.body.md.copyWith(height: 1.5)),
        const Gap(12),
        Text(
          '${item.reasonCode} · $reporter',
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        if (item.note != null && item.note!.trim().isNotEmpty) ...[
          const Gap(8),
          Text(item.note!.trim()),
        ],
        if (item.status == 'open') ...[
          const Gap(24),
          FButton(
            onPress: _busy ? null : _remove,
            prefix: _busy ? const FCircularProgress() : null,
            child: Text(l10n.reviewMeaningReportRemove),
          ),
          const Gap(8),
          FButton(
            variant: FButtonVariant.outline,
            onPress: _busy ? null : _dismiss,
            child: Text(l10n.reviewMeaningReportDismiss),
          ),
        ],
      ],
    );
  }
}
