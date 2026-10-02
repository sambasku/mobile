import 'package:flutter/painting.dart';

/// Config background card dari CDN (repo `data` via jsDelivr).
/// Soft-fail: JSON kosong/rusak → null → app pakai asset bundled.
class CardImagesConfig {
  const CardImagesConfig({required this.cards});

  /// key card (mis. 'wotd') → config-nya.
  final Map<String, CardImageEntry> cards;

  static CardImagesConfig? tryParse(Object? json) {
    if (json is! Map) return null;
    final rawCards = json['cards'];
    if (rawCards is! Map) return null;
    final parsed = <String, CardImageEntry>{};
    rawCards.forEach((key, value) {
      final entry = CardImageEntry.tryParse(value);
      if (entry != null && key is String) parsed[key] = entry;
    });
    if (parsed.isEmpty) return null;
    return CardImagesConfig(cards: parsed);
  }

  CardImageEntry? entryOf(String key) => cards[key];
}

class CardImageEntry {
  const CardImageEntry({
    required this.imageUrl,
    this.alignment = 'bottomCenter',
  });

  final String imageUrl;
  final String alignment;

  static const _allowedAlignments = {
    'topLeft', 'topCenter', 'topRight',
    'centerLeft', 'center', 'centerRight',
    'bottomLeft', 'bottomCenter', 'bottomRight',
  };

  static CardImageEntry? tryParse(Object? json) {
    if (json is! Map) return null;
    final url = json['imageUrl'];
    if (url is! String || !url.startsWith('https://')) return null;
    final align = json['alignment'];
    return CardImageEntry(
      imageUrl: url,
      alignment: align is String && _allowedAlignments.contains(align)
          ? align
          : 'bottomCenter',
    );
  }

  Alignment get alignmentValue => switch (alignment) {
        'topLeft' => Alignment.topLeft,
        'topCenter' => Alignment.topCenter,
        'topRight' => Alignment.topRight,
        'centerLeft' => Alignment.centerLeft,
        'center' => Alignment.center,
        'centerRight' => Alignment.centerRight,
        'bottomLeft' => Alignment.bottomLeft,
        'bottomRight' => Alignment.bottomRight,
        _ => Alignment.bottomCenter,
      };
}
