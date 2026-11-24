import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/back_to_top_button.dart'
    show ScrollWithBackToTop;
import '../../../../shared/widgets/profile_hero_shell.dart';
import '../../../../shared/widgets/profile_identity_header.dart';
import '../../../user_profile/presentation/widgets/profile_activity_section.dart'
    show OverlapAboveBox, ProfileBarClearanceHeader;
import '../../domain/community_org.dart';
import '../providers/community_providers.dart';

String _detailCoverFor(CommunityOrg org) => switch (org.featuredKind) {
  'tim' => 'assets/images/community/tim.webp',
  'sponsor' => 'assets/images/community/sponsor.webp',
  _ => 'assets/images/placeholder_512.png',
};

String _detailAvatarFor(CommunityOrg org) => _detailCoverFor(org);

class CommunityDetailPage extends ConsumerStatefulWidget {
  const CommunityDetailPage({super.key, required this.orgId});

  /// Route lama masih bernama orgId, nilainya sekarang slug dari API.
  final String orgId;

  @override
  ConsumerState<CommunityDetailPage> createState() =>
      _CommunityDetailPageState();
}

class _CommunityDetailPageState extends ConsumerState<CommunityDetailPage> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detailAsync = ref.watch(communityOrgDetailProvider(widget.orgId));

    return detailAsync.when(
      loading: () => FScaffold(
        header: _header(context, l10n),
        child: const Center(child: FCircularProgress()),
      ),
      error: (_, _) => FScaffold(
        header: _header(context, l10n),
        child: Center(
          child: Text(
            l10n.communityLoadFailed,
            style: context.theme.typography.body.md.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
      ),
      data: (org) {
        if (org == null) {
          return FScaffold(
            header: _header(context, l10n),
            child: Center(
              child: Text(
                l10n.communityOrgEmpty,
                style: context.theme.typography.body.md.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ),
          );
        }
        return _OrgDetailBody(
          org: org,
          scroll: _scroll,
          onRefresh: () =>
              ref.refresh(communityOrgDetailProvider(widget.orgId).future),
        );
      },
    );
  }

  FHeader _header(BuildContext context, AppLocalizations l10n) =>
      FHeader.nested(
        title: Text(l10n.exploreCategoryKomunitas),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      );
}

class _OrgDetailBody extends StatelessWidget {
  const _OrgDetailBody({
    required this.org,
    required this.scroll,
    required this.onRefresh,
  });

  final CommunityOrg org;
  final ScrollController scroll;
  final Future<void> Function() onRefresh;

  String _categoryLabel(AppLocalizations l10n) => switch (org.category) {
    'seni' => l10n.communityCategorySeni,
    'bahasa' => l10n.communityCategoryBahasa,
    'pendidikan' => l10n.communityCategoryPendidikan,
    'ukm' => l10n.communityCategoryUkm,
    _ => l10n.communityCategoryLain,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final barOffset =
        MediaQuery.paddingOf(context).top + ProfileHeroShell.barHeight;

    return FScaffold(
      childPad: false,
      child: ProfileHeroShell(
        showBack: true,
        onBack: () => context.canPop() ? context.pop() : context.go('/explore'),
        backLabel: l10n.commonBack,
        coverHeight: ProfileIdentityHeader.coverHeightOf(
          ProfileHeaderVariant.compact,
          MediaQuery.sizeOf(context).width,
        ),
        title: org.name,
        scrollView: ScrollWithBackToTop(
          controller: scroll,
          child: RefreshIndicator(
            onRefresh: onRefresh,
            displacement: barOffset + 8,
            child: CustomScrollView(
              controller: scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ProfileBarClearanceHeader(height: barOffset),
                ),
                SliverToBoxAdapter(
                  child: OverlapAboveBox(
                    overlap: barOffset,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileIdentityHeader(
                          variant: ProfileHeaderVariant.compact,
                          displayName: org.name,
                          avatarUrl: org.logoUrl,
                          avatarAsset: _detailAvatarFor(org),
                          coverUrl: org.coverUrl,
                          coverAsset: _detailCoverFor(org),
                          bio: org.description,
                          footer: org.featuredKind == null
                              ? null
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FBadge(
                                      variant: FBadgeVariant.secondary,
                                      child: Text(
                                        l10n.communityBadgeOfficialPartner,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const Gap(8),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
                  sliver: SliverToBoxAdapter(
                    child: FTileGroup(
                      children: [
                        FTile(
                          prefix: const Icon(FLucideIcons.tag, size: 18),
                          title: Text(l10n.communityDetailCategory),
                          subtitle: Text(_categoryLabel(l10n)),
                        ),
                        if (org.location != null && org.location!.isNotEmpty)
                          FTile(
                            prefix: const Icon(
                              FLucideIcons.mapPinned,
                              size: 18,
                            ),
                            title: Text(l10n.communityDetailDistrict),
                            subtitle: Text(org.location!),
                          ),
                        FTile(
                          prefix: const Icon(FLucideIcons.alignLeft, size: 18),
                          title: Text(l10n.communityContributeDesc),
                          subtitle: Text(org.description),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
