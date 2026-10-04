import '../../domain/entities/cuisine.dart';
import '../../domain/entities/place.dart';
import 'place_dto.dart';

/// DTO JSON `cuisines.json` di CDN (repo `data` via jsDelivr).
///
/// Parse defensif seperti PlaceDto: item tanpa field wajib di-skip -
/// satu item rusak tidak mematikan seluruh koleksi. `ingredients` dan
/// `tags` elemen non-string di-skip.
class CuisineDto {
  const CuisineDto({required this.cuisines});

  final List<CuisineDtoItem> cuisines;

  factory CuisineDto.fromJson(Map<String, dynamic> json) {
    final raw = json['cuisines'];
    final list = raw is List ? raw : const [];
    return CuisineDto(
      cuisines: list
          .whereType<Map>()
          .map((e) => CuisineDtoItem.fromJson(Map<String, dynamic>.from(e)))
          .whereType<CuisineDtoItem>()
          .toList(),
    );
  }

  List<Cuisine> toEntity() => cuisines.map((e) => e.toEntity()).toList();
}

/// DTO satu hidangan.
class CuisineDtoItem {
  const CuisineDtoItem({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.images,
    required this.ingredients,
    required this.region,
    required this.tags,
    required this.sources,
    this.servingSuggestion,
  });

  final String id;
  final String slug;
  final String name;
  final String description;
  final List<PlaceImage> images;
  final List<String> ingredients;
  final String region;
  final List<String> tags;
  final String? servingSuggestion;
  final List<PlaceSource> sources;

  /// Null = field wajib absen → item di-skip.
  static CuisineDtoItem? fromJson(Map<String, dynamic> json) {
    String? str(String key) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    final id = str('id');
    final slug = str('slug');
    final name = str('name');
    final description = str('description');
    final region = str('region');
    if (id == null ||
        slug == null ||
        name == null ||
        description == null ||
        region == null) {
      return null;
    }

    // Reuse parser image & source PlaceDto: skema atribusi sama.
    final images = <PlaceImage>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final raw in rawImages.whereType<Map>()) {
        final img = PlaceDto.imageFromJson(Map<String, dynamic>.from(raw));
        if (img == null) continue;
        final hasMain = images.any((e) => e.isMain);
        images.add(
          PlaceImage(
            url: img.url,
            isMain: img.isMain && !hasMain || (!hasMain && images.isEmpty),
            attribution: img.attribution,
          ),
        );
      }
    }

    String? optStr(String key) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    return CuisineDtoItem(
      id: id,
      slug: slug,
      name: name,
      description: description,
      images: images,
      ingredients: stringList(json['ingredients']),
      region: region,
      tags: stringList(json['tags']),
      servingSuggestion: optStr('servingSuggestion'),
      sources: parseSources(json['sources']),
    );
  }

  Cuisine toEntity() => Cuisine(
    id: id,
    slug: slug,
    name: name,
    description: description,
    images: images,
    ingredients: ingredients,
    region: region,
    tags: tags,
    servingSuggestion: servingSuggestion,
    sources: sources,
  );
}

/// List JSON ke `List<String>`, elemen lain di-skip.
List<String> stringList(Object? raw) => raw is List
    ? raw.whereType<String>().where((s) => s.trim().isNotEmpty).toList()
    : const [];

/// Reuse parser sources PlaceDto. Publik karena dipakai CuisineDto.
List<PlaceSource> parseSources(Object? rawSources) {
  final sources = <PlaceSource>[];
  if (rawSources is List) {
    for (final raw in rawSources.whereType<Map>()) {
      final s = PlaceDto.sourceFromJson(Map<String, dynamic>.from(raw));
      if (s != null) sources.add(s);
    }
  }
  return sources;
}
