import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_comment.dart';
import '../../domain/entities/event_contribution.dart';
import '../models/event_contribution_dto.dart';
import '../models/event_dto.dart';
import '../../../../core/i18n/l10n.dart';

/// Ukuran halaman daftar acara. Batas API 500; 50 cukup untuk layar
/// ponsel dan sisanya lewat `next_cursor`.
const eventsPageSize = 50;

/// Pagar kalau server mengulang cursor.
const eventsMaxPages = 20;

/// Satu halaman `GET /api/v1/events`.
class EventPage {
  const EventPage({required this.events, required this.nextCursor});

  final List<Event> events;
  final String? nextCursor;
}

/// Katalog acara dari API publik (`/api/v1/events`).
class EventRemoteDatasource {
  EventRemoteDatasource(this._dio);

  final Dio _dio;

  /// Satu halaman acara. `before` = `next_cursor` halaman sebelumnya.
  Future<EventPage> fetchPage({
    int limit = eventsPageSize,
    String? before,
    String? categoryId,
    String? villageId,
    String? regionId,
    String? placeId,
    String? q,
    bool notEnded = false,
    String? order,
    DateTime? overlapsFrom,
    DateTime? overlapsTo,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/events',
      queryParameters: {
        'limit': limit,
        if (before != null && before.isNotEmpty) 'before': before,
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
        if (villageId != null && villageId.isNotEmpty) 'village_id': villageId,
        if (regionId != null && regionId.isNotEmpty) 'region_id': regionId,
        if (placeId != null && placeId.isNotEmpty) 'place_id': placeId,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (notEnded) 'not_ended': '1',
        if (order != null && order.isNotEmpty) 'order': order,
        if (overlapsFrom != null)
          'overlaps_from': overlapsFrom.toUtc().toIso8601String(),
        if (overlapsTo != null)
          'overlaps_to': overlapsTo.toUtc().toIso8601String(),
      },
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final body = res.data;
    final data = body is Map ? body['data'] : null;
    final items = data is Map ? data['items'] : null;
    final events = <Event>[];
    if (items is List) {
      for (final raw in items.whereType<Map>()) {
        final event = EventDto.fromJson(Map<String, dynamic>.from(raw));
        if (event != null) events.add(event);
      }
    }
    return EventPage(events: events, nextCursor: _nextCursor(data));
  }

  /// Detail acara by slug.
  Future<Event?> fetchBySlug(String slug) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/events/${Uri.encodeComponent(slug)}',
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final body = res.data;
    final data = body is Map ? body['data'] : null;
    if (data is! Map) return null;
    return EventDto.fromJson(Map<String, dynamic>.from(data));
  }

  /// Hasil mark/unmark berencana datang.
  Future<({int goingCount, bool viewerGoing})> markGoing(String eventId) =>
      _toggleGoing(eventId, mark: true);

  Future<({int goingCount, bool viewerGoing})> unmarkGoing(String eventId) =>
      _toggleGoing(eventId, mark: false);

  Future<({int goingCount, bool viewerGoing})> _toggleGoing(
    String eventId, {
    required bool mark,
  }) async {
    final path = '/api/v1/events/${Uri.encodeComponent(eventId)}/going';
    final res = mark
        ? await _dio.post<dynamic>(
            path,
            options: Options(receiveTimeout: const Duration(seconds: 8)),
          )
        : await _dio.delete<dynamic>(
            path,
            options: Options(receiveTimeout: const Duration(seconds: 8)),
          );
    final data = _dataMap(res.data);
    final count = data['going_count'];
    return (
      goingCount: count is num ? count.toInt() : 0,
      viewerGoing: data['viewer_going'] == true,
    );
  }

