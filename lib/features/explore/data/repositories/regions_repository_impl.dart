import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cached_json_client.dart';
import '../../domain/entities/region.dart';
import '../datasources/regions_remote_datasource.dart';
import '../models/regions_dto.dart';

/// Impl repository regions (pola places_repository_impl).
///
/// Cache L1 (referenceStatic, fresh 24 jam + SWR) -> miss/stale -> fetch
/// `GET /api/v1/regions/catalog` -> DTO -> entity. Error apa pun (network,
/// parse) -> null (soft-fail). Kosong juga null supaya UI tahu bedanya
/// "belum ke-load" vs "memang kosong".
class RegionsRepositoryImpl {
  RegionsRepositoryImpl(this._datasource, this._cache);

  final RegionsRemoteDatasource _datasource;
  final CachedJsonClient _cache;

  static const _cacheKey = '/api/v1/regions/catalog';

  Future<List<Region>?> getRegions({bool forceRefresh = false}) async {
    try {
      final envelope = await _cache.getOrFetch(
        key: buildCacheKey(method: 'GET', path: _cacheKey),
        cacheClass: CacheClass.referenceStatic,
        forceRefresh: forceRefresh,
        fetch: _datasource.fetchCatalogEnvelope,
      );
      final regions = RegionsDto.fromJson(envelope)?.toEntity();
      return (regions == null || regions.isEmpty) ? null : regions;
    } catch (_) {
      return null;
    }
  }
}
