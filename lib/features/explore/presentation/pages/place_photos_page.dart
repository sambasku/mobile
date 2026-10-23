import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../auth/auth_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../explore_router.dart';
import '../../domain/entities/place.dart';
import '../providers/places_providers.dart';

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/explore');

/// Grid foto satu tempat, 3 kolom (#187). Detail hanya membawa 12 foto
/// pertama; sisa halaman diambil lewat `next_offset` saat grid di-scroll.
class PlacePhotosPage extends ConsumerStatefulWidget {
  const PlacePhotosPage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<PlacePhotosPage> createState() => _PlacePhotosPageState();
}

class _PlacePhotosPageState extends ConsumerState<PlacePhotosPage> {
  /// `GALLERY_PAGE` di API (place.use-cases.ts).
  static const _detailPageSize = 12;

  final _scroll = ScrollController();
  final _extra = <PlaceImage>[];

  /// Offset halaman berikut; null = galeri habis.
  int? _nextOffset;
  bool _loading = false;
  bool _failed = false;
  String? _loadedSlug;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final left = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (left < 400) _loadMore();
  }

  /// Mulai paginasi dari halaman pertama detail (12 foto) saat slug berganti.
  void _reset(Place place) {
    if (_loadedSlug == widget.slug) return;
    _loadedSlug = widget.slug;
    _extra.clear();
    // Detail membawa maksimal 12 foto. Kurang dari itu = galeri sudah utuh,
    // tidak perlu request halaman kedua.
    _nextOffset = place.images.length < _detailPageSize ? null : _detailPageSize;
    _failed = false;
    _loadMore();
  }

  Future<void> _loadMore() async {
    final offset = _nextOffset;
    if (offset == null || _loading) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await ref
          .read(placesRepositoryProvider)
          .imagePage(widget.slug, offset: offset);
      if (!mounted) return;
      setState(() {
        final seen = {
          for (final img in _firstPageImages()) img.url,
        };
        _extra.addAll(page.items.where((img) => !seen.contains(img.url)));
        _nextOffset = page.nextOffset;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Sepulang dari halaman unggah: hard miss L1 katalog lalu ulang galeri.
  /// Detail (halaman pertama) diambil dari katalog yang baru difetch.
  Future<void> _refresh() async {
    try {
      await ref.read(placesRefreshProvider.future);
    } catch (_) {
      // gagal jaringan: biarkan galeri lama, user bisa muat ulang manual
    }
    if (!mounted) return;
    setState(() {
      _extra.clear();
      _loadedSlug = null;
      _nextOffset = null;
    });
  }

  /// Foto halaman pertama (dari detail) - dipakai untuk dedupe.
  List<PlaceImage> _firstPageImages() {
    final places = ref.read(placesProvider).value;
    final place = places?.where((p) => p.slug == widget.slug).firstOrNull;
    return place?.images ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(placesProvider);
    final place = placesAsync.value
        ?.where((p) => p.slug == widget.slug)
        .firstOrNull;
    if (place != null) {
      // Jadwalkan setelah frame: _reset memanggil setState lewat _loadMore.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reset(place);
      });
    }
    final guest = ref.watch(authStatusProvider).value?.isAuth != true;

    return FScaffold(
      header: FHeader.nested(
        title: Text(place?.name ?? 'Foto'),
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
      ),
      childPad: false,
      child: Column(
        children: [
          Expanded(child: _body(context, placesAsync, place)),
          _UploadBar(slug: widget.slug, guest: guest, onReturned: _refresh),
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
    final images = [...place.images, ..._extra];
    if (images.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Belum ada foto untuk tempat ini.'),
        ),
      );
    }
    final footer = _loading
        ? 3
        : _failed
        ? 3
        : 0;
    return GridView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: images.length + footer,
      itemBuilder: (context, i) {
        if (i >= images.length) {
          if (_failed && i == images.length) {
            return Center(
              child: FButton(
                variant: .outline,
                onPress: _loadMore,
                child: const Text('Coba lagi'),
              ),
            );
          }
          return const ColoredBox(color: Colors.transparent);
        }
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
  const _UploadBar({
    required this.slug,
    required this.guest,
    required this.onReturned,
  });

  final String slug;

  /// #187: foto wisata tampil di feed publik -> tamu diarahkan login.
  final bool guest;

  /// Dipanggil setelah halaman unggah ditutup (foto baru sudah di server).
  final Future<void> Function() onReturned;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: FButton(
          prefix: const Icon(FLucideIcons.camera),
          onPress: () async {
            await context.push(
              guest
                  ? AuthRouter.login.path
                  : ExploreRouter.placeAddPhoto.path.replaceFirst(':slug', slug),
            );
            if (!guest) await onReturned();
          },
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
