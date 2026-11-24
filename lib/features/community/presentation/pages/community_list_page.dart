import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../about/about_router.dart';
import '../../../explore/explore_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../user_profile/presentation/widgets/profile_activity_section.dart'
    show OverlapAboveBox, ProfileBarClearanceHeader;
import '../../../../shared/widgets/profile_hero_shell.dart';
import '../../../../shared/widgets/profile_identity_header.dart';
import '../../data/community_org_list.dart';
import '../../domain/community_org.dart';
import '../providers/community_providers.dart';

/// Direktori komunitas / organisasi / perkumpulan di Kabupaten Sambas.
///
/// Struktur ala artikel: hero cover full-bleed (appbar transparan) + search
/// & chip pinned di bawah bar melayang + top 2 featured di atas grid.
class CommunityListPage extends ConsumerStatefulWidget {
  const CommunityListPage({super.key});

  @override
  ConsumerState<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends ConsumerState<CommunityListPage> {
  var _category = CommunityCategory.semua;
  var _query = '';
  Timer? _debounce;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value.trim().toLowerCase());
    });
  }

  Future<void> _reload() async {
    final provider = communityOrgListProvider(_category.id, _query);
    ref.invalidate(provider);
    await ref.read(provider.future);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(communityOrgListProvider(_category.id, _query));
    // Chip pinned berhenti di bawah bar melayang (pola profil publik).
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
        title: l10n.exploreCategoryKomunitas,
        // Aksi kanan-atas pola usaha_list_page: riwayat usulan + usul baru.
        actions: [
          ProfileHeroAction(
            icon: FLucideIcons.clipboardList,
            tooltip: l10n.communityProposalsTitle,
            onPress: () => context.push(ExploreRouter.communityProposals.path),
          ),
          ProfileHeroAction(
            icon: FLucideIcons.plus,
            tooltip: l10n.communityContributeTitle,
            onPress: () => context.push('/explore/komunitas/usul'),
          ),
        ],
        // Tombol aksi seragam dengan halaman ber-FHeader biasa (bukan 48dp).
        compactActions: true,
        scrollView: RefreshIndicator(
          onRefresh: _reload,
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
            // Clearance pinned: hero overlap ke sini, cover full-bleed
            // tembus ke tepi atas layar (pola profil publik).
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
                    // Hero cover full-bleed di bawah bar melayang.
                    _Hero(l10n: l10n),
                    // Top 2 static: Tim Kami + Sponsor Kami. Selalu tampil,
                    // tanpa API / seed.
                    _FeaturedRow(
                      l10n: l10n,
                      items: communityTopList,
                      onTap: (org) {
                        final tab = org.featuredKind == 'tim'
                            ? 'team'
                            : 'sponsors';
                        context.push(
                          '${AboutRouter.sponsorshipTeam.path}?tab=$tab',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Search + chip pinned: menempel di bawah bar melayang saat
            // scroll (stack, pola chip feed beranda). Tanpa clearance
            // internal - clearance sliver sendiri di atas.
            SliverPersistentHeader(
              pinned: true,
              delegate: _SearchChipsHeader(
                searchField: _buildSearchField(l10n),
                chips: _CategoryChips(
                  selected: _category,
                  onSelect: (c) => setState(() => _category = c),
                ),
              ),
            ),
            // Grid hasil filter.
            ...listAsync.when(
              loading: () => [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 48, 16, 16),
                    child: Center(child: FCircularProgress()),
                  ),
                ),
              ],
              error: (_, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorBody(onRetry: _reload),
                ),
              ],
              data: (page) {
                final items = page.items;
                if (items.isEmpty) {
                  final hasQuery = _query.isNotEmpty ||
                      _category != CommunityCategory.semua;
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyBody(hasQuery: hasQuery),
                    ),
                  ];
                }
                return [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 8,
                            childAspectRatio: 0.7,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _OrgCard(org: items[i]),
                        childCount: items.length,
                      ),
                    ),
                  ),
                ];
              },
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations l10n) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    child: FTextField(
      control: FTextFieldControl.managed(
        onChange: (value) => _onSearchChanged(value.text),
      ),
      hint: l10n.communitySearchHint,
      clearable: (value) => value.text.isNotEmpty,
      prefixBuilder: (context, style, variants) => FTextField.prefixIconBuilder(
        context,
        style,
        variants,
        const Icon(FLucideIcons.search),
      ),
    ),
  );
}

