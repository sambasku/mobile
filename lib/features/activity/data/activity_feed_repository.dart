import 'package:dio/dio.dart';

import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_key.dart';
import '../../../core/cache/cached_json_client.dart';
import '../domain/entities/feed_activity_item.dart';
import 'map_feed_activity.dart';

class ActivityFeedRepository {
  ActivityFeedRepository(this._dio, {CachedJsonClient? cache}) : _cache = cache;

  final Dio _dio;
  final CachedJsonClient? _cache;

  static const path = '/api/v1/activity';

  Future<List<FeedActivityItem>> list({
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final query = <String, dynamic>{'limit': limit};
    final cache = _cache;

    Future<Map<String, dynamic>> fetchEnvelope() async {
      final res = await _dio.get<dynamic>(path, queryParameters: query);
      final body = res.data;
      if (body is! Map) {
        throw StateError('Envelope activity tidak valid');
      }
      return Map<String, dynamic>.from(body);
    }

    final Map<String, dynamic> envelope;
    if (cache != null) {
      final key = buildCacheKey(method: 'GET', path: path, query: query);
      envelope = await cache.getOrFetch(
        key: key,
        cacheClass: CacheClass.feedList,
        forceRefresh: forceRefresh,
        fetch: fetchEnvelope,
      );
    } else {
      envelope = await fetchEnvelope();
    }

    return mapFeedActivityList(envelope['data']);
  }
}
