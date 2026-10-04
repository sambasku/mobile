import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cached_json_client.dart';
import '../../domain/entities/cuisine.dart';
import '../datasources/cuisine_remote_datasource.dart';
import '../models/cuisine_dto.dart';

/// Impl repository cuisine.
///
/// Alur sama dengan PlacesRepositoryImpl: cache L1 (referenceStatic,
/// fresh 24 jam + SWR) → miss/stale → fetch jsDelivr → DTO → entity.
/// Error apa pun → null (soft-fail), jangan pernah crash UI.
class CuisineRepositoryImpl {
  CuisineRepositoryImpl(this._datasource, this._cache);

  final CuisineRemoteDatasource _datasource;
  final CachedJsonClient _cache;

  static const _cacheKey = '/cdn/cuisines.json';

  Future<List<Cuisine>?> getCuisines({bool forceRefresh = false}) async {
    try {
      final envelope = await _cache.getOrFetch(
        key: buildCacheKey(method: 'GET', path: _cacheKey),
        cacheClass: CacheClass.referenceStatic,
        forceRefresh: forceRefresh,
        fetch: _fetchEnvelope,
      );
      return CuisineDto.fromJson(envelope).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchEnvelope() async {
    final resp = await _datasource.fetchRaw();
    final body = resp.data;
    if (body is! Map) {
      throw StateError('Body cuisines.json bukan object');
    }
    return Map<String, dynamic>.from(body);
  }
}
