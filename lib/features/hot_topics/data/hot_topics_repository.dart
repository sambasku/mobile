import 'package:dio/dio.dart';

import '../domain/hot_topics.dart';

class HotTopicsRepository {
  HotTopicsRepository(this._dio);

  final Dio _dio;

  static const path = '/api/v1/hot-topics';

  Future<HotTopicsBundle> fetch({int limit = 10}) async {
    final res = await _dio.get<dynamic>(
      path,
      queryParameters: {'limit': limit},
    );
    final body = res.data;
    if (body is! Map) {
      throw StateError('Envelope hot-topics tidak valid');
    }
    final data = body['data'];
    if (data is! Map) {
      throw StateError('Data hot-topics tidak valid');
    }
    return HotTopicsBundle(
      searched: _parseSearched(data['searched']),
      proposed: _parseProposed(data['proposed']),
      viewed: _parseViewed(data['viewed']),
      check: _parseCheck(data['check']),
    );
  }

  HotTopicTabMeta _meta(Object? raw) {
    final m = raw is Map ? raw : const {};
    return HotTopicTabMeta(
      inWindow: (m['in_window'] as num?)?.toInt() ?? 0,
      backfilled: (m['backfilled'] as num?)?.toInt() ?? 0,
      backfillUsed: m['backfill_used'] == true,
    );
  }

  HotTopicTab _parseSearched(Object? raw) {
    final map = raw is Map ? raw : const {};
    final list = map['items'];
    final items = <HotTopicItem>[];
    if (list is List) {
      for (final row in list) {
        if (row is! Map) continue;
        items.add(
          HotSearchedItem(
            id: row['id'] as String? ?? '',
            term: row['term'] as String? ?? '',
            direction: row['direction'] as String? ?? 'lemma',
            hitCount: (row['hit_count'] as num?)?.toInt() ?? 0,
            inWindow: row['in_window'] == true,
          ),
        );
      }
    }
    return HotTopicTab(items: items, meta: _meta(map['meta']));
  }

  HotTopicTab _parseProposed(Object? raw) {
    final map = raw is Map ? raw : const {};
    final list = map['items'];
    final items = <HotTopicItem>[];
    if (list is List) {
      for (final row in list) {
        if (row is! Map) continue;
        items.add(
          HotProposedItem(
            id: row['id'] as String? ?? '',
            wordId: row['word_id'] as String? ?? '',
            lemma: row['lemma'] as String? ?? '',
            inWindow: row['in_window'] == true,
          ),
        );
      }
    }
    return HotTopicTab(items: items, meta: _meta(map['meta']));
  }

  HotTopicTab _parseViewed(Object? raw) {
    final map = raw is Map ? raw : const {};
    final list = map['items'];
    final items = <HotTopicItem>[];
    if (list is List) {
      for (final row in list) {
        if (row is! Map) continue;
        items.add(
          HotViewedItem(
            wordId: row['word_id'] as String? ?? '',
            lemma: row['lemma'] as String? ?? '',
            viewCount: (row['view_count'] as num?)?.toInt() ?? 0,
            lastViewedDay: row['last_viewed_day'] as String? ?? '',
            inWindow: row['in_window'] == true,
          ),
        );
      }
    }
    return HotTopicTab(items: items, meta: _meta(map['meta']));
  }

  HotTopicTab _parseCheck(Object? raw) {
    final map = raw is Map ? raw : const {};
    final list = map['items'];
    final items = <HotTopicItem>[];
    if (list is List) {
      for (final row in list) {
        if (row is! Map) continue;
        final preview = row['definition_preview'];
        items.add(
          HotCheckItem(
            meaningId: row['meaning_id'] as String? ?? '',
            wordId: row['word_id'] as String? ?? '',
            lemma: row['lemma'] as String? ?? '',
            downvotes: (row['downvotes'] as num?)?.toInt() ?? 0,
            definitionPreview: preview is String ? preview : null,
            inWindow: row['in_window'] == true,
          ),
        );
      }
    }
    return HotTopicTab(items: items, meta: _meta(map['meta']));
  }
}
