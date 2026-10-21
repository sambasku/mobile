import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../core/widgets/image_preview.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../core/models/image_attribution.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../../about/presentation/providers/contributors_providers.dart';
import '../../domain/entities/place.dart';
import '../../explore_router.dart';
import '../place_ui.dart';
import '../providers/places_providers.dart';
import '../providers/regions_providers.dart';

const _heroAspect = 16 / 10;

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/explore');

/// Detail satu Place: hero carousel full-bleed + atribusi, badge kategori/type,
/// info jam/kontak, deskripsi, "Lihat di peta", "Dekat sini" (related place),
/// dan section "Sumber" bila sources[] terisi (kredit CC wajib tampil).
class PlaceDetailPage extends ConsumerWidget {
  const PlaceDetailPage({super.key, required this.slug, this.entry = 'list'});

  final String slug;

  /// `list | map | pin | link` - param analytics poi_open.
  final String entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placesAsync = ref.watch(placesProvider);
    final place = placesAsync.value?.where((p) => p.slug == slug).firstOrNull;
    if (place != null) return _Body(place: place, entry: entry);

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
      ),
      child: placesAsync.isLoading ? const _Skeleton() : const _ErrorBody(),
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
            aspectRatio: _heroAspect,
            child: Bone(width: double.infinity),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Bone(width: 240, height: 26),
                Gap(10),
                Bone(
                  width: 120,
                  height: 22,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
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

class _Body extends StatefulWidget {
  const _Body({required this.place, required this.entry});

  final Place place;
  final String entry;

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  @override
  void initState() {
    super.initState();
    // Log poi_open sekali saat detail tampil.
    Future<void>.microtask(() {
      if (!mounted) return;
      unawaited(
        AnalyticsService.instance.logPoiOpen(
          slug: widget.place.slug,
          category: widget.place.category.name,
          entry: widget.entry,
        ),
      );
    });
  }

  Future<void> _share(BuildContext buttonContext) async {
    final place = widget.place;
    final link =
        placePublicUrl(place.slug) ?? placeGoogleMapsUri(place)?.toString();
    final box = buttonContext.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        text: '${place.name}\n${place.shortDescription}\n\n$link',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final place = widget.place;
    final topInset = MediaQuery.paddingOf(context).top;

    Widget heroButton(IconData icon, String tooltip, VoidCallback onTap) =>
        IconButton(
          tooltip: tooltip,
          onPressed: onTap,
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withValues(alpha: 0.4),
            foregroundColor: Colors.white,
          ),
          icon: Icon(icon, size: 20),
        );

    return FScaffold(
      childPad: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _Carousel(images: place.images),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: theme.typography.xl.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const Gap(8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          FBadge(
                            variant: FBadgeVariant.secondary,
                            child: Text(switch (place.category) {
                              PlaceCategory.kuliner => 'Kuliner',
                              PlaceCategory.budaya => 'Budaya',
                              PlaceCategory.wisata => 'Wisata',
                            }),
                          ),
                          if (placeTypeLabels[place.type] case final type?)
                            FBadge(
                              variant: FBadgeVariant.secondary,
                              child: Text(type),
                            ),
                        ],
                      ),
                      if (place.hours != null ||
                          place.contact?.isEmpty == false) ...[
                        const Gap(12),
                        _InfoStrip(hours: place.hours, contact: place.contact),
                      ],
                      const Gap(12),
                      Text(
                        place.shortDescription,
                        style: theme.typography.sm.copyWith(height: 1.5),
                      ),
                      if (place.images.length > 1)
                        _PhotoGrid(slug: place.slug, images: place.images),
                      // Kredit penulis artikel (v2): authorId -> kontributor SambasKu;
                      // tap buka profil in-app. Absen/offline = tanpa baris.
                      Consumer(
                        builder: (context, ref, _) {
                          final authorId = place.authorId;
                          if (authorId == null) {
                            return const SizedBox.shrink();
                          }
                          final username = ref
                              .watch(contributorsIdToUsernameProvider)
                              .value?[authorId];
                          if (username == null) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: _CreditLine(
                              label: 'Penulis',
                              name: username,
                              authorId: authorId,
                            ),
                          );
                        },
                      ),
                      const Gap(16),
                      FTileGroup(
                        label: const Text('Aksi'),
                        children: [
                          FTile(
                            prefix: const Icon(FLucideIcons.map, size: 18),
                            title: const Text('Lihat di peta'),
                            suffix: const Icon(
                              FLucideIcons.chevronRight,
                              size: 16,
                            ),
                            onPress: () {
                              if (!place.hasCoordinates) {
                                showPlaceNoCoordinates(context);
                                return;
                              }
                              context.push(
                                '${ExploreRouter.pins.path}?slug=${place.slug}',
                              );
                            },
                          ),
                          FTile(
                            prefix: const Icon(FLucideIcons.pencil, size: 18),
                            title: const Text('Usulkan perubahan'),
                            suffix: const Icon(
                              FLucideIcons.chevronRight,
                              size: 16,
                            ),
                            onPress: () => context.push(
                              ExploreRouter.placeEdit.path.replaceFirst(
                                ':slug',
                                place.slug,
                              ),
                            ),
                          ),
                          FTile(
                            prefix: const Icon(FLucideIcons.image, size: 18),
                            title: const Text('Tambah foto'),
                            suffix: const Icon(
                              FLucideIcons.chevronRight,
                              size: 16,
                            ),
                            onPress: () => context.push(
                              ExploreRouter.placeAddPhoto.path.replaceFirst(
                                ':slug',
                                place.slug,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _NearbyWisata(place: place),
                if (place.sources.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SourcesCard(sources: place.sources),
                  ),
              ],
            ),
            // ponytail: tombol overlay tetap di atas saat scroll; status bar
            // ikon putih ikut terlihat di atas konten putih. Kalau mengganggu,
            // ganti ke SliverAppBar pinned yang berubah warna saat collapse.
            Positioned(
              top: topInset + 8,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  heroButton(
                    FLucideIcons.arrowLeft,
                    'Kembali',
                    () => _back(context),
                  ),
                  const Spacer(),
                  heroButton(
                    FLucideIcons.bookmark,
                    'Bookmark',
                    () => showPlaceBookmarkSoon(context),
                  ),
                  const Gap(8),
                  Builder(
                    builder: (buttonContext) => heroButton(
                      FLucideIcons.share2,
                      'Bagikan',
                      () => _share(buttonContext),
                    ),
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

class _Carousel extends StatefulWidget {
  const _Carousel({required this.images});

  final List<PlaceImage> images;

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    if (widget.images.isEmpty) {
      return AspectRatio(
        aspectRatio: _heroAspect,
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

    final attribution = widget.images[_index].attribution;

    final hero = AspectRatio(
      aspectRatio: _heroAspect,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final img = widget.images[i];
              return GestureDetector(
                onTap: () => showImagePreview(
                  context,
                  urls: [for (final im in widget.images) im.url],
                  credits: [for (final im in widget.images) im.attribution],
                  initialIndex: i,
                ),
                child: CachedNetworkImageWithFallback(
                  imageUrl: displayImageUrl(img.url, width: 1200) ?? img.url,
                  fallbackUrl: img.url,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          // Gradasi atas supaya tombol overlay & status bar tetap terbaca.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment(0, -0.3),
                  colors: [Colors.black45, Colors.transparent],
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${_index + 1}/${widget.images.length}',
                  style: theme.typography.xs.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (attribution == null) return hero;
    final where = attribution.source != null
        ? shareSourceLabel(attribution.source!)
        : shareProviderLabel(attribution.provider);
    return Column(
      children: [
        hero,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: _CreditLine(
            label: 'Foto',
            name: attribution.name,
            nameUrl: attribution.url,
            suffix: where.isEmpty ? null : ' / $where',
            license: attribution.license,
            licenseUrl: attribution.licenseUrl,
            authorId: attribution.authorId,
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
    withUnsplashUtm(uri),
    mode: LaunchMode.externalApplication,
  ).timeout(const Duration(seconds: 8), onTimeout: () => false);
}

/// Kredit satu baris: "Label: nama[suffix] · lisensi". Nama boleh terpotong,
/// lisensi tetap utuh (kredit CC wajib terbaca). Nama & lisensi bisa di-tap.
class _CreditLine extends ConsumerWidget {
  const _CreditLine({
    required this.label,
    required this.name,
    this.nameUrl,
    this.suffix,
    this.license,
    this.licenseUrl,
    this.authorId,
  });

  final String label;
  final String name;
  final String? nameUrl;
  final String? suffix;
  final String? license;
  final String? licenseUrl;
  final String? authorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onTap: () {
              if (authorId != null) {
                // Profil SambasKu in-app: resolve authorId → username
                final username = ref
                    .watch(contributorsIdToUsernameProvider)
                    .value?[authorId];
                if (username != null) {
                  UserProfileRouter.open(context, username, displayName: name);
                  return;
                }
              }
              _open(nameUrl);
            },
            child: Text(
              '$name${suffix ?? ''}',
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

/// Jam buka, telepon, dan email. Baris kosong tidak dirender.
class _InfoStrip extends StatelessWidget {
  const _InfoStrip({this.hours, this.contact});

  final String? hours;
  final PlaceContact? contact;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final rows = <({IconData icon, String value, String caption, Uri? uri})>[
      if (hours != null && hours!.trim().isNotEmpty)
        (
          icon: FLucideIcons.clock,
          value: hours!.trim(),
          caption: 'Jam buka',
          uri: null,
        ),
      if (contact?.phone case final phone?)
        (
          icon: FLucideIcons.phone,
          value: phone,
          caption: 'Telepon',
          uri: Uri.parse('tel:${phone.replaceAll(' ', '')}'),
        ),
      if (contact?.email case final email?)
        (
          icon: FLucideIcons.mail,
          value: email,
          caption: 'Email',
          uri: Uri(scheme: 'mailto', path: email),
        ),
      if (contact?.note case final note?)
        (icon: FLucideIcons.phone, value: note, caption: 'Kontak', uri: null),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      // InkWell butuh ancestor Material. Forui tidak menyediakannya.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            for (final (i, row) in rows.indexed) ...[
              if (i > 0) Divider(height: 1, color: theme.colors.border),
              InkWell(
                onTap: row.uri == null
                    ? null
                    : () {
                        launchUrl(
                          row.uri!,
                          mode: LaunchMode.externalApplication,
                        ).timeout(
                          const Duration(seconds: 8),
                          onTimeout: () => false,
                        );
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(row.icon, size: 16, color: theme.colors.primary),
                      const Gap(8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              row.value,
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                            Text(
                              row.caption,
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
            ],
          ],
        ),
      ),
    );
  }
}

/// Pratinjau 3 foto. Sisanya dibuka di halaman linimasa.
class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.slug, required this.images});

  static const _previewCount = 3;

  final String slug;
  final List<PlaceImage> images;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final shown = images.length <= _previewCount
        ? images
        : images.sublist(0, _previewCount);
    final hidden = images.length - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(12),
        Text(
          'Foto',
          style: theme.typography.md.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // Tanpa ini GridView memakai padding status bar, jadi judul
          // "Foto" terlihat jauh dari gambar.
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: shown.length,
          itemBuilder: (context, i) {
            final img = shown[i];
            return GestureDetector(
              onTap: () => showImagePreview(
                context,
                urls: [for (final im in images) im.url],
                credits: [for (final im in images) im.attribution],
                initialIndex: i,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImageWithFallback(
                  imageUrl: displayImageUrl(img.url, width: 360) ?? img.url,
                  fallbackUrl: img.url,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
        if (hidden > 0) ...[
          const Gap(8),
          GestureDetector(
            onTap: () => context.push(ExploreRouter.placePhotosPath(slug)),
            child: Text(
              'Lihat $hidden foto lainnya',
              style: theme.typography.sm.copyWith(
                color: theme.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SourcesCard extends StatelessWidget {
  const _SourcesCard({required this.sources});

  final List<PlaceSource> sources;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(20),
        Text(
          'Sumber',
          style: theme.typography.md.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, source) in sources.indexed) ...[
                if (i > 0) Divider(height: 1, color: theme.colors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: _SourceRow(source: source),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Satu sumber di dalam kartu. Judul "Sumber" sudah di parent,
/// jadi baris ini hanya nama dan lisensi, masing-masing satu baris.
class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.source});

  final PlaceSource source;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final muted = theme.typography.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    final license = source.license;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _open(source.address),
          child: Text(
            source.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: muted.copyWith(
              color: theme.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (license != null) ...[
          const Gap(2),
          GestureDetector(
            onTap: () => _open(source.licenseUrl),
            child: Text(
              license,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: muted.copyWith(decoration: TextDecoration.underline),
            ),
          ),
        ],
      ],
    );
  }
}

/// Wisata lain di kecamatan yang sama. Kosong kalau region belum ada
/// atau tidak ada tempat wisata lain di sana.
class _NearbyWisata extends ConsumerWidget {
  const _NearbyWisata({required this.place});

  static const _cardWidth = 136.0;

  final Place place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionId = place.regionId;
    if (regionId == null) return const SizedBox.shrink();

    final theme = context.theme;
    final places = ref.watch(placesProvider).value ?? const <Place>[];
    final nearby = [
      for (final other in places)
        if (other.regionId == regionId &&
            other.category == PlaceCategory.wisata &&
            other.slug != place.slug)
          other,
    ]..sort((a, b) => a.name.compareTo(b.name));
    if (nearby.isEmpty) return const SizedBox.shrink();

    final regionName = ref
        .watch(regionsProvider)
        .value
        ?.where((r) => r.id == regionId)
        .firstOrNull
        ?.name;
    final title = regionName == null
        ? 'Wisata lain di kecamatan ini'
        : 'Wisata lain di $regionName';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: theme.typography.md.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const Gap(8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          // Inset ikut konten, bukan gutter tetap. Kartu pertama sejajar
          // judul; saat digeser, kartu boleh sampai ke tepi layar.
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, t) in nearby.indexed) ...[
                if (i > 0) const Gap(12),
                _relatedCard(context, t),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _relatedCard(BuildContext context, Place t) {
    final theme = context.theme;
    final cover = t.cover;
    return SizedBox(
      width: _cardWidth,
      child: GestureDetector(
        onTap: () => context.push(
          ExploreRouter.place.path.replaceFirst(':slug', t.slug),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: cover == null
                    ? ColoredBox(color: theme.colors.muted)
                    : CachedNetworkImageWithFallback(
                        imageUrl:
                            displayImageUrl(cover.url, width: 400) ?? cover.url,
                        fallbackUrl: cover.url,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const Gap(8),
            Text(
              t.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
