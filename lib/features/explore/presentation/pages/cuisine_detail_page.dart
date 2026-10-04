import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/cuisine.dart';
import '../providers/cuisine_providers.dart';

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/explore');

/// Detail satu cuisine: hero gambar + atribusi, deskripsi, bahan,
/// cara penyajian, dan section "Sumber" bila sources[] terisi.
class CuisineDetailPage extends ConsumerWidget {
  const CuisineDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuisineAsync = ref.watch(cuisineProvider);
    final item = cuisineAsync.value?.where((k) => k.slug == slug).firstOrNull;
    if (item != null) return _Body(item: item);

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
      ),
      child: cuisineAsync.isLoading ? const _Skeleton() : const _ErrorBody(),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Bone(width: double.infinity),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(width: 240, height: 26),
                Gap(10),
                Bone(width: 120, height: 22),
                Gap(16),
                Bone(width: double.infinity, height: 16),
                Gap(6),
                Bone(width: double.infinity, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: FAlert(
          title: const Text('Konten tidak ditemukan'),
          subtitle: Text(
            'Datanya mungkin belum terpasang atau jaringanmu sedang bermasalah.',
            style: context.theme.typography.sm,
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.item});

  final Cuisine item;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final topInset = MediaQuery.paddingOf(context).top;

    return FScaffold(
      childPad: false,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _Hero(images: item.images),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: theme.typography.xl.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const Gap(8),
                    FBadge(
                      variant: FBadgeVariant.secondary,
                      child: Text(item.region),
                    ),
                    const Gap(12),
                    Text(
                      item.description,
                      style: theme.typography.sm.copyWith(height: 1.5),
                    ),
                    if (item.ingredients.isNotEmpty) ...[
                      const Gap(20),
                      Text(
                        'Bahan',
                        style: theme.typography.md.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final bahan in item.ingredients)
                            FBadge(
                              variant: FBadgeVariant.outline,
                              child: Text(bahan),
                            ),
                        ],
                      ),
                    ],
                    if (item.servingSuggestion != null) ...[
                      const Gap(20),
                      Text(
                        'Cara menyajikan',
                        style: theme.typography.md.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        item.servingSuggestion!,
                        style: theme.typography.sm.copyWith(height: 1.5),
                      ),
                    ],
                    if (item.sources.isNotEmpty) ...[
                      const Gap(20),
                      for (final s in item.sources)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _CreditLine(
                            label: 'Sumber',
                            name: s.name,
                            nameUrl: s.address,
                            license: s.license,
                            licenseUrl: s.licenseUrl,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: topInset + 8,
            left: 12,
            child: _HeroButton(
              icon: const Icon(FLucideIcons.arrowLeft, size: 20),
              tooltip: 'Kembali',
              onTap: () => _back(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        foregroundColor: Colors.white,
      ),
      icon: icon,
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.images});

  final List<PlaceImage> images;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    if (images.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 10,
        child: ColoredBox(
          color: theme.colors.muted,
          child: Icon(
            FLucideIcons.image,
            size: 48,
            color: theme.colors.mutedForeground,
          ),
        ),
      );
    }

    final img = images.first;
    final attribution = img.attribution;

    final hero = AspectRatio(
      aspectRatio: 16 / 10,
      child: CachedNetworkImageWithFallback(
        imageUrl: displayImageUrl(img.url, width: 1200) ?? img.url,
        fallbackUrl: img.url,
        fit: BoxFit.cover,
      ),
    );

    if (attribution == null) return hero;
    return Column(
      children: [
        hero,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: _CreditLine(
            label: 'Foto',
            name: attribution.name,
            nameUrl: attribution.url,
            license: attribution.license,
            licenseUrl: attribution.licenseUrl,
          ),
        ),
      ],
    );
  }
}

void _open(String? url) {
  final uri = url == null ? null : Uri.tryParse(url);
  if (uri == null || !uri.isScheme('https')) return;
  // Timeout: handler external di sebagian ROM bisa menggantung.
  launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  ).timeout(const Duration(seconds: 8), onTimeout: () => false);
}

/// Kredit satu baris: "Label: nama · lisensi". Nama & lisensi bisa di-tap.
class _CreditLine extends StatelessWidget {
  const _CreditLine({
    required this.label,
    required this.name,
    this.nameUrl,
    this.license,
    this.licenseUrl,
  });

  final String label;
  final String name;
  final String? nameUrl;
  final String? license;
  final String? licenseUrl;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final muted = theme.typography.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    final license = this.license;

    return Row(
      children: [
        Text('$label: ', style: muted),
        Flexible(
          child: GestureDetector(
            onTap: () => _open(nameUrl),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: muted.copyWith(
                color: theme.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        if (license != null) ...[
          Text(' · ', style: muted),
          GestureDetector(
            onTap: () => _open(licenseUrl),
            child: Text(
              license,
              style: muted.copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ],
    );
  }
}
