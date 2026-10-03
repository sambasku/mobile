import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/paged_list_bridge.dart';
import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/my_submission.dart';
import '../../domain/failures/my_contribution_failure.dart';
import '../../my_contributions_router.dart';
import '../providers/my_contributions_providers.dart';

/// Daftar usulan milik user login - GET /api/v1/contributions/my.
///
/// List pakai infinite_scroll_pagination: autoload saat scroll mendekati
/// ekor, tanpa tombol "Muat lagi".
class MyContributionsPage extends ConsumerWidget {
  const MyContributionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Kontribusi Saya'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => const _GuestState(),
        data: (status) =>
            status.isAuth ? const _ContributionsList() : const _GuestState(),
      ),
    );
  }
}

class _GuestState extends StatelessWidget {
  const _GuestState();

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
              FLucideIcons.filePenLine,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              'Masuk dulu untuk melihat usulanmu',
              style: theme.typography.md.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push('/login'),
              child: const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContributionsList extends ConsumerStatefulWidget {
  const _ContributionsList();

  @override
  ConsumerState<_ContributionsList> createState() => _ContributionsListState();
}

class _ContributionsListState extends ConsumerState<_ContributionsList> {
  late final PagingController<int, MySubmission> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = createPagingController<MySubmission>(
      loadMore: () async {
        final failure = await ref
            .read(myContributionsListControllerProvider.notifier)
            .loadMore();
        if (failure != null) throw failure;
      },
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(myContributionsListControllerProvider);
    await ref.read(myContributionsListControllerProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final async = ref.watch(myContributionsListControllerProvider);

    if (async.hasError) {
      final error = async.error!;
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
                error is MyContributionFailure
                    ? error.message
                    : 'Gagal memuat kontribusi',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () =>
                    ref.invalidate(myContributionsListControllerProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (async.isLoading) {
      final viewportHeight = MediaQuery.sizeOf(context).height;
      final skeletonPerPage = (viewportHeight ~/ 80) + 2;
      return _ListSkeleton(itemCount: skeletonPerPage);
    }

    final state = async.requireValue;

    // Sinkron snapshot list Riverpod -> PagingController (autoload di ekor
    // list, tanpa tombol "Muat lagi").
    _pagingController.value = buildPagingState<MySubmission>(
      items: state.items,
      hasMore: state.hasMore,
    );

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
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
                        FLucideIcons.filePenLine,
                        size: 40,
                        color: theme.colors.mutedForeground,
                      ),
                      const Gap(10),
                      Text(
                        'Belum ada usulan',
                        style: theme.typography.md.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(4),
                      Text(
                        'Usul kata baru atau perubahan akan muncul di sini.',
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: PagedListView<int, MySubmission>.separated(
          state: _pagingController.value,
          fetchNextPage: _pagingController.fetchNextPage,
          physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (_, _) => const Divider(height: 1),
          builderDelegate: PagedChildBuilderDelegate<MySubmission>(
            itemBuilder: (context, item, index) => _SubmissionTile(item: item),
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

class _SubmissionTile extends StatelessWidget with FTileMixin {
  const _SubmissionTile({required this.item});

  final MySubmission item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final date = formatDateTimeIso(item.createdAt);
    final statusColor = switch (item.status) {
      'approved' => theme.colors.success,
      'rejected' => theme.colors.destructive,
      'corrected' => theme.colors.primary,
      _ => theme.colors.warning,
    };

    final subtitleSpans = <InlineSpan>[
      TextSpan(text: '${item.kindLabel} · '),
      TextSpan(
        text: item.statusLabel,
        style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
      ),
      if (date.isNotEmpty) TextSpan(text: ' · $date'),
    ];
    if (item.status == 'rejected') {
      final comment = item.reviewComment?.trim() ?? '';
      if (comment.isNotEmpty) {
        final short = comment.length > 60
            ? '${comment.substring(0, 60)}...'
            : comment;
        subtitleSpans.add(TextSpan(text: ' · $short'));
      }
    }

    return FTile(
      title: Text(item.displayTitle),
      subtitle: Text.rich(TextSpan(children: subtitleSpans)),
      prefix: item.isPendingReview
          ? const PendingReviewBadgeIcon(size: 16)
          : null,
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () => context.push(
        MyContributionsRouter.detailPath(kind: item.kind, id: item.id),
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
      title: const Text('lemma contoh usulan'),
      subtitle: const Text(
        'Usul kata baru · Menunggu pengecekan · 21 Sep 2026 00:00',
      ),
    );
  }
}