/// Hero cover listing: gambar + gradient gelap + judul & subtitle overlay.
class _Hero extends StatelessWidget {
  const _Hero({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final coverHeight = ProfileIdentityHeader.coverHeightOf(
      ProfileHeaderVariant.compact,
      MediaQuery.sizeOf(context).width,
    );

    return SizedBox(
      height: coverHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/community/hero.webp', fit: BoxFit.cover),
          // Scrim ringan menyeluruh: cukup untuk ikon bar di atas cover;
          // kontras teks ditangani band kaca di bawah.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.4, 1.0],
                  colors: [
                    Color(0x40000000),
                    Color(0x14000000),
                    Color(0x33000000),
                  ],
                ),
              ),
            ),
          ),
          // Band kaca full-bleed di dasar hero (radius 0: menyatu cover).
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _GlassBand(
              bottomRadius: 0,
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.exploreCategoryKomunitas,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _GlassBand.foregroundOf(context),
                      height: 1.2,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    l10n.communityListSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.xs.copyWith(
                      color: _GlassBand.foregroundOf(context)
                          .withValues(alpha: 0.95),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Delegate pinned: search field + chip kategori menempel di bawah bar
/// melayang saat scroll. Latar opaque (tema) supaya item grid tak tembus.
class _SearchChipsHeader extends SliverPersistentHeaderDelegate {
  const _SearchChipsHeader({required this.searchField, required this.chips});

  final Widget searchField;
  final Widget chips;

  static const double _height = 100; // search 60 + chips 32 + gap 8

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.background,
      child: Column(children: [searchField, chips, const Gap(8)]),
    );
  }

  @override
  bool shouldRebuild(_SearchChipsHeader oldDelegate) => true;
}

/// Top 2 featured: Tim Kami, Sponsor Kami. Selalu tampil di atas,
/// tidak dipengaruhi filter kategori / pencarian.
class _FeaturedRow extends StatelessWidget {
  const _FeaturedRow({
    required this.l10n,
    required this.items,
    required this.onTap,
  });

  final AppLocalizations l10n;
  final List<CommunityOrg> items;
  final ValueChanged<CommunityOrg> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.communityFeaturedSection,
            style: theme.typography.body.xs.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(6),
          Row(
            children: [
              for (final (i, org) in items.indexed) ...[
                if (i > 0) const Gap(6),
                Expanded(
                  child: _FeaturedCard(org: org, onTap: () => onTap(org)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

String _coverAssetFor(CommunityOrg org) => switch (org.featuredKind) {
  'tim' => 'assets/images/community/tim.webp',
  'sponsor' => 'assets/images/community/sponsor.webp',
  _ => 'assets/images/placeholder_512.png',
};

/// Kartu featured: cover 2:1 rounded + nama overlay bawah.
/// Gaya beda dari kartu grid biasa.
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.org, required this.onTap});

  final CommunityOrg org;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              // 2:1 - lebih pendek dari 16:10 supaya dua kartu sejajar tak tinggi.
              aspectRatio: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (org.coverUrl != null && org.coverUrl!.isNotEmpty)
                      Image.network(
                        org.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Image.asset(_coverAssetFor(org), fit: BoxFit.cover),
                      )
                    else
                      Image.asset(_coverAssetFor(org), fit: BoxFit.cover),
                    // Band tipis di dasar kartu - opacity lebih ringan dari hero.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _GlassBand(
                        padding: const EdgeInsets.fromLTRB(8, 10, 8, 6),
                        alphas: const [0.0, 0.35, 0.55, 0.68],
                        child: Text(
                          org.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.body.xs.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _GlassBand.foregroundOf(context),
                            height: 1.25,
                          ),
                        ),
                      ),
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
}

/// Band memudar adaptif untuk teks di atas gambar.
///
/// Gradient alpha vertical: transparan di atas, pekat di bawah. Tanpa
/// BackdropFilter (blur tak terlihat jelas, tapi mahal 2 saveLayer per
/// band). Scrim ikut tema: light = putih + teks gelap, dark = hitam +
/// teks putih - teks WAJIB pakai [foregroundOf], jangan hardcode putih.
class _GlassBand extends StatelessWidget {
  const _GlassBand({
    required this.child,
    this.bottomRadius = 10,
    this.padding = const EdgeInsets.fromLTRB(8, 18, 8, 6),
    this.alphas = const [0.0, 0.78, 0.92, 0.96],
  });

  final Widget child;

  /// Radius sudut bawah (0 = menempel tepi, mis. hero full-bleed).
  final double bottomRadius;
  final EdgeInsets padding;

