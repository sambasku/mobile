import '../../../../core/models/image_attribution.dart';
import '../../domain/entities/place.dart';

/// DTO satu Place di `places.json` (CDN repo `data`).
///
/// Parse defensif per WISATA_START.md: field wajib absen → item di-skip
/// (null), related kind tak dikenal di-skip, gambar tanpa https di-skip -
/// satu item rusak tidak mematikan seluruh koleksi.
class PlaceDto {
  const PlaceDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.type,
    required this.lat,
    required this.lng,
    required this.shortDescription,
    this.regionId,
    required this.images,
    required this.hours,
    required this.contact,
    required this.related,
    required this.sources,
  });

  final String id;
  final String slug;
  final String name;
  final PlaceCategory category;
  final PlaceType? type;
  final double lat;
  final double lng;
  final String shortDescription;
  final String? regionId;
  final List<PlaceImage> images;
  final String? hours;
  final String? contact;
  final List<PlaceRelated> related;
  final List<PlaceSource> sources;

  /// Null = field wajib absen/tidak valid → item di-skip.
  static PlaceDto? fromJson(Map<String, dynamic> json) {
    String? str(Object? key) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    final id = str('id');
    final slug = str('slug');
    final name = str('name');
    final category = PlaceCategory.values
        .where((c) => c.name == json['category'])
        .firstOrNull;
    final lat = (json['lat'] as num?)?.toDouble();
    final lng = (json['lng'] as num?)?.toDouble();
    final short = str('shortDescription');
    if (id == null ||
        slug == null ||
        name == null ||
        category == null ||
        lat == null ||
        lng == null ||
        short == null) {
      return null;
    }

    PlaceType? type;
    final rawType = json['type'];
    if (rawType is String) {
      type = PlaceType.values.where((t) => t.name == rawType).firstOrNull;
    }

    final images = <PlaceImage>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final raw in rawImages.whereType<Map>()) {
        final img = imageFromJson(Map<String, dynamic>.from(raw));
        if (img == null) continue;
        final hasMain = images.any((e) => e.isMain);
        // Normalisasi: tepat satu main - true pertama menang;
        // tanpa true sama sekali, elemen pertama dianggap main.
        images.add(
          PlaceImage(
            url: img.url,
            isMain: img.isMain && !hasMain || (!hasMain && images.isEmpty),
            attribution: img.attribution,
          ),
        );
      }
    }

    final related = <PlaceRelated>[];
    final rawRelated = json['related'];
    if (rawRelated is List) {
      for (final raw in rawRelated.whereType<Map>()) {
        final kind = PlaceRelatedKind.values
            .where((k) => k.name == raw['kind'])
            .firstOrNull;
        final rid = raw['id'];
        if (kind == null || rid is! String || rid.isEmpty) continue;
        related.add(PlaceRelated(kind: kind, id: rid));
      }
    }

    final sources = <PlaceSource>[];
    final rawSources = json['sources'];
    if (rawSources is List) {
      for (final raw in rawSources.whereType<Map>()) {
        final s = sourceFromJson(Map<String, dynamic>.from(raw));
        if (s != null) sources.add(s);
      }
    }

    return PlaceDto(
      id: id,
      slug: slug,
      name: name,
      category: category,
      type: category == PlaceCategory.wisata ? type : null,
      lat: lat,
      lng: lng,
      shortDescription: short,
      regionId: str('regionId'),
      images: images,
      hours: str('hours'),
      contact: str('contact'),
      related: related,
      sources: sources,
    );
  }

  /// Publik: dipakai juga CuisineDto (skema images cuisines.json sama).
  /// Null = entry gambar tidak valid (URL absen/bukan https) → di-skip.
  static PlaceImage? imageFromJson(Map<String, dynamic> json) {
    final url = json['url'];
    if (url is! String || !url.startsWith('https://')) return null;
    return PlaceImage(
      url: url,
      isMain: json['isMain'] == true,
      attribution: ImageAttribution.fromJson(json['attribution']),
    );
  }

  /// Publik: dipakai juga CuisineDto (skema sources cuisines.json sama).
  static PlaceSource? sourceFromJson(Map<String, dynamic> json) {
    String? str(Object? key) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    final name = str('name');
    final address = str('address');
    if (name == null || address == null) return null;
    return PlaceSource(
      name: name,
      type: str('type') ?? 'other',
      address: address,
      license: str('license'),
      licenseUrl: str('licenseUrl'),
    );
  }

  Place toEntity() => Place(
    id: id,
    slug: slug,
    name: name,
    category: category,
    type: type,
    lat: lat,
    lng: lng,
    shortDescription: shortDescription,
    regionId: regionId,
    images: images,
    hours: hours,
    contact: contact,
    related: related,
    sources: sources,
  );
}
