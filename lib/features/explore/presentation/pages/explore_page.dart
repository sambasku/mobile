import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../core/widgets/theme_toggle_header_action.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../domain/explore_category.dart';
import '../../explore_router.dart';
import '../widgets/explore_map_hero.dart';

/// Tab Eksplorasi: hub kategori discovery Sambas.
class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  void _openCategory(BuildContext context, ExploreCategory cat) {
    unawaited(
      AnalyticsService.instance.logExploreCategoryTap(
        categoryId: cat.id,
        comingSoon: cat.comingSoon,
      ),
    );

    // Jembatan ke kamus: daftar kata A-Z (bukan coming-soon).
    if (cat.id == 'bahasa-budaya') {
      context.push(DictionaryRouter.list.path);
      return;
    }

    context.push(
      ExploreRouter.category.path.replaceFirst(':id', cat.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FHeader(
          title: BrandWordmark(),
          suffixes: [ThemeToggleHeaderAction()],
        ),
        // Expanded + LayoutBuilder: hero map di-clamp ke ruang tersisa supaya
        // landscape (tinggi pendek) tidak overflow Column.
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final landscape = constraints.maxWidth > constraints.maxHeight;
              // Portrait: poster ~248. Landscape: max ~38% tinggi, capped.
              final heroHeight = landscape
                  ? (constraints.maxHeight * 0.38).clamp(110.0, 160.0)
                  : 248.0;
              final crossAxisCount = landscape ? 3 : 2;

              return Column(
                children: [
                  // Map di luar ListView agar platform view tidak ikut di-scroll.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: ExploreMapHero(height: heroHeight),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 32),
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          // Nested GridView default-nya inset MediaQuery (status bar).
                          padding: EdgeInsets.zero,
                          itemCount: ExploreCategory.all.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: landscape ? 1.15 : 0.98,
                          ),
                          itemBuilder: (context, index) {
                            final cat = ExploreCategory.all[index];
                            return _CategoryCard(
                              category: cat,
                              onTap: () => _openCategory(context, cat),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(category.icon, size: 26, color: theme.colors.primary),
                  if (category.comingSoon) ...[
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Segera hadir',
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.sm.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: theme.colors.mutedForeground,
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
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        category.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.sm.copyWith(
                          fontSize: 11,
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
