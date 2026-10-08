import 'package:dio/dio.dart';

import '../../../../shared/utils/public_account_name.dart';
import '../../domain/dashboard_mappers.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/merge_analytics_activity.dart';
import '../../domain/repositories/dashboard_repository.dart';

int _asInt(Object? raw) {
  if (raw is int) return raw;
  if (raw is num) return raw.toInt();
  if (raw is String) return int.tryParse(raw) ?? 0;
  return 0;
}

Map<String, dynamic> _asMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

/// 401/403 = kegagalan otorisasi; jangan ditelan jadi [] - biar provider
/// menampilkan error state (#69). Error lain (jaringan/server) tetap [].
bool _isAuthzError(DioException e) =>
    e.response?.statusCode == 401 || e.response?.statusCode == 403;

List<Map<String, dynamic>> _asDataList(Map<String, dynamic>? body) {
  final raw = body?['data'];
  if (raw is! List) return const [];
  return [for (final row in raw) _asMap(row)];
}

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._dio);

  final Dio _dio;

  static const _statsPath = '/api/v1/admin/dashboard/stats';
  static const _searchMissesPath = '/api/v1/admin/search-misses';
  static const _commentsPath = '/api/v1/admin/comments';
  static const _votesPath = '/api/v1/admin/votes';
  static const _discussionsPath = '/api/v1/discussions';

  @override
  Future<DashboardStats> getStats({DateTime? now}) async {
    final res = await _dio.get<Map<String, dynamic>>(_statsPath);
    final body = res.data ?? const <String, dynamic>{};
    final data = _asMap(body['data']);
    return normalizeDashboardStats(data, now: now);
  }

  @override
  Future<List<AnalyticsActivityItem>> latestActivity({
    int perSource = 8,
  }) async {
    final results = await Future.wait([
      _fetchComments(perSource),
      _fetchVotes(perSource),
      _fetchDiscussions(perSource),
      _fetchVisibleSearchMisses(perSource),
    ]);
    return mergeAnalyticsActivity([
      ...results[0],
      ...results[1],
      ...results[2],
      ...results[3],
    ]);
  }

  Future<List<AnalyticsActivityItem>> _fetchComments(int limit) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _commentsPath,
        queryParameters: {'status': 'published', 'limit': limit},
      );
      final items = <AnalyticsActivityItem>[];
      for (final map in _asDataList(res.data)) {
        final id = map['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        final username = map['username']?.toString();
        final displayName = map['display_name']?.toString();
        final wordId = map['word_id']?.toString() ?? '';
        final lemmaRaw = map['word_lemma']?.toString().trim() ?? '';
        final bodyRaw = map['body']?.toString().trim() ?? '';
        items.add(
          AnalyticsActivityItem(
            kind: AnalyticsActivityKind.comment,
            id: id,
            createdAt: map['created_at']?.toString() ?? '',
            actorLabel: displayPublicAccountLabel(
              displayName: displayName,
              username: username,
            ),
            actorUsername: username,
            avatarUrl: map['avatar_url']?.toString(),
            body: bodyRaw.isEmpty ? '(kosong)' : bodyRaw,
            subtitle: lemmaRaw.isEmpty ? null : lemmaRaw,
            navigatePath: wordId.isEmpty ? null : '/words/$wordId',
          ),
        );
      }
      return items;
    } on DioException catch (e) {
      if (_isAuthzError(e)) rethrow;
      return const [];
    }
  }

  Future<List<AnalyticsActivityItem>> _fetchVotes(int limit) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _votesPath,
        queryParameters: {'limit': limit},
      );
      final items = <AnalyticsActivityItem>[];
      for (final map in _asDataList(res.data)) {
        final id = map['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        final username = map['voter_username']?.toString();
        final displayName = map['voter_display_name']?.toString();
        final avatarUrl = map['voter_avatar_url']?.toString();
        final value = _asInt(map['value']);
        final targetType = map['target_type']?.toString() ?? '';
        final targetId = map['target_id']?.toString() ?? '';
        final preview = map['target_preview']?.toString().trim() ?? '';
        final voteLabel = value >= 0 ? 'Vote naik' : 'Vote turun';
        final targetLabel = preview.isNotEmpty
            ? preview
            : (targetType.isEmpty ? 'target' : targetType);
        items.add(
          AnalyticsActivityItem(
            kind: AnalyticsActivityKind.vote,
            id: id,
            createdAt: map['created_at']?.toString() ?? '',
            actorLabel: displayPublicAccountLabel(
              displayName: displayName,
              username: username,
            ),
            actorUsername: username,
            avatarUrl: avatarUrl,
            body: '$voteLabel · $targetLabel',
            subtitle: targetType.isEmpty ? null : targetType,
            navigatePath: targetType == 'word' && targetId.isNotEmpty
                ? '/words/$targetId'
                : null,
          ),
        );
      }
      return items;
    } on DioException catch (e) {
      if (_isAuthzError(e)) rethrow;
      return const [];
    }
  }

  Future<List<AnalyticsActivityItem>> _fetchDiscussions(int limit) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _discussionsPath,
        queryParameters: {'limit': limit},
      );
      final items = <AnalyticsActivityItem>[];
      for (final map in _asDataList(res.data)) {
        final id = map['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        final username = map['username']?.toString();
        final displayName = map['display_name']?.toString();
        final avatarUrl = map['avatar_url']?.toString();
        final bodyRaw = map['body']?.toString().trim() ?? '';
        items.add(
          AnalyticsActivityItem(
            kind: AnalyticsActivityKind.discussion,
            id: id,
            createdAt: map['created_at']?.toString() ?? '',
            actorLabel: displayPublicAccountLabel(
              displayName: displayName,
              username: username,
            ),
            actorUsername: username,
            avatarUrl: avatarUrl,
            body: bodyRaw.isEmpty ? '(diskusi tanpa teks)' : bodyRaw,
            subtitle: 'Diskusi',
            navigatePath: '/discussions/$id',
          ),
        );
      }
      return items;
    } on DioException catch (e) {
      if (_isAuthzError(e)) rethrow;
      return const [];
    }
  }

  Future<List<AnalyticsActivityItem>> _fetchVisibleSearchMisses(
    int limit,
  ) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _searchMissesPath,
        queryParameters: {'visible': true, 'fulfilled': false, 'limit': limit},
      );
      final items = <AnalyticsActivityItem>[];
      for (final map in _asDataList(res.data)) {
        final id = map['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        final term = map['term']?.toString() ?? '';
        final direction = map['direction']?.toString() ?? 'lemma';
        final searchIn = direction == 'translation' ? 'translation' : 'lemma';
        final q = Uri(
          queryParameters: <String, String>{
            'lemma': term,
            'search_in': searchIn,
            'miss_id': id,
          },
        ).query;
        items.add(
          AnalyticsActivityItem(
            kind: AnalyticsActivityKind.searchMiss,
            id: id,
            createdAt:
                map['created_at']?.toString() ??
                map['last_searched_at']?.toString() ??
                '',
            actorLabel: 'Warga',
            body: searchMissActivityBody(term),
            subtitle: 'Kata tidak ditemukan',
            navigatePath: '/contribute?$q',
          ),
        );
      }
      return items;
    } on DioException catch (e) {
      if (_isAuthzError(e)) rethrow;
      return const [];
    }
  }
}
