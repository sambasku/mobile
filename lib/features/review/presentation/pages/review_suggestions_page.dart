import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../domain/failures/review_failure.dart';
import '../../review_router.dart';
import '../providers/review_suggestions_providers.dart';

/// Antrean usulan edit kata (GET admin/word-suggestions?status=pending).
class ReviewSuggestionsPage extends ConsumerWidget {
  const ReviewSuggestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final async = ref.watch(reviewSuggestionsListProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Usulan edit'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () => Skeletonizer(
          enabled: true,
          child: ListView(
            children: List.generate(
              6,
              (_) => FTile(
                title: Text('Lemma contoh'),
                subtitle: Text('Ringkasan'),
              ),
            ),
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                error is ReviewFailure
                    ? error.message
                    : 'Gagal memuat usulan edit',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => ref.invalidate(reviewSuggestionsListProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (state) {
          if (state.items.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada usulan edit menunggu',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(reviewSuggestionsListProvider);
              await ref.read(reviewSuggestionsListProvider.future);
            },
            child: ListView.builder(
              itemCount: state.items.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: state.isLoadingMore
                            ? null
                            : () => ref
                                .read(reviewSuggestionsListProvider.notifier)
                                .loadMore(),
                        child: Text(
                          state.isLoadingMore ? 'Memuat...' : 'Muat lagi',
                        ),
                      ),
                    ),
                  );
                }
                final item = state.items[index];
                return FTile(
                  title: Text(item.wordLemma),
                  subtitle: Text(
                    '${item.contributorLabel} · ${item.changeHint} · ${formatDateTimeIso(item.createdAt)}',
                  ),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => context.push(
                    ReviewRouter.suggestionDetailPath(item.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
