import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/i18n/l10n.dart';
import '../domain/jinye_models.dart';

class JinyeRepository {
  JinyeRepository(this._dio);

  final Dio _dio;

  static const _base = '/api/v1/jinye';

  Future<JinyeUploadCredentials> getUploadToken() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '$_base/upload-token',
        queryParameters: {'folder': '/jinye'},
      );
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw DioException(
          requestOptions: res.requestOptions,
          message: l10n.jinyeResponseIncomplete,
        );
      }
      return JinyeUploadCredentials.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 503) {
        final code = (e.response?.data is Map)
            ? (e.response!.data as Map)['error_code']
            : null;
        if (code == 'IMAGE_UPLOAD_UNAVAILABLE') {
          throw const JinyeImageUploadUnavailable();
        }
      }
      rethrow;
    }
  }

  Future<JinyeItem> create({
    String body = '',
    List<JinyeImageRef> images = const [],
    bool hasPendingAudio = false,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      _base,
      data: {
        'body': body.trim(),
        if (images.isNotEmpty)
          'images': [for (final i in images) i.toJson()],
        if (hasPendingAudio) 'has_pending_audio': true,
      },
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeItem.fromJson(data);
  }

  Future<JinyeItem> attachAudio({
    required String jinyeId,
    required File audioFile,
    required int durationMs,
  }) async {
    final name = audioFile.path.split(Platform.pathSeparator).last;
    final lower = name.toLowerCase();
    final (mimeType, filename) = lower.endsWith('.wav')
        ? (
            DioMediaType('audio', 'wav'),
            name.endsWith('.wav') ? name : 'recording.wav',
          )
        : lower.endsWith('.webm')
            ? (DioMediaType('audio', 'webm'), 'recording.webm')
            : lower.endsWith('.ogg')
                ? (DioMediaType('audio', 'ogg'), 'recording.ogg')
                : lower.endsWith('.mp3')
                    ? (DioMediaType('audio', 'mpeg'), 'recording.mp3')
                    : (DioMediaType('audio', 'mp4'), 'recording.m4a');

    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFile.path,
        filename: filename,
        contentType: mimeType,
      ),
      'duration_ms': durationMs,
    });

    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/$jinyeId/audio',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeItem.fromJson(data);
  }

  Future<JinyePage> listPublished({
    int limit = 20,
    String? cursor,
    String? username,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      _base,
      queryParameters: {
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        if (username != null && username.isNotEmpty) 'username': username,
      },
    );
    final raw = res.data?['data'];
    if (raw is! List) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    final items = raw
        .whereType<Map<String, dynamic>>()
        .map(JinyeItem.fromJson)
        .toList();
    final meta = res.data?['meta'];
    final next = meta is Map ? meta['next_cursor'] as String? : null;
    return JinyePage(items: items, nextCursor: next);
  }

  Future<JinyeItem> getDetail(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('$_base/$id');
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeItem.fromJson(data);
  }

  Future<void> delete(String id) async {
    await _dio.delete<Map<String, dynamic>>('$_base/$id');
  }

  Future<JinyePage> listArchived({int limit = 20, String? cursor}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_base/archived',
      queryParameters: {
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );
    final raw = res.data?['data'];
    if (raw is! List) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    final items = raw
        .whereType<Map<String, dynamic>>()
        .map(JinyeItem.fromJson)
        .toList();
    final meta = res.data?['meta'];
    final next = meta is Map ? meta['next_cursor'] as String? : null;
    return JinyePage(items: items, nextCursor: next);
  }

  Future<JinyeItem> archive(String id) async {
    final res = await _dio.post<Map<String, dynamic>>('$_base/$id/archive');
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeItem.fromJson(data);
  }

  Future<JinyeItem> unarchive(String id) async {
    final res = await _dio.post<Map<String, dynamic>>('$_base/$id/unarchive');
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeItem.fromJson(data);
  }

  Future<JinyeItem> pin(String id) async {
    final res = await _dio.post<Map<String, dynamic>>('$_base/$id/pin');
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeItem.fromJson(data);
  }

  Future<void> unpin(String id) async {
    await _dio.delete<Map<String, dynamic>>('$_base/$id/pin');
  }

  Future<List<JinyeLemmaLink>> listLemmaLinks(String jinyeId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_base/$jinyeId/lemma-links',
    );
    final raw = res.data?['data'];
    if (raw is! List) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return raw
        .whereType<Map>()
        .map((e) => JinyeLemmaLink.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<JinyeLemmaLink> createLemmaLink({
    required String jinyeId,
    required int start,
    required int end,
    required String wordId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/$jinyeId/lemma-links',
      data: {
        'start': start,
        'end': end,
        'word_id': wordId,
      },
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeLemmaLink.fromJson(data);
  }

  Future<JinyeLemmaLink> proposeLemmaCorrection({
    required String jinyeId,
    required String linkId,
    required String wordId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/$jinyeId/lemma-links/$linkId/corrections',
      data: {'word_id': wordId},
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeLemmaLink.fromJson(data);
  }

  Future<JinyeLemmaLink> resolveLemmaCorrection({
    required String jinyeId,
    required String linkId,
    required String action,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/$jinyeId/lemma-links/$linkId/resolve',
      data: {'action': action},
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeLemmaLink.fromJson(data);
  }

  Future<void> deleteLemmaLink({
    required String jinyeId,
    required String linkId,
  }) async {
    await _dio.delete<Map<String, dynamic>>(
      '$_base/$jinyeId/lemma-links/$linkId',
    );
  }

  Future<JinyePromoteResult> promoteExample({
    required String jinyeId,
    required String wordId,
    String? meaningId,
    bool includeAudio = false,
    String? targetSentence,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/$jinyeId/promote-example',
      data: {
        'word_id': wordId,
        if (meaningId != null && meaningId.isNotEmpty) 'meaning_id': meaningId,
        'include_audio': includeAudio,
        if (targetSentence != null && targetSentence.trim().isNotEmpty)
          'target_sentence': targetSentence.trim(),
      },
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyePromoteResult.fromJson(data);
  }

  Future<List<JinyeTranslation>> listTranslations(String jinyeId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_base/$jinyeId/translations',
    );
    final raw = res.data?['data'];
    if (raw is! List) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return raw
        .whereType<Map>()
        .map((e) => JinyeTranslation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<JinyeTranslation> createTranslation({
    required String jinyeId,
    required String bodyId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/$jinyeId/translations',
      data: {'body_id': bodyId.trim()},
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeTranslation.fromJson(data);
  }

  Future<JinyeTranslation> resolveTranslation({
    required String jinyeId,
    required String translationId,
    required String action,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/$jinyeId/translations/$translationId/resolve',
      data: {'action': action},
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeTranslation.fromJson(data);
  }

  Future<List<JinyeComment>> listComments(String jinyeId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_base/$jinyeId/comments',
    );
    final raw = res.data?['data'];
    if (raw is! List) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return raw
        .whereType<Map<String, dynamic>>()
        .map(JinyeComment.fromJson)
        .toList();
  }

  Future<JinyeComment> createComment({
    required String jinyeId,
    String body = '',
    String? parentId,
    List<JinyeImageRef> images = const [],
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '$_base/$jinyeId/comments',
      data: {
        'body': body.trim(),
        if (parentId != null && parentId.isNotEmpty) 'parent_id': parentId,
        if (images.isNotEmpty)
          'images': [for (final i in images) i.toJson()],
      },
    );
    final data = res.data?['data'];
    if (data is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        message: l10n.jinyeResponseIncomplete,
      );
    }
    return JinyeComment.fromJson(data);
  }

  Future<void> deleteComment({
    required String jinyeId,
    required String commentId,
  }) async {
    await _dio.delete<Map<String, dynamic>>(
      '$_base/$jinyeId/comments/$commentId',
    );
  }

  /// Laporkan Jinye / komen. [targetType] `jinye` | `jinye_comment`.
  Future<void> report({
    required String targetType,
    required String targetId,
    required String reasonCode,
    String? note,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '$_base/reports',
        data: {
          'target_type': targetType,
          'target_id': targetId,
          'reason_code': reasonCode,
          'note': ?note,
        },
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = data is Map ? data['message'] : null;
      throw JinyeFailure(
        msg is String && msg.isNotEmpty
            ? msg
            : l10n.jinyeReportFailed,
      );
    }
  }
}
