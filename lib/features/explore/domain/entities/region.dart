import 'package:flutter/foundation.dart';

/// Satu entri wilayah: kecamatan atau desa.
@immutable
class Region {
  const Region({
    required this.id,
    required this.slug,
    required this.name,
    required this.type,
    this.parentId,
    this.lat,
    this.lng,
    this.code,
  });

  /// ULID SoT (FK ke API: profil, usaha, acara).
  final String id;

  /// Slug publik (kunci geojson / CDN / route `:slug`).
  final String slug;

  final String name;
  final RegionType type;

  /// ULID kecamatan induk (hanya desa).
  final String? parentId;

  /// Centroid (hanya kecamatan) - kamera fokus & pin.
  final double? lat;
  final double? lng;

  /// Kode BPS 10-digit (hanya desa).
  final String? code;
}

enum RegionType { kecamatan, desa }
