import '../../domain/entities/place.dart';
import 'place_dto.dart';

/// Exception places.json tidak sesuai schema.
class PlacesException implements Exception {
  const PlacesException(this.message);

  final String message;

  @override
  String toString() => 'PlacesException: $message';
}

/// DTO JSON `places.json` di CDN (repo `data` via jsDelivr).
///
/// Parse defensif per WISATA_START.md: item tanpa field wajib di-skip -
/// satu item rusak tidak mematikan seluruh koleksi.
class PlacesDto {
  const PlacesDto({required this.places});

  final List<PlaceDto> places;

  factory PlacesDto.fromJson(Map<String, dynamic> json) {
    final raw = json['places'];
    final list = raw is List ? raw : const [];
    return PlacesDto(
      places: list
          .whereType<Map>()
          .map((e) => PlaceDto.fromJson(Map<String, dynamic>.from(e)))
          .whereType<PlaceDto>()
          .toList(),
    );
  }

  List<Place> toEntity() => places.map((e) => e.toEntity()).toList();
}
