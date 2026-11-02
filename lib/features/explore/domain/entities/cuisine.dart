import 'place.dart';

/// Satu hidangan cuisine dari API `/api/v1/culinary/cuisines`.
///
/// Beda dengan [Place]: tanpa koordinat (tidak masuk peta), punya
/// [ingredients] dan [servingSuggestion]. [PlaceImage] dipakai langsung
/// dari place.dart karena skemanya identik.
export 'place.dart' show PlaceImage;

/// Tempat/penjual yang menyediakan satu cuisine (dari link many-to-many).
class CuisinePlaceRef {
  const CuisinePlaceRef({
    required this.placeSlug,
    required this.placeName,
    this.availability = 'unknown',
    this.note,
  });

  final String placeSlug;
  final String placeName;

  /// `unknown` | `available` | `seasonal` | `unavailable`.
  final String availability;
  final String? note;
}

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
    this.places = const [],
  });

  final String id;
  final String slug;
  final String name;
  final String description;

  /// Sudah dinormalisasi DTO: entry `isMain` pertama yang menang,
  /// tanpa true = pertama dianggap main. Reuse skema images `places.json`.
  final List<PlaceImage> images;

  final List<String> ingredients;

  /// Daerah asal (`origin_region`). String kosong = tidak diisi.
  final String region;
  final List<String> tags;
  final String? servingSuggestion;
  final List<PlaceSource> sources;

  /// Tempat/penjual penyedia. Kosong di list, terisi di detail.
  final List<CuisinePlaceRef> places;

  /// Cover list. List kosong → null (placeholder).
  PlaceImage? get cover {
    for (final img in images) {
      if (img.isMain) return img;
    }
    return images.isEmpty ? null : images.first;
  }
}
