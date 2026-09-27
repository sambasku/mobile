import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../../domain/review_access.dart';
import '../../review_router.dart';
import '../providers/review_providers.dart';
import '../utils/leave_review.dart';
import 'review_forbidden_page.dart';

class ReviewQueuePage extends ConsumerWidget {
  const ReviewQueuePage({super.key, this.wordId});

  final String? wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ReviewQueueQuery(wordId: wordId);
    final queue = ref.watch(reviewQueueProvider(query));
    final failure = queue.hasError ? queue.error : null;
    if (failure is ReviewFailure && failure.isForbidden) {
      return ReviewForbiddenPage(message: failure.message);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leaveReview(context);
      },
      child: FScaffold(
        childPad: true,
        header: FHeader.nested(
          title: const Text('Tinjau usulan'),
          prefixes: [
            FHeaderAction.back(onPress: () => leaveReview(context)),
          ],
        ),
        child: queue.when(
          loading: () {
            final viewportHeight = MediaQuery.sizeOf(context).height;
            final skeletonPerPage = (viewportHeight ~/ 80) + 2;
            return _ListSkeleton(itemCount: skeletonPerPage);
          },
          error: (error, _) => _ErrorState(
            message: error is ReviewFailure
                ? error.message
                : 'Gagal memuat antrean',
            onRetry: () => ref.invalidate(reviewQueueProvider(query)),
          ),
          data: (state) => _QueueList(query: query, state: state),
        ),
      ),
    );
  }
}

class _QueueList extends ConsumerWidget {
  const _QueueList({required this.query, required this.state});

  final ReviewQueueQuery query;
  final ReviewQueueState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;

    Future<void> refresh() async {
      ref.invalidate(reviewQueueProvider(query));
      await ref.read(reviewQueueProvider(query).future);
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
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FLucideIcons.clipboardList,
                        size: 40,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(10),
                      Text(
                        'Tidak ada usulan yang menunggu',
                        style: theme.typography.md.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(4),
                      Text(
                        'Usulan baru dari kontributor akan muncul di sini.',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    void openSession({String? startId}) {
      ref.read(reviewSessionProvider.notifier).startFromQueue(
        state,
        query: query,
        startId: startId,
      );
      context.push(
        ReviewRouter.sessionPath(
          startId: startId ?? state.items.first.id,
          wordId: query.wordId,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          FButton(
            onPress: () => openSession(),
            prefix: const Icon(FLucideIcons.play),
            child: Text('Mulai tinjau (${state.items.length}${state.hasMore ? '+' : ''})'),
          ),
          const Gap(12),
          FTileGroup(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final item in state.items)
                _ReviewTile(
                  item: item,
                  onPress: () => openSession(startId: item.id),
                ),
            ],
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
                            .read(reviewQueueProvider(query).notifier)
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

class _ReviewTile extends StatelessWidget with FTileMixin {
  const _ReviewTile({required this.item, required this.onPress});

  final ReviewItem item;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final date = formatDateTimeIso(item.createdAt);
    return FTile(
      title: Text(item.title),
      subtitle: Text(
        [
          reviewEntityLabel(item.entityType),
          item.contributorUsername ?? 'anonim',
          if (date.isNotEmpty) date,
        ].join(' · '),
      ),
      prefix: Icon(
        FLucideIcons.clipboardList,
        color: theme.colors.primary,
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: onPress,
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
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
              FLucideIcons.circleAlert,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              message,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: onRetry,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
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
      title: Text('Usulan kata contoh'),
      subtitle: Text('Kata · kontributor · 21 Sep 2026 00:00'),
    );
  }
}
