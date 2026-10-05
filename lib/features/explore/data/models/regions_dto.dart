import '../../domain/entities/region.dart';

/// Normalisasi nama wilayah jadi slug id (harus identik dgn generator data).
String regionSlug(String name) =>
    name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').trim();

class RegionDto {
  const RegionDto({
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
  final String? parentId;
  final double? lat;
  final double? lng;
  final String? code; // BPS 10-digit code (desa only)

  /// Null = field wajib absen/tidak valid -> item di-skip (pola place_dto).
  static RegionDto? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    String? str(Object? key) {
      final v = json[key];
      return v is String && v.trim().isNotEmpty ? v.trim() : null;
    }

    final id = str('id');
    final name = str('name');
    final type = RegionType.values
        .where((t) => t.name == json['type'])
        .firstOrNull;
    if (id == null || name == null || type == null) return null;

    return RegionDto(
      id: id,
      name: name,
      type: type,
      parentId: str('parentId'),
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      code: str('code'),
    );
  }

  Region toEntity() => Region(
    id: id,
    name: name,
    type: type,
    parentId: parentId,
    lat: lat,
    lng: lng,
    code: code,
  );
}

class RegionsDto {
  const RegionsDto({required this.regions});

  final List<RegionDto> regions;

  /// Null = body bukan object / regions bukan list (soft-fail di repo).
  static RegionsDto? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final raw = json['regions'];
    if (raw is! List) return null;
    final items = <RegionDto>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final dto = RegionDto.fromJson(Map<String, dynamic>.from(e));
      if (dto != null) items.add(dto);
    }
    return RegionsDto(regions: items);
  }

  List<Region> toEntity() => regions.map((e) => e.toEntity()).toList();
}
