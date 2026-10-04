import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forui/forui.dart'
    if (dart.library.io) 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/use_scroll_collapse.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../domain/explore_category.dart';
import '../../explore_router.dart';
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
    if (cat.id == 'tradisi') {
      context.push(DictionaryRouter.list.path);
      return;
    }

    context.push(ExploreRouter.category.path.replaceFirst(':id', cat.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scroll = useScrollController();
    final landscape =
        MediaQuery.widthOf(context) > MediaQuery.heightOf(context);
    final maxHero = landscape ? 140.0 : 200.0;
    final minHero = landscape ? 50.0 : 70.0;
    final collapseDistance = maxHero - minHero;

    final collapseProgress = useScrollCollapse(
      scroll,
      distance: collapseDistance,
      duration: const Duration(milliseconds: 200),
    );

    final heroHeight = maxHero - collapseProgress * collapseDistance;

    return Column(
      children: [
        const FHeader(
          title: BrandWordmark(),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        // Hero map yang mengecil saat scroll; di luar CustomScrollView
        // agar platform view MapLibre tidak ikut di-scroll.
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: heroHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: ExploreMapHero(height: heroHeight),
          ),
        ),
        Expanded(
          child: CustomScrollView(
            controller: scroll,
            slivers: [
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: landscape ? 1.15 : 0.98,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final cat = ExploreCategory.all[index];
                  return _CategoryCard(
                    category: cat,
                    onTap: () => _openCategory(context, cat),
                  );
                }, childCount: ExploreCategory.all.length),
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
    final theme = context.theme;

    return Material(
      color: theme.colors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(category.icon, size: 20, color: theme.colors.primary),
                  if (category.comingSoon) ...[
                    const Gap(6),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        // ponytail: FittedBox mengecilkan chip sampai muat;
                        // kalau nanti copy lebih panjang, ganti jadi 2 kata lain.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Segera hadir',
                              maxLines: 1,
                              style: theme.typography.sm.copyWith(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: theme.colors.primaryForeground,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.sm.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        category.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.sm.copyWith(
                          fontSize: 9,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
