import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../../review_router.dart';
import '../providers/review_history_providers.dart';
import '../providers/review_providers.dart';
import '../widgets/review_entity_preview.dart';

/// Detail satu keputusan di riwayat - reopen / unverify / lanjut tinjau.
class ReviewHistoryDetailPage extends ConsumerWidget {
  const ReviewHistoryDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(reviewDetailProvider(id));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Detail keputusan'),
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
        data: (detail) => _HistoryDetailBody(detail: detail),
      ),
    );
  }
}

class _HistoryDetailBody extends ConsumerStatefulWidget {
  const _HistoryDetailBody({required this.detail});

  final ReviewDetail detail;

  @override
  ConsumerState<_HistoryDetailBody> createState() => _HistoryDetailBodyState();
}

class _HistoryDetailBodyState extends ConsumerState<_HistoryDetailBody> {
  bool _busy = false;

  ReviewDetail get detail => widget.detail;

  Future<void> _reopen() async {
    if (_busy) return;
    setState(() => _busy = true);
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.reopen(detail.contribution.id);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) {
        showFToast(
          context: context,
          title: Text(failure.message),
        );
      },
      (_) {
        ref.invalidate(reviewDetailProvider(detail.contribution.id));
        ref.invalidate(reviewHistoryControllerProvider);
        showFToast(
          context: context,
          title: const Text('Keputusan dibuka ulang'),
        );
        context.push(ReviewRouter.sessionPath(startId: detail.contribution.id));
      },
    );
  }

  Future<void> _unverify() async {
    final wordId = detail.wordIdForUnverify;
    if (wordId == null || _busy) return;
    setState(() => _busy = true);
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.unverifyWord(wordId);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (failure) {
        showFToast(
          context: context,
          title: Text(failure.message),
        );
      },
      (_) {
        ref.invalidate(reviewDetailProvider(detail.contribution.id));
        showFToast(
          context: context,
          title: const Text('Verifikasi kata dicabut'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final pending = detail.contribution.isPending;
    final prior = detail.priorReviews;

    return ListView(
      children: [
        Text(
          detail.contribution.title,
          style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(4),
        Text(
          '${reviewStatusLabel(detail.contribution.status)} · ${detail.contribution.contributorLabel}',
          style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
        ),
        const Gap(16),
        ReviewEntityPreview(detail: detail),
        if (prior.isNotEmpty) ...[
          const Gap(16),
          Text(
            'Riwayat keputusan',
            style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(8),
          for (final row in prior) ...[
            Text(
              '${reviewStatusLabel(row.status)} · ${formatDateTimeIso(row.createdAt)}',
              style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
            ),
            if (row.comment != null && row.comment!.trim().isNotEmpty)
              Text(
                row.comment!,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            const Gap(8),
          ],
        ],
        const Gap(20),
        Text(
          pending
              ? 'Usulan ini sedang dibuka ulang. Lanjut tinjau untuk memberi keputusan baru.'
              : 'Buka ulang menahan item dari antrean global sampai ada keputusan baru. Cabut verifikasi hanya menghapus stempel kata.',
          style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
        ),
        const Gap(16),
        if (pending)
          FButton(
            onPress: _busy
                ? null
                : () => context.push(
                    ReviewRouter.sessionPath(startId: detail.contribution.id),
                  ),
            child: const Text('Lanjut tinjau'),
          )
        else ...[
          FButton(
            onPress: _busy ? null : _reopen,
            child: Text(_busy ? 'Memproses...' : 'Buka ulang'),
          ),
          if (detail.wordAlreadyVerified) ...[
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              onPress: _busy ? null : _unverify,
              child: const Text('Cabut verifikasi'),
            ),
          ],
        ],
      ],
    );
  }
}
