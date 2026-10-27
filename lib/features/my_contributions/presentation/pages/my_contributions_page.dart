import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/tile_group_list.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/my_submission.dart';
import '../../domain/failures/my_contribution_failure.dart';
import '../../my_contributions_router.dart';
import '../my_contribution_labels.dart';
import '../providers/my_contributions_providers.dart';
import '../widgets/submission_status_icon.dart';

/// Daftar usulan milik user login - GET /api/v1/contributions/my.
///
/// List pakai TileGroupList: autoload saat scroll mendekati ekor,
/// tanpa tombol "Muat lagi".
class MyContributionsPage extends ConsumerWidget {
  const MyContributionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(AppLocalizations.of(context).myContributionsTitle),
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
              AppLocalizations.of(context).myContributionsLoginRequired,
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

class _ContributionsList extends ConsumerWidget {
  const _ContributionsList();

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(myContributionsListControllerProvider);
    await ref.read(myContributionsListControllerProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    : AppLocalizations.of(context).myContributionsLoadFailed,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(16),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () =>
                    ref.invalidate(myContributionsListControllerProvider),
                child: Text(AppLocalizations.of(context).commonRetry),
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

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: constraints.maxHeight,
                child: Center(
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
                        AppLocalizations.of(context).myContributionsEmpty,
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(4),
                      Text(
                        AppLocalizations.of(context).myContributionsEmptyBody,
                        style: theme.typography.body.sm.copyWith(
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

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: TileGroupList<MySubmission>(
        items: state.items,
        hasMore: state.hasMore,
        onLoadMore: () =>
            ref.read(myContributionsListControllerProvider.notifier).loadMore(),
        tileBuilder: (context, item) => _SubmissionTile(item: item),
      ),
    );
  }
}

class _SubmissionTile extends StatelessWidget with FTileMixin {
  const _SubmissionTile({required this.item});

  final MySubmission item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final date = formatDateTimeIso(item.createdAt);
    final statusColor = switch (item.status) {
      'approved' => theme.colors.success,
      'rejected' => theme.colors.destructive,
      'corrected' => theme.colors.primary,
      _ => theme.colors.warning,
    };

    final subtitleSpans = <InlineSpan>[
      TextSpan(text: '${mySubmissionKindLabel(l10n, item.entityType)} · '),
      TextSpan(
        text: mySubmissionStatusLabel(l10n, item.status),
        style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
      ),
      if (date.isNotEmpty) TextSpan(text: ' · $date'),
    ];
    if (item.status == 'rejected') {
      final short = submissionReviewSnippet(item.reviewComment);
      if (short.isNotEmpty) subtitleSpans.add(TextSpan(text: ' · $short'));
    }

    return FTile(
      title: Text(mySubmissionTitle(l10n, item)),
      subtitle: Text.rich(TextSpan(children: subtitleSpans)),
      prefix: SubmissionStatusIcon(status: item.status),
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
    PaintingEffect shimmerResolver(Brightness brightness) => ShimmerEffect(
      baseColor: isDark
          ? muted.withValues(alpha: 0.35)
          : const Color(0xFFE7E7EA),
      highlightColor: isDark
          ? muted.withValues(alpha: 0.55)
          : const Color(0xFFF4F4F5),
      duration: const Duration(milliseconds: 1500),
    );

    return SkeletonizerConfig(
      data: SkeletonizerConfigData(effectResolver: shimmerResolver),
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
    final l10n = AppLocalizations.of(context);
    return FTile(
      title: Text(l10n.myContributionsSkeletonLemma),
      subtitle: Text(l10n.myContributionsSkeletonMeta),
    );
  }
}
