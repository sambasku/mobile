import 'package:flutter/widgets.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../domain/entities/word_suggestion_review.dart';
import '../../domain/failures/review_failure.dart';
import '../providers/review_suggestions_providers.dart';
import '../../../../shared/utils/message_dialog.dart';

/// Detail usulan edit + Setujui / Tolak.
class ReviewSuggestionDetailPage extends ConsumerWidget {
  const ReviewSuggestionDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reviewSuggestionDetailProvider(id));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(AppLocalizations.of(context).reviewSuggestionDetailTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) => Center(
          child: Text(
            error is ReviewFailure ? error.message : AppLocalizations.of(context).commonLoadFailed,
            textAlign: TextAlign.center,
          ),
        ),
        data: (detail) => _SuggestionDetailBody(detail: detail),
      ),
    );
  }
}

class _SuggestionDetailBody extends ConsumerStatefulWidget {
  const _SuggestionDetailBody({required this.detail});

  final WordSuggestionDetail detail;

  @override
  ConsumerState<_SuggestionDetailBody> createState() =>
      _SuggestionDetailBodyState();
}

class _SuggestionDetailBodyState extends ConsumerState<_SuggestionDetailBody> {
  bool _busy = false;

  WordSuggestionDetail get detail => widget.detail;

  Future<void> _approve() async {
    if (_busy || !detail.isPending) return;
    setState(() => _busy = true);
    final result = await ref
        .read(wordSuggestionReviewRepositoryProvider)
        .approve(detail.id);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) {
        showFToast(context: context, title: Text(failure.message));
      },
      (_) {
        ref
            .read(reviewSuggestionsListProvider.notifier)
            .drop(detail.id);
        invalidateReviewSuggestions(ref);
        showFToast(
          context: context,
          title: Text(AppLocalizations.of(context).reviewSuggestionApprovedToast),
        );
        context.pop();
      },
    );
  }

  Future<void> _reject() async {
    if (_busy || !detail.isPending) return;
    final controller = TextEditingController();
    final comment = await showFMessageDialog<String>(
      context: context,
      title: Text(AppLocalizations.of(context).reviewSuggestionRejectTitle),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(AppLocalizations.of(context).reviewSuggestionRejectBody),
          Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: controller),
            label: Text(AppLocalizations.of(context).commonReason),
            maxLines: 3,
          ),
        ],
      ),
      actions: (dialogContext) => [
        FButton(
          variant: FButtonVariant.outline,
          onPress: () => Navigator.of(dialogContext).pop(),
          child: Text(AppLocalizations.of(context).commonCancel),
        ),
        FButton(
          onPress: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;
            Navigator.of(dialogContext).pop(text);
          },
          child: Text(AppLocalizations.of(context).commonReject),
        ),
      ],
    );
    controller.dispose();
    if (!mounted || comment == null || comment.trim().isEmpty) return;

    setState(() => _busy = true);
    final result = await ref
        .read(wordSuggestionReviewRepositoryProvider)
        .reject(detail.id, comment: comment.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) {
        showFToast(context: context, title: Text(failure.message));
      },
      (_) {
        ref
            .read(reviewSuggestionsListProvider.notifier)
            .drop(detail.id);
        invalidateReviewSuggestions(ref);
        showFToast(
          context: context,
          title: Text(AppLocalizations.of(context).reviewSuggestionRejectedToast),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ListView(
      children: [
        Text(
          detail.wordLemma,
          style: theme.typography.body.xl.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(4),
        Text(
          AppLocalizations.of(context).reviewSuggestionFrom(detail.contributorLabel ?? '-', formatDateTimeIso(detail.createdAt)),
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(12),
        Text(
          AppLocalizations.of(context).reviewSuggestionReason(detail.reason),
          style: theme.typography.body.sm,
        ),
        const Gap(20),
        Text(
          AppLocalizations.of(context).reviewSuggestionComparison,
          style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        if (detail.lemmaDiff.changed)
          _DiffRow(
            label: AppLocalizations.of(context).historyFieldLemma,
            current: detail.lemmaDiff.current,
            proposed: detail.lemmaDiff.proposed,
          ),
        if (detail.notesDiff.changed)
          _DiffRow(
            label: AppLocalizations.of(context).historyFieldNotes,
            current: detail.notesDiff.current,
            proposed: detail.notesDiff.proposed,
          ),
        if (detail.wordTypeDiff.changed)
          _DiffRow(
            label: AppLocalizations.of(context).reviewSuggestionEntryType,
            current: detail.wordTypeDiff.current,
            proposed: detail.wordTypeDiff.proposed,
          ),
        for (final klass in detail.classDiffs)
          _DiffRow(
            label: AppLocalizations.of(context).suggestWordClassLabelShort,
            current: klass.current,
            proposed: klass.proposed,
          ),
        if (detail.meaningsChanged > 0)
          _CountRow(label: AppLocalizations.of(context).shareSectionMeaning, count: detail.meaningsChanged),
        if (detail.categoriesAdded > 0 || detail.categoriesRemoved > 0)
          _CountRow(
            label: AppLocalizations.of(context).historyFieldCategory,
            count: detail.categoriesAdded + detail.categoriesRemoved,
            detail:
                '+${detail.categoriesAdded} / -${detail.categoriesRemoved}',
          ),
        if (detail.relationsAdded > 0 || detail.relationsRemoved > 0)
          _CountRow(
            label: AppLocalizations.of(context).historyFieldRelation,
            count: detail.relationsAdded + detail.relationsRemoved,
            detail: '+${detail.relationsAdded} / -${detail.relationsRemoved}',
          ),
        if (detail.variantsAdded > 0 || detail.variantsRemoved > 0)
          _CountRow(
            label: AppLocalizations.of(context).historyFieldVariant,
            count: detail.variantsAdded + detail.variantsRemoved,
            detail: '+${detail.variantsAdded} / -${detail.variantsRemoved}',
          ),
        if (detail.imagesAdded > 0 || detail.imagesRemoved > 0)
          _CountRow(
            label: AppLocalizations.of(context).historyFieldImage,
            count: detail.imagesAdded + detail.imagesRemoved,
            detail: '+${detail.imagesAdded} / -${detail.imagesRemoved}',
          ),
        if (!detail.lemmaDiff.changed &&
            !detail.notesDiff.changed &&
            !detail.wordTypeDiff.changed &&
            detail.classDiffs.isEmpty &&
            detail.meaningsChanged == 0 &&
            detail.categoriesAdded == 0 &&
            detail.categoriesRemoved == 0 &&
            detail.relationsAdded == 0 &&
            detail.relationsRemoved == 0 &&
            detail.variantsAdded == 0 &&
            detail.variantsRemoved == 0 &&
            detail.imagesAdded == 0 &&
            detail.imagesRemoved == 0)
          Text(
            AppLocalizations.of(context).reviewSuggestionNoDiff,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        const Gap(24),
        if (detail.isPending) ...[
          if (detail.imagesAdded > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                AppLocalizations.of(context).reviewSuggestionApproveNote,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          FButton(
            variant: FButtonVariant.outline,
            onPress: _busy ? null : _reject,
            child: Text(AppLocalizations.of(context).commonReject),
          ),
          const Gap(8),
          FButton(
            onPress: _busy ? null : _approve,
            child: Text(_busy ? AppLocalizations.of(context).reviewHistoryProcessing : AppLocalizations.of(context).commonApprove),
          ),
        ] else
          Text(
            AppLocalizations.of(context).reviewSuggestionStatus(detail.status),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
      ],
    );
  }
}

class _DiffRow extends StatelessWidget {
  const _DiffRow({
    required this.label,
    this.current,
    this.proposed,
  });

  final String label;
  final String? current;
  final String? proposed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(4),
          Text(
            current?.trim().isNotEmpty == true
          ? AppLocalizations.of(context).reviewSuggestionCurrent(current!)
          : AppLocalizations.of(context).reviewSuggestionCurrentEmpty,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          Text(
            proposed?.trim().isNotEmpty == true
          ? AppLocalizations.of(context).reviewSuggestionProposed(proposed!)
          : AppLocalizations.of(context).reviewSuggestionProposedEmpty,
            style: theme.typography.body.sm,
          ),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.label,
    required this.count,
    this.detail,
  });

  final String label;
  final int count;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        detail != null ? AppLocalizations.of(context).reviewSuggestionDiffValue(label, detail!) : AppLocalizations.of(context).reviewSuggestionDiffCount(label, '$count'),
        style: theme.typography.body.sm,
      ),
    );
  }
}
