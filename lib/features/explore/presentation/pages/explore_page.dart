import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forui/forui.dart'
    if (dart.library.io) 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/use_scroll_collapse.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../encyclopedia/encyclopedia_router.dart';
import '../../domain/explore_category.dart';
import '../../explore_router.dart';
import '../widgets/explore_map_hero.dart';

/// Tab Eksplorasi: hub kategori discovery Sambas.
class ExplorePage extends HookConsumerWidget {
  const ExplorePage({super.key});

  static const _menuColumns = 4;
  static const _menuIconSize = 48.0;
  static const _menuSpacing = 8.0;

  void _openCategory(BuildContext context, ExploreCategory cat) {
    unawaited(
      AnalyticsService.instance.logExploreCategoryTap(
        categoryId: cat.id,
        comingSoon: cat.comingSoon,
      ),
    );

    // Jembatan ke ensiklopedia: buka rute ensiklopedia penuh.
    if (cat.id == 'ensiklopedia') {
      context.push(EncyclopediaRouter.list.path);
      return;
    }

    context.push(ExploreRouter.category.path.replaceFirst(':id', cat.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scroll = useScrollController();
    final landscape =
        MediaQuery.widthOf(context) > MediaQuery.heightOf(context);
    // Hero pendek: grid kategori harus masuk viewport tanpa scroll panjang.
    // Subtitle overlay butuh height >= 130 (lihat ExploreMapHero).
    final maxHero = landscape ? 112.0 : 140.0;
    final minHero = landscape ? 48.0 : 56.0;
    final collapseDistance = maxHero - minHero;

    // Coming-soon disembunyikan default: tab Eksplorasi tampil 100% konten
    // aktif. Toggle sesi-lokal (tidak persist) - kesan pertama yang penting.
    final showComingSoon = useState(false);

    // Animation, bukan double: grid kategori tidak rebuild tiap frame scroll.
    // Hanya hero (AnimatedBuilder) yang ikut nilai collapse.
    final collapse = useScrollCollapse(
      scroll,
      distance: collapseDistance,
      duration: const Duration(milliseconds: 200),
    );

    // ponytail: heightFn di-invoke per frame di AnimatedBuilder, tanpa
    // AnimatedContainer (restart tween tiap tick scroll = jitter).
    Widget hero() => AnimatedBuilder(
      animation: collapse,
      builder: (context, _) {
        final t = collapse.value;
        final heroHeight = maxHero - t * collapseDistance;
        // Tanpa padding atas: header sudah pad bawah 6px (app.dart).
        // Padding lama 8 + SizedBox sama tinggi = overflow 8px.
        return ExploreMapHero(height: heroHeight);
      },
    );

    // Available dulu (urutan tetap), coming-soon di-append setelahnya -
    // toggle tidak pernah menggeser posisi kartu yang sudah aktif
    // (Acara dulunya loncat karena ada di list statis setelah Usaha).
    final available = ExploreCategory.all.where((c) => !c.comingSoon).toList();
    final soon = ExploreCategory.all.where((c) => c.comingSoon).toList();
    final categories = showComingSoon.value
        ? [...available, ...soon]
        : available;

    return Column(
      children: [
        const FHeader(
          title: BrandWordmark(),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        // Hero map yang mengecil saat scroll; di luar CustomScrollView
        // agar platform view MapLibre tidak ikut di-scroll. Tanpa
        // AnimatedContainer: nilai sudah scroll-proportional, tween tambahan
        // hanya bikin gerak mengejar dan platform view resize dobel.
        hero(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Ikon 48 + gap 6 + 2 baris label (~28).
              // Horizontal sudah dari Padding shell (app_router) - jangan dobel.
              const cellHeight = _menuIconSize + 6 + 28;
              final cellW =
                  (constraints.maxWidth - _menuSpacing * (_menuColumns - 1)) /
                  _menuColumns;
              final childAspectRatio = cellW / cellHeight;
              return CustomScrollView(
                controller: scroll,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 8),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _menuColumns,
                        mainAxisSpacing: _menuSpacing,
                        crossAxisSpacing: _menuSpacing,
                        childAspectRatio: childAspectRatio,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final cat = categories[index];
                        return _ExploreMenuTile(
                          category: cat,
                          iconSize: _menuIconSize,
                          onTap: () => _openCategory(context, cat),
                        );
                      }, childCount: categories.length),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: () {
                            AnalyticsService.instance.log(
                              'explore_coming_soon_toggle',
                              params: {
                                'show': showComingSoon.value ? 0 : 1,
                              },
                            );
                            showComingSoon.value = !showComingSoon.value;
                          },
                          child: FBadge(
                            variant: showComingSoon.value
                                ? FBadgeVariant.primary
                                : FBadgeVariant.outline,
                            child: Text(
                              showComingSoon.value
                                  ? l10n.exploreHideComingSoon
                                  : l10n.exploreShowComingSoon,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Menu kecil 4-kolom: ikon/cover mini + label (bukan kartu cover besar).
class _ExploreMenuTile extends StatelessWidget {
  const _ExploreMenuTile({
    required this.category,
    required this.onTap,
    required this.iconSize,
  });

  final ExploreCategory category;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final cover = category.coverAsset;

    return FTappable(
      onPress: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: cover != null
                      ? Image.asset(
                          cover,
                          width: iconSize,
                          height: iconSize,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                          errorBuilder: (_, _, _) => _IconBox(
                            icon: category.icon,
                            size: iconSize,
                          ),
                        )
                      : _IconBox(icon: category.icon, size: iconSize),
                ),
                if (category.comingSoon)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colors.background,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Gap(6),
          Text(
            category.titleOf(l10n),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w600,
              color: theme.colors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.secondary,
      child: Center(
        child: Icon(
          icon,
          size: size * 0.42,
          color: theme.colors.mutedForeground,
        ),
      ),
    );
  }
}
