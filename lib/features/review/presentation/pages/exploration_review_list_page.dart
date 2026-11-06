import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/exploration_proposal.dart';
import '../../domain/exploration_reject_reasons.dart';
import '../../domain/failures/review_failure.dart';
import '../../review_router.dart';
import '../providers/exploration_review_providers.dart';

class ExplorationReviewListPage extends ConsumerWidget {
  const ExplorationReviewListPage({super.key, required this.domain});

  final ExplorationReviewDomain domain;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(explorationPendingListProvider(domain));

    Future<void> refresh() async {
      ref.invalidate(explorationPendingListProvider(domain));
      await ref.read(explorationPendingListProvider(domain).future);
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(_listTitle(l10n)),
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
                    : l10n.reviewExploreLoadFailed,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(12),
              FButton(
                variant: FButtonVariant.outline,
                onPress: () =>
                    ref.invalidate(explorationPendingListProvider(domain)),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
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
                          l10n.reviewExploreEmpty,
                          style: theme.typography.body.sm.copyWith(
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

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                FTileGroup(
                  children: [
                    for (final item in items)
                      _ProposalTile(domain: domain, item: item),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _listTitle(AppLocalizations l10n) => switch (domain) {
    .usaha => l10n.reviewExploreUsahaListTitle,
    .place => l10n.reviewExplorePlaceListTitle,
    .culinary => l10n.reviewExploreCulinaryListTitle,
    .event => l10n.reviewExploreEventListTitle,
  };
}

class _ProposalTile extends StatelessWidget with FTileMixin {
  const _ProposalTile({required this.domain, required this.item});

  final ExplorationReviewDomain domain;
  final ExplorationProposal item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kindLabel = item.kind != null && item.kind!.isNotEmpty
        ? explorationKindLabel(domain, item.kind, l10n)
        : (item.subtitle?.trim().isNotEmpty == true
            ? item.subtitle!.trim()
            : explorationKindLabel(domain, null, l10n));
    return FTile(
      prefix: Icon(_iconFor(domain), color: context.theme.colors.primary),
      title: Text(item.title),
      subtitle: Text(
        l10n.reviewExploreMetaKindDate(kindLabel, item.createdAtLabel),
      ),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: () =>
          context.push(ReviewRouter.explorationDetailPath(domain, item.id)),
    );
  }

  IconData _iconFor(ExplorationReviewDomain domain) => switch (domain) {
    .usaha => FLucideIcons.store,
    .place => FLucideIcons.mapPin,
    .culinary => FLucideIcons.utensilsCrossed,
    .event => FLucideIcons.calendar,
  };
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
    return FTile(
      title: Text(AppLocalizations.of(context).reviewSkeletonLemma),
      subtitle: Text(AppLocalizations.of(context).reviewSkeletonProposalMeta),
    );
  }
}
