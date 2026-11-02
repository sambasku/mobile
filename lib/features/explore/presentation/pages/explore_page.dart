import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forui/forui.dart'
    if (dart.library.io) 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/use_scroll_collapse.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../domain/explore_category.dart';
import '../../explore_router.dart';
import '../widgets/explore_cover_card.dart';
import '../widgets/explore_map_hero.dart';

/// Tab Eksplorasi: hub kategori discovery Sambas.
class ExplorePage extends HookConsumerWidget {
  const ExplorePage({super.key});

  void _openCategory(BuildContext context, ExploreCategory cat) {
    unawaited(
      AnalyticsService.instance.logExploreCategoryTap(
        categoryId: cat.id,
        comingSoon: cat.comingSoon,
      ),
    );

    // Jembatan ke kamus: kosakata di tab kamus (bukan coming-soon).
    if (cat.id == 'ensiklopedia') {
      context.push(DictionaryRouter.list.path);
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
    final maxHero = landscape ? 140.0 : 200.0;
    final minHero = landscape ? 50.0 : 70.0;
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
        return SizedBox(
          height: heroHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: ExploreMapHero(height: heroHeight),
          ),
        );
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
          child: CustomScrollView(
            controller: scroll,
            slivers: [
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  // Gap ketat: cover penuh sudah bedakan kartu; 12 + aspect
                  // tinggi terasa jarang setelah ikon dihapus.
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  // Lebih tinggi: foto + blok teks di bawah (bukan overlay).
                  childAspectRatio: landscape ? 0.95 : 0.78,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final cat = categories[index];
                  return _CategoryCard(
                    category: cat,
                    onTap: () => _openCategory(context, cat),
                  );
                }, childCount: categories.length),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: GestureDetector(
                      onTap: () {
                        AnalyticsService.instance.log(
                          'explore_coming_soon_toggle',
                          params: {'show': showComingSoon.value ? 0 : 1},
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
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final ExploreCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    return ExploreCoverCard(
      title: category.titleOf(l10n),
      onTap: onTap,
      coverAsset: category.coverAsset,
      // Ensiklopedia / Komunitas (segera): ikon kategori biar area foto
      // tidak kosong polos.
      placeholderIcon: category.coverAsset == null ? category.icon : null,
      badge: category.comingSoon
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.exploreComingSoon,
                maxLines: 1,
                style: theme.typography.body.sm.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: theme.colors.primaryForeground,
                ),
              ),
            )
          : null,
    );
  }
}
