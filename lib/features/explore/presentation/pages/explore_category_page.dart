import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../domain/explore_category.dart';
import '../../domain/sambas_map_config.dart';
import '../widgets/sambas_map_view.dart';

/// Detail kategori. Peta & Akses = MapLibre; Bahasa & Budaya = bridge kamus; lainnya segera hadir.
class ExploreCategoryPage extends StatelessWidget {
  const ExploreCategoryPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = ExploreCategory.byId(categoryId);
    final isPetaAkses = categoryId == 'peta-akses';
    final isBahasaBudaya = categoryId == 'bahasa-budaya';

    return FScaffold(
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
      child: isPetaAkses
          ? const _PetaAksesMap()
          : isBahasaBudaya
              ? const _BahasaBudayaBridge()
              : _ComingSoonBody(category: category),
    );
  }
}

class _PetaAksesMap extends StatelessWidget {
  const _PetaAksesMap();

  @override
  Widget build(BuildContext context) {
    return SambasMapView(
      initialCameraPosition: SambasMapConfig.fullscreenCamera,
      interactive: true,
      analyticsEntry: 'category',
      onMapCreated: (_) {
        unawaited(
          AnalyticsService.instance.logMapOpen(
            entry: 'category',
            mode: 'live',
          ),
        );
      },
      onFallbackTap: () {
        unawaited(
          AnalyticsService.instance.logMapOpen(
            entry: 'category',
            mode: 'poster',
          ),
        );
      },
    );
  }
}

class _BahasaBudayaBridge extends StatelessWidget {
  const _BahasaBudayaBridge();

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
              FLucideIcons.bookOpen,
              size: 48,
              color: theme.colors.primary,
            ),
            const Gap(16),
            Text(
              'Kamus hidup Sambas',
              style: theme.typography.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              'Jelajahi kosakata, makna, dan contoh kalimat bahasa Melayu Sambas.',
              textAlign: TextAlign.center,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(20),
            FButton(
              onPress: () => context.push(DictionaryRouter.list.path),
              child: const Text('Buka daftar kata A-Z'),
            ),
          ],
        ),
      ),
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
              style: theme.typography.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
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
              'Kami sedang menyiapkan konten untuk menjelajahi Sambas lebih dalam.',
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
