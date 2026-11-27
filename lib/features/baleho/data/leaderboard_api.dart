import 'package:dio/dio.dart';

import '../../../core/network/api_error_text.dart';
import '../domain/leaderboard_iso_week.dart';
import '../domain/leaderboard_models.dart';
import '../domain/points_history_models.dart';

class LeaderboardApiException implements Exception {
  LeaderboardApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class LeaderboardApi {
  LeaderboardApi(this._dio);

  final Dio _dio;

  Future<WeeklyLeaderboardViewData> fetchCurrentWeek({int limit = 50}) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/leaderboard',
        queryParameters: {'period': 'week', 'limit': limit},
        options: Options(receiveTimeout: const Duration(seconds: 12)),
      );
      final envelope = _rootMap(res.data);
      final data = envelope['data'];
      final apiEntries = <LeaderboardEntry>[];
      if (data is List) {
        for (final raw in data) {
          if (raw is Map) {
            apiEntries.add(
              LeaderboardEntry.fromJson(Map<String, dynamic>.from(raw)),
            );
          }
        }
      }

      final meta = envelope['meta'];
      final metaMap = meta is Map
          ? Map<String, dynamic>.from(meta)
          : <String, dynamic>{};
      final weekId = metaMap['week_id'] as String?;
      final resetsRaw = metaMap['resets_at'] as String?;
      final resetsAt = resetsRaw == null || resetsRaw.isEmpty
          ? null
          : DateTime.tryParse(resetsRaw);
      final cdn = LeaderboardCdnMeta.fromJson(
        metaMap['cdn'] is Map
            ? Map<String, dynamic>.from(metaMap['cdn'] as Map)
            : null,
      );

      var entries = apiEntries;
      if (cdn.current != null && cdn.current!.trim().isNotEmpty) {
        try {
          final snap = await _fetchCdnSnapshot(cdn.current!.trim());
          if (snap.entries.isNotEmpty) {
            entries = snap.entries;
          }
        } catch (_) {
          // Tetap pakai API.
        }
      }

      return WeeklyLeaderboardViewData(
        entries: entries,
        weekId: weekId,
        resetsAt: resetsAt,
        cdnCurrentUrl: cdn.current,
        cdnWeeklyPatternUrl: cdn.weekly,
      );
    } on DioException catch (e) {
      throw _fromDio(e, codeFallback: 'LEADERBOARD_LOAD_FAILED');
    }
  }

  /// Snapshot minggu lalu dari API (sudah tanpa user yang di-exclude).
  /// API 404 → null (kosong). API gagal lain → cadangan file CDN beku.
  /// [cdnWeeklyTemplate] = contoh `meta.cdn.weekly` dari minggu berjalan
  /// supaya staging pakai `coem/staging-leaderboard`, bukan prod.
  Future<LeaderboardWeekSnapshot?> fetchHistoryWeek(
    String weekId, {
    String? cdnWeeklyTemplate,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/leaderboard',
        queryParameters: {'period': 'week', 'week_id': weekId},
        options: Options(receiveTimeout: const Duration(seconds: 12)),
      );
      final data = _rootMap(res.data)['data'];
      final entries = <LeaderboardEntry>[];
      if (data is List) {
        for (final raw in data) {
          if (raw is Map) {
            entries.add(
              LeaderboardEntry.fromJson(Map<String, dynamic>.from(raw)),
            );
          }
        }
      }
      return LeaderboardWeekSnapshot(
        weekId: weekId,
        entries: entries,
        finalized: true,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
    }

    final url = weeklyLeaderboardCdnUrl(
      weekId,
      templateWeeklyUrl: cdnWeeklyTemplate,
    );
    try {
      return await _fetchCdnSnapshot(url);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _fromDio(e, codeFallback: 'LEADERBOARD_LOAD_FAILED');
    } on LeaderboardApiException {
      rethrow;
    }
  }

  /// Riwayat poin mingguan + XP snapshot user (fase 4).
  Future<UserPointsHistoryViewData> fetchUserPointsHistory(
    String username, {
    int limit = 52,
  }) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/leaderboard/users/$username/points-history',
        queryParameters: {'limit': limit},
        options: Options(receiveTimeout: const Duration(seconds: 12)),
      );
      final envelope = _rootMap(res.data);
      final data = envelope['data'];
      if (data is Map) {
        return UserPointsHistoryViewData.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      throw LeaderboardApiException(
        'LEADERBOARD_LOAD_FAILED',
        code: 'LEADERBOARD_LOAD_FAILED',
      );
    } on DioException catch (e) {
      throw _fromDio(e, codeFallback: 'LEADERBOARD_LOAD_FAILED');
    }
  }

  Future<LeaderboardWeekSnapshot> _fetchCdnSnapshot(String url) async {
    try {
      final res = await _dio.get<dynamic>(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 12),
          headers: const {'Accept': 'application/json'},
        ),
      );
      final body = res.data;
      if (body is! Map) {
        throw LeaderboardApiException(
          'LEADERBOARD_LOAD_FAILED',
          code: 'LEADERBOARD_LOAD_FAILED',
        );
      }
      return LeaderboardWeekSnapshot.fromCdnJson(
        Map<String, dynamic>.from(body),
      );
    } on DioException catch (e) {
      throw _fromDio(e, codeFallback: 'LEADERBOARD_LOAD_FAILED');
    }
  }

  /// Bagikan posisi minggu berjalan ke feed. Server menolak di luar 1-25
  /// dengan `LEADERBOARD_NOT_IN_TOP`. Return peringkat yang dibagikan.
  Future<int> shareMyRank() async {
    try {
      final res = await _dio.post<dynamic>('/api/v1/leaderboard/me/share');
      final data = _rootMap(res.data)['data'];
      final rank = data is Map ? (data['rank'] as num?)?.toInt() : null;
      if (rank == null) {
        throw LeaderboardApiException(
          'LEADERBOARD_SHARE_FAILED',
          code: 'LEADERBOARD_SHARE_FAILED',
        );
      }
      return rank;
    } on DioException catch (e) {
      throw _fromDio(e, codeFallback: 'LEADERBOARD_SHARE_FAILED');
    }
  }

  LeaderboardApiException _fromDio(
    DioException e, {
    required String codeFallback,
  }) {
    final data = e.response?.data;
    final code = data is Map
        ? (data['error_code'] as String? ?? codeFallback)
        : codeFallback;
    final message = apiErrorText(data, code);
    return LeaderboardApiException(message, code: code);
  }

  Map<String, dynamic> _rootMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }
}
