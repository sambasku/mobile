import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/inbox_notification.dart';
import '../../domain/entities/inbox_notification_page.dart';
import '../../domain/failures/notification_failure.dart';
import '../../domain/repositories/notification_repository.dart';

InboxNotification parseInboxNotification(Map<String, dynamic> map) {
  final rawImage = map['image_url']?.toString();
  return InboxNotification(
    id: map['id']?.toString() ?? '',
    type: map['type']?.toString() ?? '',
    title: map['title']?.toString() ?? '',
    body: map['body']?.toString() ?? '',
    targetKind: map['target_kind']?.toString() ?? 'contribution',
    targetId: map['target_id']?.toString() ?? '',
    createdAt: map['created_at']?.toString() ?? '',
    readAt: map['read_at']?.toString(),
    actionKind: map['action_kind']?.toString(),
    actionValue: map['action_value']?.toString(),
    imageUrl: (rawImage != null && rawImage.isNotEmpty) ? rawImage : null,
  );
}

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Either<NotificationFailure, InboxNotificationPage>> listMine({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/notifications',
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final body = res.data ?? const <String, dynamic>{};
      final data = body['data'];
      final meta = body['meta'];
      final items = <InboxNotification>[];
      if (data is List) {
        for (final raw in data.whereType<Map>()) {
          items.add(parseInboxNotification(Map<String, dynamic>.from(raw)));
        }
      }
      return Either.right(
        InboxNotificationPage(
          items: items,
          nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
          hasMore: meta is Map ? meta['has_more'] == true : false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal memuat notifikasi'));
    } catch (error) {
      return Either.left(NotificationFailure(error.toString()));
    }
  }

  @override
  Future<Either<NotificationFailure, int>> unreadCount() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/notifications/unread-count',
      );
      final data = res.data?['data'];
      final count = data is Map ? data['unread_count'] : 0;
      return Either.right(count is int ? count : int.tryParse('$count') ?? 0);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal memuat jumlah notifikasi'));
    } catch (error) {
      return Either.left(NotificationFailure(error.toString()));
    }
  }

  @override
  Future<Either<NotificationFailure, bool>> markRead(String id) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/notifications/$id/read',
      );
      final data = res.data?['data'];
      return Either.right(data is Map && data['already_read'] == true);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal menandai notifikasi'));
    } catch (error) {
      return Either.left(NotificationFailure(error.toString()));
    }
  }

  @override
  Future<Either<NotificationFailure, int>> markAllRead() async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/v1/notifications/read-all',
      );
      final data = res.data?['data'];
      final updated = data is Map ? data['updated'] : 0;
      return Either.right(
        updated is int ? updated : int.tryParse('$updated') ?? 0,
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal menandai semua notifikasi'));
    } catch (error) {
      return Either.left(NotificationFailure(error.toString()));
    }
  }

  NotificationFailure _mapDio(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map) {
      return NotificationFailure(
        data['message']?.toString() ?? fallback,
        errorCode: data['error_code']?.toString(),
      );
    }
    return NotificationFailure(fallback);
  }
}
