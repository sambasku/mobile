import 'dart:io';

import 'package:dio/dio.dart';

import '../../features/comment/domain/entities/comment_image.dart';
import 'entity_comment.dart';

/// Client komentar place / usaha / cuisine / event (teks + stiker + foto + VN).
class EntityCommentApi {
  EntityCommentApi(this._dio);

  final Dio _dio;

  String _listPath(EntityCommentTarget target, String entityId) {
    final id = Uri.encodeComponent(entityId);
    return switch (target) {
      EntityCommentTarget.place => '/api/v1/places/$id/comments',
      EntityCommentTarget.usaha => '/api/v1/usaha/$id/comments',
      EntityCommentTarget.cuisine => '/api/v1/culinary/cuisines/$id/comments',
      EntityCommentTarget.event => '/api/v1/events/$id/comments',
    };
  }

  String _audioPath(EntityCommentTarget target, String entityId) =>
      '${_listPath(target, entityId)}/audio';

  String _itemPath(EntityCommentTarget target, String commentId) {
    final id = Uri.encodeComponent(commentId);
    return switch (target) {
      EntityCommentTarget.place => '/api/v1/places/comments/$id',
      EntityCommentTarget.usaha => '/api/v1/usaha/comments/$id',
      EntityCommentTarget.cuisine => '/api/v1/culinary/comments/$id',
      EntityCommentTarget.event => '/api/v1/events/comments/$id',
    };
  }

  String _entityIdKey(EntityCommentTarget target) => switch (target) {
        EntityCommentTarget.place => 'place_id',
        EntityCommentTarget.usaha => 'usaha_id',
        EntityCommentTarget.cuisine => 'cuisine_id',
        EntityCommentTarget.event => 'event_id',
      };

  Future<EntityCommentPage> list(
    EntityCommentTarget target,
    String entityId, {
    String? cursor,
    int limit = 20,
  }) async {
    final res = await _dio.get<dynamic>(
      _listPath(target, entityId),
      queryParameters: {
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );
    final data = res.data;
    if (data is! Map) {
      return const EntityCommentPage(items: []);
    }
    final payload = data['data'];
    if (payload is! Map) {
      return const EntityCommentPage(items: []);
    }
    final rawItems = payload['items'];
    final key = _entityIdKey(target);
    final items = <EntityComment>[];
    if (rawItems is List) {
      for (final raw in rawItems.whereType<Map>()) {
        items.add(
          EntityComment.fromJson(
            Map<String, dynamic>.from(raw),
            entityIdKey: key,
          ),
        );
      }
    }
    final next = payload['next_cursor'];
    return EntityCommentPage(
      items: items,
      nextCursor: next is String && next.isNotEmpty ? next : null,
      hasMore: payload['has_more'] == true,
    );
  }

  Future<EntityComment> create(
    EntityCommentTarget target,
    String entityId, {
    String body = '',
    CommentImageStaging? image,
    String? stickerId,
  }) async {
    final res = await _dio.post<dynamic>(
      _listPath(target, entityId),
      data: {
        'body': body,
        if (stickerId != null && stickerId.trim().isNotEmpty)
          'sticker_id': stickerId.trim(),
        if (image != null)
          'image': {
            'url': image.url,
            'provider_file_id': image.providerFileId,
          },
      },
    );
    final data = res.data;
    if (data is! Map || data['data'] is! Map) {
      throw StateError('empty comment create response');
    }
    return EntityComment.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
      entityIdKey: _entityIdKey(target),
    );
  }

  Future<EntityComment> createAudio(
    EntityCommentTarget target,
    String entityId, {
    required File audioFile,
    required int durationMs,
    String? body,
  }) async {
    final form = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.uri.pathSegments.last,
      ),
      'duration_ms': durationMs,
      if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
    });
    final res = await _dio.post<dynamic>(
      _audioPath(target, entityId),
      data: form,
    );
    final data = res.data;
    if (data is! Map || data['data'] is! Map) {
      throw StateError('empty comment audio create response');
    }
    return EntityComment.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
      entityIdKey: _entityIdKey(target),
    );
  }

  Future<EntityComment> update(
    EntityCommentTarget target,
    String commentId,
    String body,
  ) async {
    final res = await _dio.patch<dynamic>(
      _itemPath(target, commentId),
      data: {'body': body},
    );
    final data = res.data;
    if (data is! Map || data['data'] is! Map) {
      throw StateError('empty comment update response');
    }
    return EntityComment.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
      entityIdKey: _entityIdKey(target),
    );
  }

  Future<void> delete(EntityCommentTarget target, String commentId) async {
    await _dio.delete<dynamic>(_itemPath(target, commentId));
  }
}
