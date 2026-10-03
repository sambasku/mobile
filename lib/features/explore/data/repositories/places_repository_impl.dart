import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cached_json_client.dart';
import '../../domain/entities/place.dart';
import '../datasources/places_remote_datasource.dart';
import '../models/places_dto.dart';

/// Impl repository places.
///
/// Alur: cache L1 (referenceStatic, fresh 24 jam + SWR) → miss/stale →
/// fetch jsDelivr via datasource → DTO → entity. Error apa pun (network,
/// parse) → null (soft-fail), jangan pernah crash UI.
class PlacesRepositoryImpl {
  PlacesRepositoryImpl(this._datasource, this._cache);

  final PlacesRemoteDatasource _datasource;
  final CachedJsonClient _cache;

  static const _cacheKey = '/cdn/places.json';

  Future<List<Place>?> getPlaces({bool forceRefresh = false}) async {
    try {
      final envelope = await _cache.getOrFetch(
        key: buildCacheKey(method: 'GET', path: _cacheKey),
        cacheClass: CacheClass.referenceStatic,
        forceRefresh: forceRefresh,
        fetch: _fetchEnvelope,
      );
      return PlacesDto.fromJson(envelope).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchEnvelope() async {
    final resp = await _datasource.fetchRaw();
    final body = resp.data;
    if (body is! Map) {
      throw StateError('Body places.json bukan object');
    }
    return Map<String, dynamic>.from(body);
  }
}
