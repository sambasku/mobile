import 'package:flutter/painting.dart';

/// Entity domain: config card siap render. Diparse dari DTO
/// (`CardImagesDto`), hanya berisi nilai yang dipakai widget.
class CardImagesConfig {
  const CardImagesConfig({required this.cards});

  /// key card (mis. 'wotd') → config-nya.
  final Map<String, CardImageEntry> cards;

  CardImageEntry? entryOf(String key) => cards[key];
}

class CardImageEntry {
  const CardImageEntry({required this.imageUrl, required this.alignmentValue});

  final String imageUrl;

  /// Sudah lewat whitelist DTO — aman dipakai langsung widget.
  final Alignment alignmentValue;
}
