import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/my_comment_item.dart';
import '../../domain/failures/my_comment_failure.dart';
import '../providers/my_comments_providers.dart';

/// Komentar milik user login - GET /api/v1/comments/my.
///
/// List pakai TileGroupList: autoload saat scroll mendekati ekor,
/// tanpa tombol "Muat lagi".
class MyCommentsPage extends ConsumerWidget {
  const MyCommentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Komentar'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => const _GuestState(),
        data: (status) =>
            status.isAuth ? const _CommentsList() : const _GuestState(),
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
              FLucideIcons.messageSquare,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              'Masuk dulu untuk melihat komentar kamu',
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

class _CommentsList extends ConsumerWidget {
  const _CommentsList();

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myCommentsListControllerProvider);
    await ref.read(myCommentsListControllerProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final selected = ref.watch(myCommentsStatusFilterProvider);
    final async = ref.watch(myCommentsListControllerProvider);

    final chips = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < commentStatusFilters.length; i++) ...[
              if (i > 0) const Gap(6),
              GestureDetector(
                onTap: () => ref
                    .read(myCommentsStatusFilterProvider.notifier)
                    .select(commentStatusFilters[i].$1),
                child: FBadge(
                  variant: selected == commentStatusFilters[i].$1
                      ? FBadgeVariant.primary
                      : FBadgeVariant.secondary,
                  child: Text(commentStatusFilters[i].$2),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (async.hasError) {
      final error = async.error!;
      return Column(
        children: [
          chips,
          Expanded(
            child: Center(
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
                      error is MyCommentFailure
                          ? error.message
                          : 'Gagal memuat komentar',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () =>
                          ref.invalidate(myCommentsListControllerProvider),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (async.isLoading) {
      return Column(
        children: [
          chips,
          Expanded(
            child: Skeletonizer(
              enabled: true,
              child: ListView(
                children: [
                  FTile(
                    title: const Text('lemma contoh'),
                    subtitle: const Text('Tayang · cuplikan · 21 Sep 2026'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final state = async.requireValue;

    final emptyMessage = selected == null
        ? 'Belum ada komentar'
        : 'Tidak ada komentar dengan status ini';

    if (state.items.isEmpty) {
      return Column(
        children: [
          chips,
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: Center(child: Text(emptyMessage)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        chips,
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: TileGroupList<MyCommentItem>(
              items: state.items,
              hasMore: state.hasMore,
              onLoadMore: () =>
                  ref.read(myCommentsListControllerProvider.notifier).loadMore(),
              tileBuilder: (context, item) => _CommentTile(item: item),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget with FTileMixin {
  const _CommentTile({required this.item});

  final MyCommentItem item;

  @override
  Widget build(BuildContext context) {
    final date = formatDateTimeIso(item.createdAt);
    return FTile(
      title: Text(item.title),
      subtitle: Text(item.subtitle(date)),
      suffix: item.canOpen ? const Icon(FLucideIcons.chevronRight) : null,
      onPress: item.canOpen
          ? () => context.push('/words/${item.wordId}')
          : null,
    );
  }
}
