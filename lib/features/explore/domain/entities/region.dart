import 'package:flutter/foundation.dart';

/// Satu entri wilayah: kecamatan atau desa.
@immutable
class Region {
  const Region({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.lat,
    this.lng,
    this.code,
  });

  final String id;
  final String name;
  final RegionType type;

  /// Kecamatan induk (hanya desa).
  final String? parentId;

  /// Centroid (hanya kecamatan) - kamera fokus & pin.
  final double? lat;
  final double? lng;

  /// Kode BPS 10-digit (hanya desa).
  final String? code;
}

enum RegionType { kecamatan, desa }
