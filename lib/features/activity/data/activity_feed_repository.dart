import 'package:dio/dio.dart';

import '../../../core/cache/cache_entry.dart';
import '../../../core/cache/cache_key.dart';
import '../../../core/cache/cached_json_client.dart';
import '../domain/entities/feed_activity_item.dart';
import 'map_feed_activity.dart';

/// Kategori chips feed beranda (#193). Nilai = query `category` di API.
enum FeedCategory {
  all('all'),
  searchMiss('search_miss'),
  correction('correction'),
  explore('explore'),
  announcement('announcement'),
  joined('joined');

  const FeedCategory(this.wire);

  /// Nilai `category` yang dikirim ke API.
  final String wire;
}

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
    // #193: filter kategori chips. `all` = tanpa filter (identik dengan
    // request tanpa param - perilaku lama tidak berubah).
    FeedCategory category = FeedCategory.all,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      // #167: server exclude otomatis saat Bearer sah. Flag ini tetap dikirim
      // saat login sebagai pembeda cache key L1 (buildCacheKey memuat query,
      // bukan Authorization) - feed login vs tamu tidak saling menimpa.
      if (excludeSelf) 'exclude_self': '1',
      // #193: kategori ikut masuk cache key L1 -> tiap kategori punya cache
      // terpisah, tidak saling menimpa.
      if (category != FeedCategory.all) 'category': category.wire,
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
