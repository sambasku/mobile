import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../domain/entities/word_suggestion_review.dart';
import '../../domain/failures/review_failure.dart';
import '../providers/review_suggestions_providers.dart';

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
        title: const Text('Detail usulan edit'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (error, _) => Center(
          child: Text(
            error is ReviewFailure ? error.message : 'Gagal memuat detail',
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
          title: const Text('Usulan disetujui'),
        );
        context.pop();
      },
    );
  }

  Future<void> _reject() async {
    if (_busy || !detail.isPending) return;
    final controller = TextEditingController();
    final comment = await showFDialog<String>(
      context: context,
      builder: (dialogContext, style, animation) {
        return FDialog(
          style: style,
          animation: animation,
          title: const Text('Tolak usulan'),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Berikan alasan penolakan untuk kontributor.'),
              const Gap(12),
              FTextField(
                control: FTextFieldControl.managed(controller: controller),
                label: const Text('Alasan'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            FButton(
              onPress: () {
                final text = controller.text.trim();
                if (text.isEmpty) return;
                Navigator.of(dialogContext).pop(text);
              },
              child: const Text('Tolak'),
            ),
          ],
        );
      },
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
          title: const Text('Usulan ditolak'),
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
          style: theme.typography.xl.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(4),
        Text(
          'Dari ${detail.contributorLabel} · ${formatDateTimeIso(detail.createdAt)}',
          style: theme.typography.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        const Gap(12),
        Text(
          'Alasan: ${detail.reason}',
          style: theme.typography.sm,
        ),
        const Gap(20),
        Text(
          'Perbandingan',
          style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        if (detail.lemmaDiff.changed)
          _DiffRow(
            label: 'Lemma',
            current: detail.lemmaDiff.current,
            proposed: detail.lemmaDiff.proposed,
          ),
        if (detail.notesDiff.changed)
          _DiffRow(
            label: 'Catatan',
            current: detail.notesDiff.current,
            proposed: detail.notesDiff.proposed,
          ),
        if (detail.meaningsChanged > 0)
          _CountRow(label: 'Makna', count: detail.meaningsChanged),
        if (detail.categoriesAdded > 0 || detail.categoriesRemoved > 0)
          _CountRow(
            label: 'Kategori',
            count: detail.categoriesAdded + detail.categoriesRemoved,
            detail:
                '+${detail.categoriesAdded} / -${detail.categoriesRemoved}',
          ),
        if (detail.relationsAdded > 0 || detail.relationsRemoved > 0)
          _CountRow(
            label: 'Relasi',
            count: detail.relationsAdded + detail.relationsRemoved,
            detail: '+${detail.relationsAdded} / -${detail.relationsRemoved}',
          ),
        if (detail.variantsAdded > 0 || detail.variantsRemoved > 0)
          _CountRow(
            label: 'Varian',
            count: detail.variantsAdded + detail.variantsRemoved,
            detail: '+${detail.variantsAdded} / -${detail.variantsRemoved}',
          ),
        if (detail.imagesAdded > 0 || detail.imagesRemoved > 0)
          _CountRow(
            label: 'Gambar',
            count: detail.imagesAdded + detail.imagesRemoved,
            detail: '+${detail.imagesAdded} / -${detail.imagesRemoved}',
          ),
        if (!detail.lemmaDiff.changed &&
            !detail.notesDiff.changed &&
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
            'Tidak ada diff ringkas',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        const Gap(24),
        if (detail.isPending) ...[
          if (detail.imagesAdded > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Setujui akan mempromosikan semua gambar staging (ImageKit) ke GitHub. Sensor/tolak per gambar hanya di console.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          FButton(
            onPress: _busy ? null : _approve,
            child: Text(_busy ? 'Memproses...' : 'Setujui'),
          ),
          const Gap(8),
          FButton(
            variant: FButtonVariant.outline,
            onPress: _busy ? null : _reject,
            child: const Text('Tolak'),
          ),
        ] else
          Text(
            'Status: ${detail.status}',
            style: theme.typography.sm.copyWith(
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
            style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(4),
          Text(
            'Sekarang: ${current?.trim().isNotEmpty == true ? current : '-'}',
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          Text(
            'Usulan: ${proposed?.trim().isNotEmpty == true ? proposed : '-'}',
            style: theme.typography.sm,
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
        detail != null ? '$label: $detail' : '$label: $count perubahan',
        style: theme.typography.sm,
      ),
    );
  }
}
