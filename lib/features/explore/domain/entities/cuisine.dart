import 'place.dart';

/// Satu hidangan cuisine dari `cuisines.json` (CDN repo `data`).
///
/// Beda dengan [Place]: tanpa koordinat (tidak masuk peta), punya
/// [ingredients] dan [servingSuggestion]. [PlaceImage] dipakai langsung
/// dari place.dart karena skemanya identik.
export 'place.dart' show PlaceImage;
class Cuisine {
  const Cuisine({
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

  /// Sudah dinormalisasi DTO: entry `isMain` pertama yang menang,
  /// tanpa true = pertama dianggap main. Reuse skema images `places.json`.
  final List<PlaceImage> images;

  final List<String> ingredients;

  /// Asal daerah, mis. `Kota Sambas`.
  final String region;
  final List<String> tags;
  final String? servingSuggestion;
  final List<PlaceSource> sources;

  /// Cover list. List kosong → null (placeholder).
  PlaceImage? get cover {
    for (final img in images) {
      if (img.isMain) return img;
    }
    return images.isEmpty ? null : images.first;
  }
}
