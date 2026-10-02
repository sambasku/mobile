import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../core/widgets/paged_list_bridge.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/my_vote_item.dart';
import '../../domain/failures/my_vote_failure.dart';
import '../providers/my_votes_providers.dart';

/// Riwayat vote milik user login - GET /api/v1/votes/history.
///
/// List pakai infinite_scroll_pagination: autoload saat scroll mendekati
/// ekor, tanpa tombol "Muat lagi".
class MyVotesPage extends ConsumerWidget {
  const MyVotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Vote'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => const _GuestState(),
        data: (status) =>
            status.isAuth ? const _VotesList() : const _GuestState(),
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
              FLucideIcons.arrowBigUp,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              'Masuk dulu untuk melihat vote kamu',
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

class _VotesList extends ConsumerStatefulWidget {
  const _VotesList();

  @override
  ConsumerState<_VotesList> createState() => _VotesListState();
}

class _VotesListState extends ConsumerState<_VotesList> {
  late final PagingController<int, MyVoteItem> _pagingController;

  @override
  void initState() {
    super.initState();
    _pagingController = createPagingController<MyVoteItem>(
      loadMore: () async {
        final failure =
            await ref.read(myVotesListControllerProvider.notifier).loadMore();
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
    ref.invalidate(myVotesListControllerProvider);
    await ref.read(myVotesListControllerProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final async = ref.watch(myVotesListControllerProvider);

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
                error is MyVoteFailure ? error.message : 'Gagal memuat vote',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () => ref.invalidate(myVotesListControllerProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (async.isLoading) {
      final skeletonPerPage = (MediaQuery.sizeOf(context).height ~/ 80) + 2;
      return _ListSkeleton(itemCount: skeletonPerPage);
    }

    final state = async.requireValue;

    // Sinkron snapshot list Riverpod -> PagingController.
    _pagingController.value = buildPagingState<MyVoteItem>(
      items: state.items,
      hasMore: state.hasMore,
    );

    return RefreshIndicator(
      onRefresh: _refresh,
      child: PagedListView<int, MyVoteItem>.separated(
        state: _pagingController.value,
        fetchNextPage: _pagingController.fetchNextPage,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        separatorBuilder: (_, _) => const Divider(height: 1),
        builderDelegate: PagedChildBuilderDelegate<MyVoteItem>(
          itemBuilder: (context, item, index) => _VoteTile(item: item),
          noItemsFoundIndicatorBuilder: (context) => SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: const Center(child: Text('Belum ada vote')),
          ),
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
    );
  }
}

class _VoteTile extends StatelessWidget with FTileMixin {
  const _VoteTile({required this.item});

  final MyVoteItem item;

  @override
  Widget build(BuildContext context) {
    final date = formatDateTimeIso(item.votedAt);
    return FTile(
      title: Text(item.title),
      subtitle: Text(item.subtitle(date)),
      suffix: item.canOpen ? const Icon(FLucideIcons.chevronRight) : null,
      onPress: item.canOpen
          ? () => context.push('/words/${item.word!.id}')
          : null,
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = context.theme.colors.muted;
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: isDark
            ? muted.withValues(alpha: 0.35)
            : const Color(0xFFE7E7EA),
        highlightColor: isDark
            ? muted.withValues(alpha: 0.55)
            : const Color(0xFFF4F4F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [
          FTileGroup(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (var i = 0; i < itemCount; i++)
                FTile(
                  title: const Text('lemma contoh'),
                  subtitle: const Text('Upvote · Kata · 21 Sep 2026 10:00'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
