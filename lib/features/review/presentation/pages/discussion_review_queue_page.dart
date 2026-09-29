import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../discussion/domain/discussion_models.dart';
import '../../review_router.dart';
import '../providers/discussion_review_providers.dart';

/// Antrean diskusi pending_review untuk verifikator.
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

class _QueueList extends ConsumerWidget {
  const _QueueList({required this.state});

  final DiscussionReviewListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: refresh,
              child: FTileGroup.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                count: state.items.length,
                tileBuilder: (context, index) =>
                    _DiscussionTile(item: state.items[index]),
              ),
            ),
          ),
          if (state.hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  variant: FButtonVariant.ghost,
                  onPress: state.isLoadingMore
                      ? null
                      : () => ref
                            .read(discussionReviewListProvider.notifier)
                            .loadMore(),
                  prefix: state.isLoadingMore
                      ? const FCircularProgress()
                      : null,
                  child: Text(state.isLoadingMore ? 'Memuat...' : 'Muat lagi'),
                ),
              ),
            ),
        ],
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
