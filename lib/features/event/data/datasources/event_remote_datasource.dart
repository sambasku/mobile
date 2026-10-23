import 'package:dio/dio.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_contribution.dart';
import '../models/event_contribution_dto.dart';
import '../models/event_dto.dart';

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
    String? placeId,
    String? q,
    bool notEnded = false,
    String? order,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/events',
      queryParameters: {
        'limit': limit,
        if (before != null && before.isNotEmpty) 'before': before,
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
        if (villageId != null && villageId.isNotEmpty)
          'village_id': villageId,
        if (placeId != null && placeId.isNotEmpty) 'place_id': placeId,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
        if (notEnded) 'not_ended': '1',
        if (order != null && order.isNotEmpty) 'order': order,
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
              : 'Gagal menyimpan. Coba lagi.',
          code: data['error_code'] as String?,
        );
      }
      throw const EventContributionException('Gagal menyimpan. Coba lagi.');
    }
  }
}

Map<String, dynamic> _dataMap(Object? body) {
  if (body is Map && body['data'] is Map) {
    return Map<String, dynamic>.from(body['data'] as Map);
  }
  return const {};
}
