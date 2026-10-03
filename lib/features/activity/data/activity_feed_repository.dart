import 'package:dio/dio.dart';

import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_key.dart';
import '../../../core/cache/cached_json_client.dart';
import '../domain/entities/feed_activity_item.dart';
import 'map_feed_activity.dart';

class ActivityFeedPage {
  const ActivityFeedPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<FeedActivityItem> items;
  final String? nextCursor;
  final bool hasMore;
}

class ActivityFeedRepository {
  ActivityFeedRepository(this._dio, {CachedJsonClient? cache}) : _cache = cache;

  final Dio _dio;
  final CachedJsonClient? _cache;

  static const path = '/api/v1/activity';

  Future<ActivityFeedPage> list({
    int limit = 20,
    String? cursor,
    bool forceRefresh = false,
    bool excludeSelf = false,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      // Penyaringan terjadi di API (SQL, sebelum cap per jenis). Tanpa token
      // sah server mengabaikannya dan tetap mengembalikan feed publik penuh.
      //
      // `buildCacheKey` sengaja tidak memuat Authorization, tapi memuat query -
      // jadi feed login dan feed tamu punya entri cache terpisah dan tidak
      // saling menimpa.
      if (excludeSelf) 'exclude_self': '1',
    };
    final cache = _cache;
    final isFirstPage = cursor == null || cursor.isEmpty;

    Future<Map<String, dynamic>> fetchEnvelope() async {
      final res = await _dio.get<dynamic>(path, queryParameters: query);
      final body = res.data;
      if (body is! Map) {
        throw StateError('Envelope activity tidak valid');
      }
      return Map<String, dynamic>.from(body);
    }

    final Map<String, dynamic> envelope;
    if (cache != null && isFirstPage) {
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

    final meta = envelope['meta'];
    return ActivityFeedPage(
      items: mapFeedActivityList(envelope['data']),
      nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
      hasMore: meta is Map && meta['has_more'] == true,
    );
  }
}
