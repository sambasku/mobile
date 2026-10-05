import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../domain/entities/word_suggestion_review.dart';
import '../../domain/failures/review_failure.dart';
import '../../review_router.dart';
import '../providers/review_suggestions_providers.dart';

/// Antrean usulan edit kata (GET admin/word-suggestions?status=pending).
///
/// List pakai TileGroupList: autoload saat scroll mendekati ekor,
/// tanpa tombol "Muat lagi".
class ReviewSuggestionsPage extends ConsumerStatefulWidget {
  const ReviewSuggestionsPage({super.key});

  @override
  ConsumerState<ReviewSuggestionsPage> createState() =>
      _ReviewSuggestionsPageState();
}

class _ReviewSuggestionsPageState
    extends ConsumerState<ReviewSuggestionsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final async = ref.watch(reviewSuggestionsListProvider);

    Future<void> refresh() async {
      ref.invalidate(reviewSuggestionsListProvider);
      await ref.read(reviewSuggestionsListProvider.future);
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Usulan edit'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: async.when(
        loading: () {
          final viewportHeight = MediaQuery.sizeOf(context).height;
          final skeletonPerPage = (viewportHeight ~/ 80) + 2;
          return _ListSkeleton(itemCount: skeletonPerPage);
        },
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
            return RefreshIndicator(
              onRefresh: refresh,
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: Center(
                        child: Text(
                          'Tidak ada usulan edit menunggu',
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refresh,
            child: TileGroupList<WordSuggestionSummary>(
              items: state.items,
              hasMore: state.hasMore,
              onLoadMore: () => ref
                  .read(reviewSuggestionsListProvider.notifier)
                  .loadMore(),
              tileBuilder: (context, item) => _SuggestionTile(item: item),
            ),
          );
        },
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget with FTileMixin {
  const _SuggestionTile({required this.item});

  final WordSuggestionSummary item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FTile(
      prefix: Icon(FLucideIcons.pencilLine, color: theme.colors.primary),
      title: Text(item.wordLemma),
      subtitle: Text(
        '${item.contributorLabel} · ${item.changeHint} · ${formatDateTimeIso(item.createdAt)}',
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => context.push(ReviewRouter.suggestionDetailPath(item.id)),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final materialBrightness = Theme.of(context).brightness;
    final isDark = materialBrightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    final shimmer = ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effect: shimmer),
      child: IgnorePointer(
        child: Skeletonizer(
          enabled: true,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              FTileGroup(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < itemCount; i++) const _SkeletonTile(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget with FTileMixin {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return FTile(
      title: Text('Lemma contoh'),
      subtitle: Text('Kontributor · ringkasan · 21 Sep 2026 00:00'),
    );
  }
}
