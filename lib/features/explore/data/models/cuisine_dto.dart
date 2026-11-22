import '../../../../core/models/public_author_ref.dart';
import '../../domain/entities/cuisine.dart';
import '../../domain/entities/place.dart';
import 'place_dto.dart';
/// DTO kuliner dari API `/api/v1/culinary/cuisines`.
///
/// Menerima dua bentuk kunci: snake_case (wire API: `is_main`,
/// `origin_region`, `serving_suggestion`) dan camelCase lama
/// (`cuisines.json` CDN: `isMain`, `region`, `servingSuggestion`) supaya
/// seed lama dan test lama tetap jalan.
///
/// Parse defensif seperti PlaceDto: item tanpa field wajib di-skip -
/// satu item rusak tidak mematikan seluruh koleksi.
class CuisineDto {
  const CuisineDto({required this.cuisines});
  final List<CuisineDtoItem> cuisines;

  factory CuisineDto.fromJson(Map<String, dynamic> json) {
    final raw = json['cuisines'] ?? json['items'];
    final list = raw is List ? raw : const [];
    return CuisineDto(
      cuisines: list
          .whereType<Map>()
          .map((e) => CuisineDtoItem.fromJson(Map<String, dynamic>.from(e)))
          .whereType<CuisineDtoItem>()
          .toList(),
    );
  }

  /// Satu item wire API (bukan envelope).
  static CuisineDtoItem? itemFromJson(Map<String, dynamic> json) =>
      CuisineDtoItem.fromJson(json);

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
    this.usahas = const [],
    this.author,
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
  final List<CuisineUsahaRef> usahas;
  final PublicAuthorRef? author;

  /// Null = field wajib absen → item di-skip.
  static CuisineDtoItem? fromJson(Map<String, dynamic> json) {
    String? str(String key) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    String? optStr(String snake, String camel) => str(snake) ?? str(camel);

    final id = str('id');
    final slug = str('slug');
    final name = str('name');
    // API mengizinkan deskripsi null; CDN lama mewajibkannya.
    final description = optStr('description', 'description') ?? '';
    // Region API = `origin_region`, CDN lama = `region`.
    final region = optStr('origin_region', 'region') ?? '';
    if (id == null || slug == null || name == null) return null;

    // Reuse parser image & source PlaceDto: skema atribusi sama.
    final images = <PlaceImage>[];
    final rawImages = json['images'];
    if (rawImages is List) {
      for (final raw in rawImages.whereType<Map>()) {
        final map = Map<String, dynamic>.from(raw);
        final img = PlaceDto.imageFromJson(map);
        if (img == null) continue;
        final hasMain = images.any((e) => e.isMain);
        final isMain = map['is_main'] == true || map['isMain'] == true;
        images.add(
          PlaceImage(
            url: img.url,
            isMain: isMain && !hasMain || (!hasMain && images.isEmpty),
            attribution: img.attribution,
          ),
        );
      }
    }

    final usahas = <CuisineUsahaRef>[];
    final rawUsahas = json['usaha'] ?? json['usahas'] ?? json['places'];
    if (rawUsahas is List) {
      for (final raw in rawUsahas.whereType<Map>()) {
        final usahaSlug =
            raw['usaha_slug'] ?? raw['usahaSlug'] ?? raw['place_slug'] ?? raw['placeSlug'];
        final usahaName =
            raw['usaha_name'] ?? raw['usahaName'] ?? raw['place_name'] ?? raw['placeName'];
        if (usahaSlug is! String || usahaSlug.isEmpty) continue;
        final availability = raw['availability'];
        final note = raw['note'];
        usahas.add(
          CuisineUsahaRef(
            usahaSlug: usahaSlug,
            usahaName: usahaName is String && usahaName.isNotEmpty
                ? usahaName
                : usahaSlug,
            availability: availability is String && availability.isNotEmpty
                ? availability
                : 'unknown',
            note: note is String && note.trim().isNotEmpty ? note.trim() : null,
          ),
        );
      }
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
      servingSuggestion: optStr('serving_suggestion', 'servingSuggestion'),
      sources: parseSources(json['sources']),
      usahas: usahas,
      author: PublicAuthorRef.fromJson(json['author']),
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
    usahas: usahas,
    author: author,
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
      final map = Map<String, dynamic>.from(raw);
      final s = PlaceDto.sourceFromJson({
        ...map,
        // Wire API pakai license_url; CDN lama licenseUrl.
        'licenseUrl': map['license_url'] ?? map['licenseUrl'],
      });
      if (s != null) sources.add(s);
    }
  }
  return sources;
}