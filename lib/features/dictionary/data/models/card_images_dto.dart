import 'package:flutter/painting.dart';

import '../../domain/entities/card_images.dart';

/// Exception config card tidak sesuai schema (`data/mobile/home.json`).
class CardImagesException implements Exception {
  const CardImagesException(this.message);

  final String message;

  @override
  String toString() => 'CardImagesException: $message';
}

/// DTO JSON `home.json` di CDN (repo `data` via jsDelivr).
/// Bentuk mengikuti file JSON, bukan entitas UI.
class CardImagesDto {
  const CardImagesDto({required this.version, required this.cards});

  /// Penanda schema. Belum dipakai parser (YAGNI) — dinaikkan hanya
  /// saat bentuk JSON berubah.
  final int version;

  /// key card (mis. 'wotd') → config-nya.
  final Map<String, CardImageEntryDto> cards;

  factory CardImagesDto.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'];
    if (rawCards is! Map) {
      throw const CardImagesException('Field "cards" tidak valid');
    }

    final version = json['version'];
    final parsed = <String, CardImageEntryDto>{};
    rawCards.forEach((key, value) {
      if (key is! String) return;
      final entry = CardImageEntryDto.fromJson(
        Map<String, dynamic>.from(value as Map),
      );
      if (entry != null) parsed[key] = entry;
    });

    return CardImagesDto(
      version: version is int ? version : 0,
      cards: parsed,
    );
  }

  /// Entry tanpa `imageUrl` valid sudah dibuang saat parse.
  CardImagesConfig toEntity() => CardImagesConfig(
        cards: cards.map((key, entry) => MapEntry(key, entry.toEntity())),
      );
}

/// DTO satu card di `home.json`.
class CardImageEntryDto {
  const CardImageEntryDto({required this.imageUrl, required this.alignment});

  final String imageUrl;
  final String alignment;

  static const _allowedAlignments = {
    'topLeft', 'topCenter', 'topRight',
    'centerLeft', 'center', 'centerRight',
    'bottomLeft', 'bottomCenter', 'bottomRight',
  };

  /// Null = entry tidak valid (URL absen/bukan https) → dibuang.
  static CardImageEntryDto? fromJson(Map<String, dynamic> json) {
    final url = json['imageUrl'];
    if (url is! String || !url.startsWith('https://')) return null;
    final align = json['alignment'];
    return CardImageEntryDto(
      imageUrl: url,
      alignment: align is String && _allowedAlignments.contains(align)
          ? align
          : 'bottomCenter',
    );
  }

  CardImageEntry toEntity() => CardImageEntry(
        imageUrl: imageUrl,
        alignmentValue: switch (alignment) {
          'topLeft' => Alignment.topLeft,
          'topCenter' => Alignment.topCenter,
          'topRight' => Alignment.topRight,
          'centerLeft' => Alignment.centerLeft,
          'center' => Alignment.center,
          'centerRight' => Alignment.centerRight,
          'bottomLeft' => Alignment.bottomLeft,
          'bottomRight' => Alignment.bottomRight,
          _ => Alignment.bottomCenter,
        },
      );
}

