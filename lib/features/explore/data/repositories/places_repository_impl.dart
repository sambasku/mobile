import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cached_json_client.dart';
import '../../domain/entities/place.dart';
import '../datasources/places_remote_datasource.dart';
import '../models/place_dto.dart';
import '../models/places_dto.dart';

/// Impl repository places (API publik).
///
/// Alur: cache L1 (referenceStatic) → miss/stale → fetch halaman
/// `GET /api/v1/places` mengikuti `next_cursor` → envelope → DTO → entity.
/// Error apa pun → null (soft-fail).
class PlacesRepositoryImpl {
  PlacesRepositoryImpl(this._datasource, this._cache);

  final PlacesRemoteDatasource _datasource;
  final CachedJsonClient _cache;

  static const _cacheKey = '/api/v1/places';

  Future<List<Place>?> getPlaces({bool forceRefresh = false}) async {
    try {
      final envelope = await _cache.getOrFetch(
        key: buildCacheKey(method: 'GET', path: _cacheKey),
        cacheClass: CacheClass.referenceStatic,
        forceRefresh: forceRefresh,
        fetch: _datasource.fetchCatalogEnvelope,
      );
      return PlacesDto.fromJson(envelope).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> recordView(String slug) => _datasource.recordView(slug);

  /// #187: halaman galeri foto (offset server-side). Error dilempar supaya
  /// grid bisa menampilkan tombol coba lagi, bukan senyap kosong.
  Future<({List<PlaceImage> items, int total, int? nextOffset})> imagePage(
    String slug, {
    int offset = 0,
  }) async {
    final page = await _datasource.fetchImagePage(slug, offset: offset);
    return (
      items: [
        for (final raw in page.items)
          ?PlaceDto.imageFromJson(raw),
      ],
      total: page.total,
      nextOffset: page.nextOffset,
    );
  }

  /// Satu halaman daftar. Error dilempar supaya halaman bisa tampil gagal/retry.
  Future<({List<Place> items, String? nextCursor})> listPage({
    required String category,
    String? type,
    String? q,
    String? before,
    int limit = placesBrowsePageSize,
  }) async {
    final page = await _datasource.fetchPage(
      limit: limit,
      before: before,
      category: category,
      type: type,
      q: q,
    );
    return (
      items: PlacesDto.fromJson({
        'version': 1,
        'places': page.places,
      }).toEntity(),
      nextCursor: page.nextCursor,
    );
  }
}
