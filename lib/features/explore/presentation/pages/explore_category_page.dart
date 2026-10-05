import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../domain/explore_category.dart';
import '../pages/cuisine_list_page.dart';
import '../pages/place_list_page.dart';
import '../pages/wilayah_page.dart';

/// Detail kategori. Wisata/Cuisine = daftar Place; lainnya segera hadir.
class ExploreCategoryPage extends StatelessWidget {
  const ExploreCategoryPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = ExploreCategory.byId(categoryId);
    final isWisata = categoryId == 'wisata';

    return isWisata
        ? const PlaceListPage(mode: PlacePageMode.wisata)
        : categoryId == 'kuliner'
        ? const CuisineListPage()
        : categoryId == 'wilayah'
        ? const WilayahPage()
        : FScaffold(
            childPad: false,
            header: FHeader.nested(
              title: Text(category?.title ?? 'Eksplorasi'),
              prefixes: [
                FHeaderAction.back(
                  onPress: () =>
                      context.canPop() ? context.pop() : context.go('/explore'),
                ),
              ],
            ),
            child: _ComingSoonBody(category: category),
          );
  }
}

class _ComingSoonBody extends StatelessWidget {
  const _ComingSoonBody({required this.category});

  final ExploreCategory? category;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category?.icon ?? FLucideIcons.compass,
              size: 48,
              color: theme.colors.primary,
            ),
            const Gap(16),
            FBadge(
              variant: FBadgeVariant.outline,
              child: const Text('Segera hadir'),
            ),
            const Gap(12),
            Text(
              category?.title ?? 'Kategori',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              category?.subtitle ?? 'Kategori ini belum tersedia.',
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(12),
            Text(
              'Kami sedang menyiapkan kontennya. Balik lagi nanti ya.',
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
