import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/forui_palette_controller.dart';
import '../../../../core/theme/forui_palettes.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/place.dart';
import '../../explore_router.dart';
import '../place_ui.dart';
import '../providers/places_providers.dart';
import '../widgets/sambas_map_pins.dart';

/// Peta pin Place full layar tanpa header. Data dari provider yang sama
/// dengan list. Tombol kembali melayang di semua state (loading/gagal juga).
///
/// Toggle tema di sini cuma untuk halaman peta: subtree dibungkus Theme +
/// FTheme sendiri, tema app tidak disentuh.
/// ponytail: pilihan tema peta tidak disimpan (reset saat halaman ditutup);
/// ganti tema me-remount map, tapi kamera dipulihkan (memori + prefs).
class PinsPage extends HookConsumerWidget {
  const PinsPage({super.key, this.focusSlug});

  final String? focusSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapBrightness = useState<Brightness?>(null);
    final reloadToken = useState(0);
    final brightness = mapBrightness.value ?? Theme.of(context).brightness;
    final palette =
        foruiPalettes[ref.watch(foruiPaletteControllerProvider)] ??
        foruiPalettes[defaultPalette]!;
    final fTheme =
        (brightness == Brightness.dark ? palette.dark : palette.light).touch;

    Future<void> refreshPlaces() async {
      // Hard miss L1 (fetch baru dari CDN), lalu tampilkan hasil terbaru.
      await ref.read(placesRefreshProvider.future);
      ref.invalidate(placesProvider);
    }

