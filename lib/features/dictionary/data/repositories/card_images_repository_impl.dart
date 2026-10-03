import 'package:dio/dio.dart';

import '../../../../core/cache/cache_entry.dart';
import '../../../../core/cache/cache_key.dart';
import '../../../../core/cache/cached_json_client.dart';
import '../../domain/entities/card_images.dart';
import '../../domain/repositories/card_images_repository.dart';
import '../datasources/card_images_remote_datasource.dart';
import '../models/card_images_dto.dart';

/// Impl repository config card.
///
/// Alur: cache L1 (referenceStatic, fresh 24 jam + SWR) → miss/stale →
/// fetch jsDelivr via datasource → DTO → entity. Error apa pun (network,
/// parse) → null (soft-fail), jangan pernah crash UI.
class CardImagesRepositoryImpl implements CardImagesRepository {
  CardImagesRepositoryImpl(this._datasource, this._dio, this._cache);

  final CardImagesRemoteDatasource _datasource;
  final Dio _dio;
  final CachedJsonClient _cache;

  static const _cacheKey = '/cdn/home.json';

  @override
  Future<CardImagesConfig?> getCardImages({bool forceRefresh = false}) async {
    try {
      final envelope = await _cache.getOrFetch(
        key: buildCacheKey(method: 'GET', path: _cacheKey),
        cacheClass: CacheClass.referenceStatic,
        forceRefresh: forceRefresh,
        fetch: _fetchEnvelope,
      );
      return CardImagesDto.fromJson(envelope).toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchEnvelope() async {
    final resp = await _dio.get<dynamic>(
      _datasource.configUrl,
      options: Options(receiveTimeout: const Duration(seconds: 5)),
    );
    final body = resp.data;
    if (body is! Map) {
      throw const CardImagesException('Body home.json bukan object');
    }
    return Map<String, dynamic>.from(body);
  }
}
