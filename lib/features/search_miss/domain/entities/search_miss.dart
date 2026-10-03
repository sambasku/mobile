import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_miss.freezed.dart';
part 'search_miss.g.dart';

/// Satu baris "pencarian yang tidak ketemu", ditampilkan sebagai konten
/// beranda / aktivitas. Endpoint publik:
/// `GET /api/v1/search-misses?limit=10` (sort hit_count DESC).
///
/// Server HANYA mengembalikan miss yang admin sudah izinkan tayang
/// (`is_visible=true`) dan belum fulfilled - lihat
/// Client tidak perlu
/// filter visibility sendiri.
@freezed
abstract class SearchMiss with _$SearchMiss {
  const factory SearchMiss({
    required String id,
    required String term,

    /// Mirror wire `direction`; nama Dart searchIn untuk query UI.
    @JsonKey(name: 'direction') required String searchIn,
    @JsonKey(name: 'hit_count') required int hitCount,
    @JsonKey(name: 'last_searched_at') DateTime? lastSearchedAt,
  }) = _SearchMiss;

  factory SearchMiss.fromJson(Map<String, dynamic> json) =>
      _$SearchMissFromJson(json);
}