    return Theme(
      data: fTheme.toApproximateMaterialTheme(),
      child: FTheme(
        data: fTheme,
        child: Builder(
          builder: (context) => _build(
            context,
            ref,
            onToggleTheme: () =>
                mapBrightness.value = brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
            onRetryPlaces: () async {
              // Buang state provider (fetch ulang) + bikin instance map baru
              // lewat key, supaya tiles yang menggantung ikut dibuang.
              await refreshPlaces();
              reloadToken.value++;
            },
            reloadToken: reloadToken.value,
            refreshPlaces: refreshPlaces,
          ),
        ),
      ),
    );
  }

  Widget _build(
    BuildContext context,
    WidgetRef ref, {
    required VoidCallback onToggleTheme,
    required VoidCallback onRetryPlaces,
    required int reloadToken,
    required Future<void> Function() refreshPlaces,
  }) {
    final theme = context.theme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final placesAsync = ref.watch(placesProvider);
    final focusPlace = placesAsync.value
        ?.where((p) => p.slug == focusSlug)
        .firstOrNull;
    final floatingStyle = IconButton.styleFrom(
      backgroundColor: theme.colors.background,
      foregroundColor: theme.colors.foreground,
      elevation: 2,
      shadowColor: Colors.black26,
    );

    return FScaffold(
      childPad: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            Positioned.fill(
              child: Stack(
                children: [
                  placesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, _) => const _PinsError(),
                    data: (places) {
                      final list = places ?? const <Place>[];
                      // Daftar tempat kosong (slug salah, atau data belum
                      // ada): jangan tampilkan peta tanpa penjelasan.
                      if (list.isEmpty) {
                        return _PinsEmpty(onRetry: onRetryPlaces);
                      }
                      return SambasMapPins(
                        key: ValueKey('pins-map-$reloadToken'),
                        places: list,
                        initialPlace: focusPlace,
                        onRetryMap: onRetryPlaces,
                      );
                    },
                  ),
                  // Pull-to-refresh dari strip tipis di tepi atas. ponytail:
                  // RefreshIndicator butuh scrollable, peta bukan scrollable;
                  // strip sengaja tidak menutupi kolom tombol kiri dan kompas.
                  Positioned(
                    top: 0,
                    left: 64,
                    right: 64,
                    height: 44,
                    child: RefreshIndicator(
                      onRefresh: refreshPlaces,
                      child: const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Di atas tombol atribusi MapLibre (kiri bawah, margin 8): lisensi
            // OSM wajib tetap terlihat.
            if (focusPlace != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: MediaQuery.paddingOf(context).bottom + 40,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: _PlaceCard(place: focusPlace),
                  ),
                ),
              ),
            // Kolom kiri: kanan atas dipakai kompas MapLibre saat peta diputar.
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              left: 12,
              child: Column(
                children: [
                  IconButton(
                    tooltip: 'Kembali',
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go('/explore'),
                    style: floatingStyle,
                    icon: const Icon(FLucideIcons.arrowLeft, size: 20),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    tooltip: isDark ? 'Peta mode terang' : 'Peta mode gelap',
                    onPressed: onToggleTheme,
                    style: floatingStyle,
                    icon: Icon(
                      isDark ? FLucideIcons.sun : FLucideIcons.moon,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    tooltip: 'Muat ulang peta',
                    onPressed: onRetryPlaces,
                    style: floatingStyle,
                    icon: const Icon(FLucideIcons.refreshCw, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu tempat yang dibuka: foto, nama, label, dan link Google Maps.
/// Ketuk kartu = kembali ke detail.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place});

  static const _thumb = 64.0;

  final Place place;

  Future<void> _openMaps(BuildContext context) async {
    // Timeout: handler external di sebagian ROM bisa menggantung; tanpa ini
    // user tidak dapat umpan balik sama sekali.
    final ok = await launchUrl(
      placeGoogleMapsUri(place),
      mode: LaunchMode.externalApplication,
    ).timeout(const Duration(seconds: 8), onTimeout: () => false);
    if (!ok && context.mounted) {
      showFToast(
        context: context,
        title: const Text('Google Maps tidak bisa dibuka'),
        description: const Text('Coba lagi sebentar, ya.'),
      );
    }
  }

  void _openDetail(BuildContext context) => context.canPop()
      ? context.pop()
      : context.push(
          ExploreRouter.place.path.replaceFirst(':slug', place.slug),
          extra: 'map',
        );

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cover = place.cover;
    final radius = BorderRadius.circular(16);

    return Material(
      // Flat + border (tanpa shadow), konsisten kartu list.
      color: theme.colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: theme.colors.border),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox.square(
                  dimension: _thumb,
                  child: cover == null
                      ? ColoredBox(
                          color: theme.colors.muted,
                          child: Icon(
                            FLucideIcons.image,
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      : CachedNetworkImageWithFallback(
                          imageUrl:
                              displayImageUrl(cover.url, width: 200) ??
                              cover.url,
                          fallbackUrl: cover.url,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        FBadge(
                          variant: FBadgeVariant.secondary,
                          child: Text(
                            place.category == PlaceCategory.kuliner
                                ? 'Kuliner'
                                : 'Wisata',
                          ),
                        ),
                        if (placeTypeLabels[place.type] case final type?)
                          FBadge(
                            variant: FBadgeVariant.secondary,
                            child: Text(type),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FButton(
                      onPress: () => _openMaps(context),
                      size: FButtonSizeVariant.xs,
                      prefix: const Icon(FLucideIcons.navigation),
                      child: const Text('Lihat di Google Maps'),
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

class _PinsEmpty extends StatelessWidget {
  const _PinsEmpty({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FAlert(
              title: const Text('Belum ada tempat di peta'),
              subtitle: Text(
                'Daftar tempat masih kosong, atau datanya gagal dimuat.',
                style: context.theme.typography.sm,
              ),
            ),
            const SizedBox(height: 12),
            FButton(onPress: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}

class _PinsError extends StatelessWidget {
  const _PinsError();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FAlert(
          title: const Text('Peta tidak bisa dimuat'),
          subtitle: Text(
            'Periksa koneksi internetmu lalu coba lagi ya.',
            style: context.theme.typography.sm,
          ),
        ),
      ),
    );
  }
}
