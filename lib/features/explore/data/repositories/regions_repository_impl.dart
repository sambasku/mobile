import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cached_json_client.dart';
import '../../domain/entities/region.dart';
import '../datasources/regions_remote_datasource.dart';
import '../models/regions_dto.dart';

/// Impl repository regions (pola places_repository_impl).
///
/// Cache L1 (referenceStatic, fresh 24 jam + SWR) -> miss/stale -> fetch
/// jsDelivr via datasource -> DTO -> entity. Error apa pun (network, parse)
/// -> null (soft-fail), jangan pernah crash UI. Kosong juga null supaya
/// UI tahu bedanya "belum ke-load" vs "memang kosong".
class RegionsRepositoryImpl {
  RegionsRepositoryImpl(this._datasource, this._cache);

  final RegionsRemoteDatasource _datasource;
  final CachedJsonClient _cache;

  static const _cacheKey = '/cdn/regions.json';

  Future<List<Region>?> getRegions({bool forceRefresh = false}) async {
    try {
      final envelope = await _cache.getOrFetch(
        key: buildCacheKey(method: 'GET', path: _cacheKey),
        cacheClass: CacheClass.referenceStatic,
        forceRefresh: forceRefresh,
        fetch: _fetchEnvelope,
      );
      final regions = RegionsDto.fromJson(envelope)?.toEntity();
      return (regions == null || regions.isEmpty) ? null : regions;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchEnvelope() async {
    final resp = await _datasource.fetchRaw();
    final body = resp.data;
    if (body is! Map) {
      throw StateError('Body regions.json bukan object');
    }
    return Map<String, dynamic>.from(body);
  }
}
