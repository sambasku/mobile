import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../domain/explore_category.dart';
import '../../domain/entities/place.dart';
import '../../domain/sambas_map_config.dart';
import '../../explore_router.dart';
import '../place_ui.dart';
import '../providers/places_providers.dart';
import '../pages/place_list_page.dart';
import '../widgets/sambas_map_view.dart';

/// Detail kategori. Peta & Akses = MapLibre; Bahasa & Budaya = bridge kamus;
/// Wisata & Kuliner = daftar Place; lainnya segera hadir.
class ExploreCategoryPage extends StatelessWidget {
  const ExploreCategoryPage({super.key, required this.categoryId});

  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final category = ExploreCategory.byId(categoryId);
    final isPetaAkses = categoryId == 'peta-akses';
    final isBahasaBudaya = categoryId == 'bahasa-budaya';
    final isWisataKuliner = categoryId == 'wisata-kuliner';

    return isWisataKuliner
        ? const PlaceListPage()
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
    return Column(
      children: [
        // Peta ~40% atas; sisanya daftar tempat (tap = detail).
        SizedBox(
          height: MediaQuery.heightOf(context) * 0.4,
          child: SambasMapView(
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
          ),
        ),
        // Tombol buka peta penuh menumpuk di bawah peta.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: FButton(
              size: FButtonSizeVariant.sm,
              prefix: const Icon(FLucideIcons.maximize),
              onPress: () => context.push(ExploreRouter.pins.path),
              child: const Text('Buka peta penuh'),
            ),
          ),
        ),
        const Expanded(child: _PlaceListCompact()),
      ],
    );
  }
}

/// Daftar Place ringkas di bawah peta kategori Peta & Akses.
class _PlaceListCompact extends ConsumerWidget {
  const _PlaceListCompact();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider).value ?? const <Place>[];

    if (places.isEmpty) {
      return Center(
        child: Text(
          'Belum ada tempat yang bisa ditampilkan.',
          style: context.theme.typography.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: places.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) => _PlaceListTile(place: places[i]),
    );
  }
}

/// Tile list 88px, mirip card di Wisata & Kuliner (tanpa filter/search).
class _PlaceListTile extends StatelessWidget {
  const _PlaceListTile({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cover = place.cover;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => context.push(
          ExploreRouter.place.path.replaceFirst(':slug', place.slug),
          extra: 'map',
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: 88,
                  child: cover == null
                      ? ColoredBox(
                          color: theme.colors.muted,
                          child: Icon(
                            place.category == PlaceCategory.kuliner
                                ? FLucideIcons.utensilsCrossed
                                : FLucideIcons.landmark,
                            size: 32,
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      : CachedNetworkImageWithFallback(
                          imageUrl:
                              displayImageUrl(cover.url, width: 240) ??
                              cover.url,
                          fallbackUrl: cover.url,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      placeLabel(place),
                      style: theme.typography.xs.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colors.primary,
                      ),
                    ),
                    Text(
                      place.shortDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            Icon(FLucideIcons.bookOpen, size: 48, color: theme.colors.primary),
            const Gap(16),
            Text(
              'Kamus hidup Sambas',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
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
