import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/paged_list_bridge.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../discussion/domain/discussion_models.dart';
import '../../review_router.dart';
import '../providers/discussion_review_providers.dart';

/// Antrean diskusi pending_review untuk verifikator.
///
/// List pakai infinite_scroll_pagination: autoload saat scroll mendekati
/// ekor, tanpa tombol "Muat lagi".
class DiscussionReviewQueuePage extends ConsumerWidget {
  const DiscussionReviewQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final async = ref.watch(discussionReviewListProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Tinjauan Diskusi'),
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
                error is DiscussionFailure
                    ? error.message
                    : 'Gagal memuat antrean diskusi',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => ref.invalidate(discussionReviewListProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (state) => _QueueList(state: state),
      ),
    );
  }
}

class _QueueList extends ConsumerStatefulWidget {
  const _QueueList({required this.state});

  final DiscussionReviewListState state;

  @override
  ConsumerState<_QueueList> createState() => _QueueListState();
}

class _QueueListState extends ConsumerState<_QueueList> {
  late final PagingController<int, DiscussionItem> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = createPagingController<DiscussionItem>(
      loadMore: () =>
          ref.read(discussionReviewListProvider.notifier).loadMore(),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final state = widget.state;

    Future<void> refresh() async {
      ref.invalidate(discussionReviewListProvider);
      await ref.read(discussionReviewListProvider.future);
    }

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
                    'Tidak ada diskusi menunggu tinjauan',
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

    // Sinkron snapshot list Riverpod -> PagingController (autoload di ekor
    // list, tanpa tombol "Muat lagi").
    _pagingController.value = buildPagingState<DiscussionItem>(
      items: state.items,
      hasMore: state.hasMore,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: RefreshIndicator(
        onRefresh: refresh,
        child: PagedListView<int, DiscussionItem>.separated(
          state: _pagingController.value,
          fetchNextPage: _pagingController.fetchNextPage,
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (_, _) => const Divider(height: 1),
          builderDelegate: PagedChildBuilderDelegate<DiscussionItem>(
            itemBuilder: (context, item, index) => _DiscussionTile(item: item),
            newPageProgressIndicatorBuilder: (context) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: FCircularProgress()),
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
      ),
    );
  }
}

class _DiscussionTile extends StatelessWidget with FTileMixin {
  const _DiscussionTile({required this.item});

  final DiscussionItem item;

  @override
  Widget build(BuildContext context) {
    final preview = (item.body ?? '').trim();
    final name = displayPublicAccountLabel(
      displayName: item.displayName,
      username: item.username,
    );
    final thumb = item.images.isNotEmpty
        ? item.images.first.displaySource
        : null;
    final thumbUrl = thumb == null ? null : (displayImageUrl(thumb) ?? thumb);
    return FTile(
      prefix: thumbUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: CachedNetworkImageWithFallback(
                  imageUrl: thumbUrl,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : const Icon(FLucideIcons.messageSquare),
      title: Text(
        preview.isEmpty ? '(tanpa teks)' : preview,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          name,
          if (item.createdAt.isNotEmpty)
            formatRelativeCompact(DateTime.tryParse(item.createdAt)),
          if (item.linkUrl != null && item.linkUrl!.isNotEmpty) 'Ada tautan',
        ].where((e) => e.isNotEmpty).join(' · '),
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => context.push(ReviewRouter.discussionDetailPath(item.id)),
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
      title: Text('Cuplikan diskusi contoh'),
      subtitle: Text('Pengirim · baru saja'),
    );
  }
}
