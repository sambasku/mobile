import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/my_comment_item.dart';
import '../../domain/failures/my_comment_failure.dart';
import '../my_comment_labels.dart';
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
        title: Text(AppLocalizations.of(context).myCommentsTitle),
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
              AppLocalizations.of(context).myCommentsLoginRequired,
              style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push('/login'),
              child: Text(AppLocalizations.of(context).commonLoginRequiredShort),
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
                    .select(commentStatusFilters[i]),
                child: FBadge(
                  variant: selected == commentStatusFilters[i]
                      ? FBadgeVariant.primary
                      : FBadgeVariant.secondary,
                  child: Text(
                    commentStatusFilterLabel(
                      AppLocalizations.of(context),
                      commentStatusFilters[i],
                    ),
                  ),
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
                          : AppLocalizations.of(context).myCommentsLoadFailed,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () =>
                          ref.invalidate(myCommentsListControllerProvider),
                      child: Text(AppLocalizations.of(context).commonRetry),
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
      final l10n = AppLocalizations.of(context);
      return Column(
        children: [
          chips,
          Expanded(
            child: Skeletonizer(
              enabled: true,
              child: ListView(
                children: [
                  FTile(
                    title: Text(l10n.commonSkeletonLemma),
                    subtitle: Text(l10n.myCommentsSkeletonMeta),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final state = async.requireValue;

    final l10n = AppLocalizations.of(context);
    final emptyMessage = selected == null
        ? l10n.myCommentsEmpty
        : l10n.myCommentsEmptyFiltered;

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
    final l10n = AppLocalizations.of(context);
    final date = formatDateTimeIso(item.createdAt);
    return FTile(
      title: Text(myCommentTitle(l10n, item)),
      subtitle: Text(myCommentSubtitle(l10n, item, date)),
      suffix: item.canOpen ? const Icon(FLucideIcons.chevronRight) : null,
      onPress: item.canOpen
          ? () => context.push('/words/${item.wordId}')
          : null,
    );
  }
}