  /// Katalog kategori acara (published).
  Future<List<EventCategoryRef>> fetchCategories() async {
    final res = await _dio.get<dynamic>(
      '/api/v1/events/categories',
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final body = res.data;
    final data = body is Map ? body['data'] : null;
    final items = data is Map ? data['items'] : null;
    if (items is! List) return const [];
    return EventContributionDto.categoriesFromJson(items);
  }

  /// Komentar satu acara (publik) - GET /api/v1/events/:id/comments.
  Future<EventCommentPage> fetchComments(
    String eventId, {
    int limit = 20,
    String? cursor,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/events/${Uri.encodeComponent(eventId)}/comments',
      queryParameters: {
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final data = _dataMap(res.data);
    return EventCommentPage.fromJson(data);
  }

  /// Kirim komentar (login) - POST /api/v1/events/:id/comments.
  Future<EventComment?> postComment(String eventId, String body) async {
    final res = await _dio.post<dynamic>(
      '/api/v1/events/${Uri.encodeComponent(eventId)}/comments',
      data: {'body': body},
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final data = _dataMap(res.data);
    if (data.isEmpty) return null;
    return EventComment.fromJson(data);
  }

  /// Edit komentar milik sendiri - PATCH /api/v1/events/comments/:id.
  Future<EventComment?> updateComment(
    String commentId,
    String body,
  ) async {
    final res = await _dio.patch<dynamic>(
      '/api/v1/events/comments/${Uri.encodeComponent(commentId)}',
      data: {'body': body},
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final data = _dataMap(res.data);
    if (data.isEmpty) return null;
    return EventComment.fromJson(data);
  }

  /// Hapus komentar milik sendiri - DELETE /api/v1/events/comments/:id.
  Future<void> deleteComment(String commentId) async {
    await _dio.delete<dynamic>(
      '/api/v1/events/comments/${Uri.encodeComponent(commentId)}',
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
  }

  static String? _nextCursor(Object? data) {
    if (data is! Map) return null;
    final cursor = data['next_cursor'];
    if (cursor is! String || cursor.trim().isEmpty) return null;
    return cursor;
  }
}

/// Panggilan usulan acara (login saja untuk `mine`; submit boleh anonim).
class EventContributionApi {
  EventContributionApi(this._dio);

  final Dio _dio;

  /// Kirim usulan. Boleh tanpa token (rate limit ketat 5/jam per IP).
  Future<void> submit(EventContributionDraft draft) async {
    await _send(
      () => _dio.post<dynamic>(
        '/api/v1/event-contributions',
        data: draft.toBody(),
      ),
    );
  }

  /// Usulan milik user yang login.
  Future<List<EventContribution>> mine() async {
    final res = await _send(
      () => _dio.get<dynamic>('/api/v1/event-contributions/mine'),
    );
    final data = _dataMap(res.data);
    final items = data['items'];
    if (items is! List) return const [];
    return [
      for (final raw in items.whereType<Map>())
        ?EventContributionDto.fromJson(Map<String, dynamic>.from(raw)),
    ];
  }

  /// Batalkan usulan yang masih menunggu.
  Future<void> cancel(String id) async {
    await _send(
      () => _dio.delete<dynamic>(
        '/api/v1/event-contributions/${Uri.encodeComponent(id)}',
      ),
    );
  }

  /// Unggah poster acara (wajib file, bukan URL) - multipart ke
  /// `POST /api/v1/event-contributions/images`, hasilnya URL publik.
  Future<String> uploadPoster(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });
    final res = await _send(
      () => _dio.post<dynamic>(
        '/api/v1/event-contributions/images',
        data: form,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {Headers.contentTypeHeader: null},
        ),
      ),
    );
    final url = _dataMap(res.data)['url'];
    if (url is! String || url.isEmpty) {
      throw EventContributionException(l10n.eventPosterUploadFailed);
    }
    return url;
  }

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        final message = data['message'];
        throw EventContributionException(
          message is String && message.isNotEmpty
              ? message
              : l10n.eventSaveFailed,
          code: data['error_code'] as String?,
        );
      }
      throw EventContributionException(l10n.eventSaveFailed);
    }
  }
}

Map<String, dynamic> _dataMap(Object? body) {
  if (body is Map && body['data'] is Map) {
    return Map<String, dynamic>.from(body['data'] as Map);
  }
  return const {};
}
