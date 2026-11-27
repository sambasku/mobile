import 'dart:io';

import 'package:dio/dio.dart';

import '../../features/comment/domain/entities/comment_image.dart';
import 'entity_comment.dart';

/// Client komentar seragam untuk semua 8 target (teks + stiker + foto + VN + 2-level reply + edit history).
class EntityCommentApi {
  EntityCommentApi(this._dio);

  final Dio _dio;

  String _listPath(EntityCommentTarget target, String entityId) {
    final id = Uri.encodeComponent(entityId);
    return switch (target) {
      EntityCommentTarget.word => '/api/v1/words/$id/comments',
      EntityCommentTarget.article => '/api/v1/encyclopedia/articles/$id/comments',
      EntityCommentTarget.jinye => '/api/v1/jinye/$id/comments',
      EntityCommentTarget.place => '/api/v1/places/$id/comments',
      EntityCommentTarget.usaha => '/api/v1/usaha/$id/comments',
      EntityCommentTarget.cuisine => '/api/v1/culinary/cuisines/$id/comments',
      EntityCommentTarget.event => '/api/v1/events/$id/comments',
      EntityCommentTarget.karya => '/api/v1/karya/$id/comments',
    };
  }

  String _audioPath(EntityCommentTarget target, String entityId) =>
      '${_listPath(target, entityId)}/audio';

  String _itemPath(
    EntityCommentTarget target,
    String entityId,
    String commentId,
  ) {
    final cid = Uri.encodeComponent(commentId);
    final eid = Uri.encodeComponent(entityId);
    return switch (target) {
      EntityCommentTarget.word => '/api/v1/comments/$cid',
      EntityCommentTarget.article => '/api/v1/encyclopedia/comments/$cid',
      EntityCommentTarget.jinye => '/api/v1/jinye/$eid/comments/$cid',
      EntityCommentTarget.place => '/api/v1/places/comments/$cid',
      EntityCommentTarget.usaha => '/api/v1/usaha/comments/$cid',
      EntityCommentTarget.cuisine => '/api/v1/culinary/comments/$cid',
      EntityCommentTarget.event => '/api/v1/events/comments/$cid',
      EntityCommentTarget.karya => '/api/v1/karya/comments/$cid',
    };
  }

  String _editHistoryPath(
    EntityCommentTarget target,
    String entityId,
    String commentId,
  ) =>
      '${_itemPath(target, entityId, commentId)}/edit-history';

  String _entityIdKey(EntityCommentTarget target) => switch (target) {
        EntityCommentTarget.word => 'word_id',
        EntityCommentTarget.article => 'article_id',
        EntityCommentTarget.jinye => 'jinye_id',
        EntityCommentTarget.place => 'place_id',
        EntityCommentTarget.usaha => 'usaha_id',
        EntityCommentTarget.cuisine => 'cuisine_id',
        EntityCommentTarget.event => 'event_id',
        EntityCommentTarget.karya => 'karya_id',
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
        if (target != EntityCommentTarget.jinye) 'limit': limit,
        if (target != EntityCommentTarget.jinye &&
            cursor != null &&
            cursor.isNotEmpty)
          'cursor': cursor,
      },
    );
    final data = res.data;
    if (data is! Map) {
      return const EntityCommentPage(items: []);
    }
    final payload = data['data'];
    final key = _entityIdKey(target);

    // Format A: { data: { items: [...], next_cursor, has_more } }
    if (payload is Map) {
      final rawItems = payload['items'];
      final items = _parseList(rawItems, key);
      final next = payload['next_cursor'];
      return EntityCommentPage(
        items: items,
        nextCursor: next is String && next.isNotEmpty ? next : null,
        hasMore: payload['has_more'] == true,
      );
    }

    // Format B (word & jinye): { data: [...], meta?: { next_cursor, has_more } }
    if (payload is List) {
      final items = _parseList(payload, key);
      final meta = data['meta'];
      String? nextCursor;
      var hasMore = false;
      if (meta is Map) {
        final next = meta['next_cursor'];
        if (next is String && next.isNotEmpty) nextCursor = next;
        hasMore = meta['has_more'] == true;
      }
      return EntityCommentPage(
        items: items,
        nextCursor: nextCursor,
        hasMore: hasMore,
      );
    }

    return const EntityCommentPage(items: []);
  }

  List<EntityComment> _parseList(Object? rawItems, String entityIdKey) {
    final items = <EntityComment>[];
    if (rawItems is List) {
      for (final raw in rawItems.whereType<Map>()) {
        items.add(
          EntityComment.fromJson(
            Map<String, dynamic>.from(raw),
            entityIdKey: entityIdKey,
          ),
        );
      }
    }
    return items;
  }

  Future<EntityComment> create(
    EntityCommentTarget target,
    String entityId, {
    String body = '',
    String? parentId,
    CommentImageStaging? image,
    String? stickerId,
  }) async {
    final payload = <String, dynamic>{
      'body': body,
      if (parentId != null && parentId.trim().isNotEmpty)
        'parent_id': parentId.trim(),
      if (stickerId != null && stickerId.trim().isNotEmpty)
        'sticker_id': stickerId.trim(),
    };
    if (image != null) {
      if (target == EntityCommentTarget.article) {
        payload['image_url'] = image.url;
      } else if (target == EntityCommentTarget.jinye) {
        payload['images'] = [
          {'url': image.url, 'provider_file_id': image.providerFileId},
        ];
      } else {
        payload['image'] = {
          'url': image.url,
          'provider_file_id': image.providerFileId,
        };
      }
    }

    final res = await _dio.post<dynamic>(
      _listPath(target, entityId),
      data: payload,
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
    String? parentId,
  }) async {
    final form = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFile.path,
        filename: audioFile.uri.pathSegments.last,
      ),
      'duration_ms': durationMs,
      if (body != null && body.trim().isNotEmpty) 'body': body.trim(),
      if (parentId != null && parentId.trim().isNotEmpty)
        'parent_id': parentId.trim(),
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
    String entityId,
    String commentId,
    String body,
  ) async {
    final res = await _dio.patch<dynamic>(
      _itemPath(target, entityId, commentId),
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

  Future<void> delete(
    EntityCommentTarget target,
    String entityId,
    String commentId,
  ) async {
    await _dio.delete<dynamic>(_itemPath(target, entityId, commentId));
  }

  Future<EntityCommentEditHistory> getEditHistory(
    EntityCommentTarget target,
    String entityId,
    String commentId,
  ) async {
    final res = await _dio.get<dynamic>(
      _editHistoryPath(target, entityId, commentId),
    );
    final data = res.data;
    if (data is! Map || data['data'] is! Map) {
      throw StateError('empty comment edit history response');
    }
    return EntityCommentEditHistory.fromJson(
      Map<String, dynamic>.from(data['data'] as Map),
    );
  }
}
