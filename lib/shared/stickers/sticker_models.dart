/// Item katalog stiker (GET /api/v1/stickers).
class CatalogSticker {
  const CatalogSticker({
    required this.id,
    required this.imageUrl,
    this.playOnce = false,
    this.categorySlug,
  });

  final String id;
  final String imageUrl;
  final bool playOnce;
  final String? categorySlug;

  factory CatalogSticker.fromJson(Map<String, dynamic> json) {
    final rawCat = json['category_slug']?.toString().trim();
    return CatalogSticker(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      playOnce: json['play_once'] == true,
      categorySlug: (rawCat == null || rawCat.isEmpty) ? null : rawCat,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
        'play_once': playOnce,
        'category_slug': categorySlug,
      };
}

class StickerCatalogPage {
  const StickerCatalogPage({
    required this.items,
    required this.categories,
    this.nextCursor,
  });

  final List<CatalogSticker> items;
  final List<String> categories;
  final String? nextCursor;
}
