import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../../review_router.dart';
import '../providers/review_history_providers.dart';

/// Riwayat keputusan verifikasi milik user auth (GET mine=true).
class ReviewHistoryPage extends ConsumerWidget {
  const ReviewHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final async = ref.watch(reviewHistoryControllerProvider);
    final filter = async.value?.statusFilter ??
        ref.read(reviewHistoryControllerProvider.notifier).statusFilter;

    final chips = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < reviewHistoryStatusFilters.length; i++) ...[
              if (i > 0) const Gap(6),
              GestureDetector(
                onTap: () => ref
                    .read(reviewHistoryControllerProvider.notifier)
                    .setStatusFilter(reviewHistoryStatusFilters[i].value),
                child: FBadge(
                  variant: filter == reviewHistoryStatusFilters[i].value
                      ? FBadgeVariant.primary
                      : FBadgeVariant.secondary,
                  child: Text(reviewHistoryStatusFilters[i].label),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Riwayat verifikasi'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          chips,
          Expanded(
            child: async.when(
              loading: () => const _ListSkeleton(),
              error: (error, _) => Center(
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
                        error is ReviewFailure
                            ? error.message
                            : 'Gagal memuat riwayat',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(16),
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: () =>
                            ref.invalidate(reviewHistoryControllerProvider),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (state) {
                Future<void> refresh() async {
                  ref.invalidate(reviewHistoryControllerProvider);
                  await ref.read(reviewHistoryControllerProvider.future);
                }

                if (state.items.isEmpty) {
                  final message = filter == null
                      ? 'Belum ada keputusan verifikasi'
                      : 'Tidak ada keputusan dengan status ini';
                  return RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            message,
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                    children: [
                      FTileGroup(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final item in state.items)
                            _HistoryTile(item: item),
                        ],
                      ),
                      if (state.hasMore)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FButton(
                              variant: FButtonVariant.ghost,
                              onPress: () => ref
                                  .read(
                                    reviewHistoryControllerProvider.notifier,
                                  )
                                  .loadMore(),
                              child: const Text('Muat lagi'),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget with FTileMixin {
  const _HistoryTile({required this.item});

  final ReviewItem item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final decision = item.reviewStatus ?? item.status;
    final date = formatDateTimeIso(item.reviewedAt ?? item.createdAt);
    final statusColor = switch (decision) {
      'approved' => theme.colors.success,
      'rejected' => theme.colors.destructive,
      'corrected' => theme.colors.primary,
      _ => theme.colors.warning,
    };

    return FTile(
      title: Text(item.title),
      subtitle: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: reviewStatusLabel(decision),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (date.isNotEmpty) TextSpan(text: ' · $date'),
          ],
        ),
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => context.push(ReviewRouter.historyDetailPath(item.id)),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

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
                  for (var i = 0; i < 6; i++) const _SkeletonTile(),
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
      title: const Text('Lemma contoh'),
      subtitle: const Text('Disetujui · 21 Sep 2026 00:00'),
    );
  }
}
