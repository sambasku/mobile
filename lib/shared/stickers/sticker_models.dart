/// Item katalog / favorit / custom stiker.
class CatalogSticker {
  const CatalogSticker({
    required this.id,
    required this.imageUrl,
    this.playOnce = false,
    this.categorySlug,
    this.displayName,
    this.isCustom = false,
  });

  final String id;
  final String imageUrl;
  final bool playOnce;
  final String? categorySlug;
  final String? displayName;
  final bool isCustom;

  String get label {
    final n = displayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return id;
  }

  factory CatalogSticker.fromJson(Map<String, dynamic> json) {
    final rawCat = json['category_slug']?.toString().trim();
    final rawName = json['display_name']?.toString().trim();
    return CatalogSticker(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      playOnce: json['play_once'] == true,
      categorySlug: (rawCat == null || rawCat.isEmpty) ? null : rawCat,
      displayName: (rawName == null || rawName.isEmpty) ? null : rawName,
      isCustom: json['is_custom'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'image_url': imageUrl,
        'play_once': playOnce,
        'category_slug': categorySlug,
        'display_name': displayName,
        'is_custom': isCustom,
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

class StickerUploadCredentials {
  const StickerUploadCredentials({
    required this.token,
    required this.signature,
    required this.expire,
    required this.publicKey,
    required this.uploadEndpoint,
  });

  final String token;
  final String signature;
  final int expire;
  final String publicKey;
  final String uploadEndpoint;

  factory StickerUploadCredentials.fromJson(Map<String, dynamic> json) {
    return StickerUploadCredentials(
      token: json['token']?.toString() ?? '',
      signature: json['signature']?.toString() ?? '',
      expire: (json['expire'] as num?)?.toInt() ?? 0,
      publicKey: json['public_key']?.toString() ?? '',
      uploadEndpoint: json['upload_endpoint']?.toString() ?? '',
    );
  }
}

class StickerApiException implements Exception {
  const StickerApiException({this.errorCode, this.message});

  final String? errorCode;
  final String? message;
}
