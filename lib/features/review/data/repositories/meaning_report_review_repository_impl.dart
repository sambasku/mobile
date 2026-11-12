import 'package:dio/dio.dart';

class MeaningReportReviewFailure implements Exception {
  const MeaningReportReviewFailure(this.message);
  final String message;
}

class MeaningReportReviewItem {
  const MeaningReportReviewItem({
    required this.id,
    required this.wordId,
    required this.meaningId,
    required this.lemma,
    required this.reasonCode,
    required this.status,
    required this.createdAt,
    this.meaningDefinition,
    this.note,
    this.username,
    this.displayName,
  });

  final String id;
  final String wordId;
  final String? meaningId;
  final String lemma;
  final String? meaningDefinition;
  final String reasonCode;
  final String? note;
  final String status;
  final String createdAt;
  final String? username;
  final String? displayName;

  factory MeaningReportReviewItem.fromJson(Map<String, dynamic> json) {
    return MeaningReportReviewItem(
      id: json['id'] as String,
      wordId: json['word_id'] as String,
      meaningId: json['meaning_id'] as String?,
      lemma: (json['lemma'] as String?) ?? '',
      meaningDefinition: json['meaning_definition'] as String?,
      reasonCode: (json['reason_code'] as String?) ?? '',
      note: json['note'] as String?,
      status: (json['status'] as String?) ?? 'open',
      createdAt: (json['created_at'] as String?) ?? '',
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
    );
  }
}

class MeaningReportReviewPage {
  const MeaningReportReviewPage({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<MeaningReportReviewItem> items;
  final String? nextCursor;
  final bool hasMore;
}

class MeaningReportReviewRepository {
  MeaningReportReviewRepository(this._dio);

  final Dio _dio;

  Future<MeaningReportReviewPage> list({
    String status = 'open',
    String target = 'meaning',
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/admin/word-reports',
        queryParameters: {
          'status': status,
          'target': target,
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );
      final data = response.data?['data'];
      final meta = response.data?['meta'];
      final items = data is List
          ? data
                .whereType<Map>()
                .map(
                  (e) => MeaningReportReviewItem.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : <MeaningReportReviewItem>[];
      return MeaningReportReviewPage(
        items: items,
        nextCursor: meta is Map ? meta['next_cursor'] as String? : null,
        hasMore: meta is Map ? (meta['has_more'] as bool? ?? false) : false,
      );
    } on DioException catch (error) {
      throw MeaningReportReviewFailure(_message(error));
    }
  }

  Future<MeaningReportReviewItem> getById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/admin/word-reports/$id',
      );
      final data = response.data?['data'];
      if (data is! Map) {
        throw const MeaningReportReviewFailure('Laporan tidak ditemukan');
      }
      return MeaningReportReviewItem.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw MeaningReportReviewFailure(_message(error));
    }
  }

  Future<void> dismiss(String id, {String? note}) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/v1/admin/word-reports/$id/dismiss',
        data: {if (note != null && note.trim().isNotEmpty) 'note': note.trim()},
      );
    } on DioException catch (error) {
      throw MeaningReportReviewFailure(_message(error));
    }
  }

  Future<void> removeMeaning(String id, {String? note}) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/v1/admin/word-reports/$id/remove-meaning',
        data: {if (note != null && note.trim().isNotEmpty) 'note': note.trim()},
      );
    } on DioException catch (error) {
      throw MeaningReportReviewFailure(_message(error));
    }
  }

  String _message(DioException error) {
    final data = error.response?.data;
    if (data is Map &&
        data['message'] is String &&
        (data['message'] as String).isNotEmpty) {
      return data['message'] as String;
    }
    return 'Gagal memproses laporan makna. Coba lagi.';
  }
}
