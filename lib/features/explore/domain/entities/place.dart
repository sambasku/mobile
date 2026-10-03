import '../../../../core/models/image_attribution.dart';

/// Kategori Place. Satu koleksi, dibedakan category (WISATA_START.md).
enum PlaceCategory { wisata, kuliner }

/// Type hanya untuk wisata; kuliner null.
enum PlaceType { sejarah, alam, budaya, pantai, belanja }

/// Kind relasi generik. Kind di luar daftar ini di-skip parser
/// (hidup otomatis saat article/event/umkm ship, tanpa refactor).
enum PlaceRelatedKind { word, place }

class PlaceImage {
  const PlaceImage({required this.url, required this.isMain, this.attribution});

  final String url;

  /// Cover list/peta. Kosong/absen = elemen pertama dianggap main.
  final bool isMain;

  /// Null = foto milik sendiri, tanpa kredit.
  final ImageAttribution? attribution;
}

class PlaceSource {
  const PlaceSource({
    required this.name,
    required this.type,
    required this.address,
    this.license,
    this.licenseUrl,
  });

  final String name;
  final String type;
  final String address;
  final String? license;
  final String? licenseUrl;
}

class PlaceRelated {
  const PlaceRelated({required this.kind, required this.id});

  final PlaceRelatedKind kind;
  final String id;
}

class Place {
  const Place({
    required this.id,
    required this.slug,
    required this.name,
    required this.category,
    required this.type,
    required this.lat,
    required this.lng,
    required this.shortDescription,
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

  /// Sudah dinormalisasi DTO: entry `isMain` pertama yang menang,
  /// tanpa true = pertama dianggap main.
  final List<PlaceImage> images;
  final String? hours;
  final String? contact;
  final List<PlaceRelated> related;
  final List<PlaceSource> sources;

  /// Cover list/peta/detail. List kosong → null (placeholder).
  PlaceImage? get cover {
    for (final img in images) {
      if (img.isMain) return img;
    }
    return images.isEmpty ? null : images.first;
  }

  PlaceImage? get mainImage {
    final img = cover;
    if (img == null) return null;
    return img.isMain ? img : PlaceImage(url: img.url, isMain: true);
  }

  List<PlaceRelated> relatedOf(PlaceRelatedKind kind) =>
      related.where((r) => r.kind == kind).toList();
}