  /// Alpha 4-stop gradient (atas → bawah). Kartu featured pakai nilai
  /// lebih rendah supaya overlay tak pekat.
  final List<double> alphas;

  /// Warna teks di atas band: kebalikan scrim (gelap di light theme).
  static Color foregroundOf(BuildContext context) =>
      context.theme.colors.foreground;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : Colors.black;
    assert(alphas.length == 4, '_GlassBand butuh 4 alpha');
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.4, 0.7, 1.0],
          colors: [for (final a in alphas) base.withValues(alpha: a)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(bottomRadius),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelect});

  final CommunityCategory selected;
  final ValueChanged<CommunityCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      CommunityCategory.semua: l10n.communityCategoryAll,
      CommunityCategory.seni: l10n.communityCategorySeni,
      CommunityCategory.bahasa: l10n.communityCategoryBahasa,
      CommunityCategory.pendidikan: l10n.communityCategoryPendidikan,
      CommunityCategory.ukm: l10n.communityCategoryUkm,
      CommunityCategory.lain: l10n.communityCategoryLain,
    };
    // Pola chip kategori feed beranda: FBadge pill + GestureDetector,
    // baris scroll horizontal 32px.
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const Gap(6),
        itemBuilder: (context, i) {
          final category = labels.keys.elementAt(i);
          final isSelected = category == selected;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelect(category),
            child: FBadge(
              variant: isSelected
                  ? FBadgeVariant.primary
                  : FBadgeVariant.secondary,
              child: Text(labels[category]!),
            ),
          );
        },
      ),
    );
  }
}

/// Kartu komunitas di grid 3 kolom: foto 1:1 rounded (10px) + nama maks
/// 2 baris - seragam dengan UsahaCard dan PlaceCard.
class _OrgCard extends StatelessWidget {
  const _OrgCard({required this.org});

  final CommunityOrg org;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final titleStyle = theme.typography.body.xs.copyWith(
      fontWeight: FontWeight.w600,
      height: 1.25,
    );
    final titleHeight = (titleStyle.fontSize ?? 12) * 1.25 * 2;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push('/explore/komunitas/${org.slug}'),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _OrgCover(org: org),
                  ),
                  Positioned(
                    left: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.background.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _categoryLabel(l10n, org.category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (org.isVerified)
                    // Strip nempel pojok kanan-atas cover; rounded mengikuti
                    // sudut cover (kanan-atas 10) + kiri-bawah 6 supaya menyatu.
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.background.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.zero,
                          ),
                        ),
                        child: Icon(
                          FLucideIcons.check,
                          size: 12,
                          color: theme.colors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Gap(6),
            SizedBox(
              height: titleHeight,
              child: Text(
                org.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(AppLocalizations l10n, String id) => switch (id) {
    'seni' => l10n.communityCategorySeni,
    'bahasa' => l10n.communityCategoryBahasa,
    'pendidikan' => l10n.communityCategoryPendidikan,
    'ukm' => l10n.communityCategoryUkm,
    _ => l10n.communityCategoryLain,
  };
}

/// Cover kotak 1:1 untuk komunitas: foto URL bila ada, fallback placeholder.
class _OrgCover extends StatelessWidget {
  const _OrgCover({required this.org});

  final CommunityOrg org;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (org.logoUrl != null && org.logoUrl!.isNotEmpty) {
      return Image.network(
        org.logoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallback(theme),
      );
    }
    return _fallback(theme);
  }

  Widget _fallback(FThemeData theme) {
    // ponytail: proto - mock belum punya logo asli, pakai placeholder_512.
    // Saat data nyata: hapus fallback ini, logoUrl wajib terisi.
    return Image.asset('assets/images/placeholder_512.png', fit: BoxFit.cover);
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.hasQuery});

  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FLucideIcons.users,
            size: 40,
            color: theme.colors.mutedForeground,
          ),
          const Gap(10),
          Text(
            hasQuery ? l10n.communityOrgEmptyQuery : l10n.communityOrgEmpty,
            textAlign: TextAlign.center,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(
            hasQuery
                ? l10n.communityOrgEmptyQueryHint
                : l10n.communityOrgEmptyHint,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          FButton(
            variant: FButtonVariant.outline,
            onPress: () =>
                context.push(ExploreRouter.communityContribute.path),
            child: Text(l10n.communityContributeTitle),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
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
            l10n.communityLoadFailed,
            textAlign: TextAlign.center,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(4),
          Text(
            l10n.communityLoadFailedBody,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          FButton(
            variant: FButtonVariant.outline,
            onPress: () => onRetry(),
            child: Text(l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}
