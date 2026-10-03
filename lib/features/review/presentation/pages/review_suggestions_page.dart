import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/paged_list_bridge.dart';
import '../../domain/entities/word_suggestion_review.dart';
import '../../domain/failures/review_failure.dart';
import '../../review_router.dart';
import '../providers/review_suggestions_providers.dart';

/// Antrean usulan edit kata (GET admin/word-suggestions?status=pending).
///
/// List pakai infinite_scroll_pagination: autoload saat scroll mendekati
/// ekor, tanpa tombol "Muat lagi".
class ReviewSuggestionsPage extends ConsumerStatefulWidget {
  const ReviewSuggestionsPage({super.key});

  @override
  ConsumerState<ReviewSuggestionsPage> createState() =>
      _ReviewSuggestionsPageState();
}

class _ReviewSuggestionsPageState
    extends ConsumerState<ReviewSuggestionsPage> {
  late final PagingController<int, WordSuggestionSummary> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = createPagingController<WordSuggestionSummary>(
      loadMore: () =>
          ref.read(reviewSuggestionsListProvider.notifier).loadMore(),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(reviewSuggestionsListProvider);
    await ref.read(reviewSuggestionsListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final async = ref.watch(reviewSuggestionsListProvider);

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
          // Sinkron snapshot list Riverpod -> PagingController.
          _pagingController.value = buildPagingState<WordSuggestionSummary>(
            items: state.items,
            hasMore: state.hasMore,
          );

          return RefreshIndicator(
            onRefresh: _refresh,
            child: PagedListView<int, WordSuggestionSummary>.separated(
              state: _pagingController.value,
              fetchNextPage: _pagingController.fetchNextPage,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
              separatorBuilder: (_, _) => const Divider(height: 1),
              builderDelegate:
                  PagedChildBuilderDelegate<WordSuggestionSummary>(
                itemBuilder: (context, item, index) =>
                    _SuggestionTile(item: item),
                noItemsFoundIndicatorBuilder: (context) => Center(
                  child: Text(
                    'Tidak ada usulan edit menunggu',
                    style: theme.typography.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                newPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: FCircularProgress(),
                  ),
                ),
                newPageErrorIndicatorBuilder: (context) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Gagal memuat halaman berikutnya',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const Gap(10),
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: _pagingController.fetchNextPage,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
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
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
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
