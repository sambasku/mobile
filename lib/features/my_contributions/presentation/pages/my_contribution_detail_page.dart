import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../dictionary/domain/failures/dictionary_failure.dart';
import '../../../dictionary/presentation/providers/word_detail_providers.dart';
import '../../domain/entities/my_submission.dart';
import '../../domain/failures/my_contribution_failure.dart';
import '../providers/my_contributions_providers.dart';

/// Detail satu usulan milik user - GET /api/v1/contributions/my/:kind/:id.
class MyContributionDetailPage extends ConsumerWidget {
  const MyContributionDetailPage({
    super.key,
    required this.kind,
    required this.id,
  });

  final String kind;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myContributionDetailProvider(kind, id));
    final item = async.asData?.value;
    final wordId = item != null && item.canOpenWord ? item.wordId : null;
    final word = wordId == null ? null : ref.watch(wordDetailProvider(wordId));
    final wordMissing = word != null &&
        word.hasError &&
        word.error is DictionaryFailure &&
        (word.error! as DictionaryFailure).errorCode == 'WORD_NOT_FOUND';
    final showOpenWord = wordId != null && word != null && !word.isLoading && !wordMissing;

    return FScaffold(
      childPad: true,
      footer: !showOpenWord
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: FButton(
                  onPress: () => context.push('/words/$wordId'),
                  child: const Text('Buka kata'),
                ),
              ),
            ),
      header: FHeader.nested(
        title: Text(
          async.maybeWhen(data: (d) => d.displayTitle, orElse: () => 'Usulan'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.hasError
          ? _ErrorState(
              failure: async.error is MyContributionFailure
                  ? async.error! as MyContributionFailure
                  : MyContributionFailure(async.error.toString()),
              onRetry: () =>
                  ref.invalidate(myContributionDetailProvider(kind, id)),
            )
          : async.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (_, _) => const SizedBox.shrink(),
              data: (item) => _DetailBody(item: item),
            ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.failure, required this.onRetry});

  final MyContributionFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              failure.isNotFound
                  ? FLucideIcons.searchX
                  : FLucideIcons.circleAlert,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              failure.isNotFound ? 'Usulan tidak ditemukan' : failure.message,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            if (!failure.isNotFound) ...[
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: onRetry,
                child: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.item});

  final MySubmission item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final created = formatDateTimeIso(item.createdAt);
    final reviewed = formatDateTimeIso(item.reviewedAt);
    final comment = item.reviewComment?.trim();
    final reason = item.reason?.trim();
    final reasonCode = item.reasonCode?.trim();

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      children: [
        FTileGroup(
          children: [
            FTile(
              title: const Text('Status'),
              subtitle: Text(
                item.statusLabel,
                style: TextStyle(
                  color: switch (item.status) {
                    'approved' => context.theme.colors.success,
                    'rejected' => context.theme.colors.destructive,
                    'corrected' => context.theme.colors.primary,
                    _ => context.theme.colors.warning,
                  },
                  fontWeight: FontWeight.w600,
                ),
              ),
              prefix: item.isPendingReview
                  ? Semantics(
                      button: true,
                      label: 'Menunggu pengecekan',
                      child: GestureDetector(
                        onTap: () => showPendingReviewInfo(context),
                        child: const PendingReviewBadgeIcon(size: 16),
                      ),
                    )
                  : null,
            ),
            FTile(title: const Text('Jenis'), subtitle: Text(item.kindLabel)),
            if (created.isNotEmpty)
              FTile(title: const Text('Dikirim'), subtitle: Text(created)),
            if (reviewed.isNotEmpty)
              FTile(title: const Text('Ditinjau'), subtitle: Text(reviewed)),
            if (item.action != null && item.action!.isNotEmpty)
              FTile(title: const Text('Aksi'), subtitle: Text(item.action!)),
            if (reasonCode != null && reasonCode.isNotEmpty)
              FTile(
                title: const Text('Kode alasan'),
                subtitle: Text(reasonCode),
              ),
            if (reason != null && reason.isNotEmpty)
              FTile(
                title: const Text('Alasan perubahan'),
                subtitle: Text(reason),
              ),
            if (comment != null && comment.isNotEmpty)
              FTile(
                title: const Text('Catatan reviewer'),
                subtitle: Text(comment),
              ),
          ],
        ),
      ],
    );
  }
}
