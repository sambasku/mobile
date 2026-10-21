import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../domain/entities/place.dart';
import '../providers/places_providers.dart';

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/explore');

/// Grid foto satu tempat, 3 kolom. Unggah foto belum hidup; tombolnya
/// menyiapkan tempat CTA di bawah grid.
class PlacePhotosPage extends ConsumerWidget {
  const PlacePhotosPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesProvider);
    final place = placesAsync.value?.where((p) => p.slug == slug).firstOrNull;

    return FScaffold(
      header: FHeader.nested(
        title: Text(place?.name ?? 'Foto'),
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
      ),
      childPad: false,
      child: Column(
        children: [
          Expanded(child: _body(context, placesAsync, place)),
          const _UploadBar(),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    AsyncValue<List<Place>?> placesAsync,
    Place? place,
  ) {
    if (place == null) {
      if (placesAsync.isLoading) return const _PhotosSkeleton();
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: FAlert(
            title: Text('Foto tidak ditemukan'),
            subtitle: Text(
              'Tempat ini belum punya foto, atau datanya gagal dimuat.',
            ),
          ),
        ),
      );
    }
    final images = place.images;
    if (images.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Belum ada foto untuk tempat ini.'),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: images.length,
      itemBuilder: (context, i) {
        final img = images[i];
        return GestureDetector(
          onTap: () => showImagePreview(
            context,
            urls: [for (final im in images) im.url],
            credits: [for (final im in images) im.attribution],
            initialIndex: i,
          ),
          child: CachedNetworkImageWithFallback(
            imageUrl: displayImageUrl(img.url, width: 480) ?? img.url,
            fallbackUrl: img.url,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}

class _UploadBar extends StatelessWidget {
  const _UploadBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: FButton(
          prefix: const Icon(FLucideIcons.camera),
          onPress: () => showFToast(
            context: context,
            title: const Text('Unggah foto belum bisa dipakai'),
            description: const Text(
              'Kami sedang menyiapkannya untuk tempat ini.',
            ),
          ),
          child: const Text('Unggah foto'),
        ),
      ),
    );
  }
}

class _PhotosSkeleton extends StatelessWidget {
  const _PhotosSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: 9,
      itemBuilder: (_, _) => ColoredBox(color: theme.colors.muted),
    );
  }
}
