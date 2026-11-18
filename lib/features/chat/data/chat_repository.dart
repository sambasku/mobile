import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/i18n/l10n.dart';
import '../domain/chat_models.dart';

/// API chat publik.
///
/// F2: histori + mutasi lewat REST saja. Supabase realtime
/// (`supabase_flutter` + subscribe `chat_messages`) ditunda - belum ada
/// bootstrap env di flavor mobile. Refresh: load awal, optimistic append
/// saat kirim, pull-to-refresh, dan resume lifecycle.
class ChatRepository {
  ChatRepository(this._dio);

  final Dio _dio;

  static const _base = '/api/v1/chat';

  Future<Either<ChatFailure, ChatCapabilities>> getCapabilities() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('$_base/capabilities');
      final data = res.data?['data'];
      if (data is! Map) {
        return Either.left(ChatFailure(l10n.chatLoadFailed));
      }
      return Either.right(
        ChatCapabilities.fromJson(Map<String, dynamic>.from(data)),
      );
    } on DioException catch (e) {
      return Either.left(_mapDio(e, l10n.chatLoadFailed));
    } catch (e) {
      return Either.left(ChatFailure(e.toString()));
    }
  }

  Future<Either<ChatFailure, ChatMessagePage>> listMessages({
    int limit = 50,
    String? beforeCreatedAt,
    String? beforeId,
    String? afterCreatedAt,
    String? afterId,
  }) async {
    try {
      final query = <String, dynamic>{
        'limit': limit,
        if (beforeCreatedAt != null && beforeId != null) ...{
          'before_created_at': beforeCreatedAt,
          'before_id': beforeId,
        },
        if (afterCreatedAt != null && afterId != null) ...{
          'after_created_at': afterCreatedAt,
          'after_id': afterId,
        },
      };
      final res = await _dio.get<Map<String, dynamic>>(
        '$_base/messages',
        queryParameters: query,
      );
      return Either.right(_parsePage(res.data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, l10n.chatLoadFailed));
    } catch (e) {
      return Either.left(ChatFailure(e.toString()));
    }
  }

  Future<Either<ChatFailure, ChatMessage>> sendText({
    required String body,
    String? replyToId,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$_base/messages',
        data: {
          'kind': 'text',
          'body': body.trim(),
          if (replyToId != null && replyToId.isNotEmpty)
            'reply_to_id': replyToId,
        },
      );
      return Either.right(_parseMessage(res.data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, l10n.chatSendFailed));
    } catch (e) {
      return Either.left(ChatFailure(e.toString()));
    }
  }

  Future<Either<ChatFailure, ChatMessage>> sendSticker({
    required String stickerId,
    String? replyToId,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '$_base/messages',
        data: {
          'kind': 'sticker',
          'sticker_id': stickerId,
          if (replyToId != null && replyToId.isNotEmpty)
            'reply_to_id': replyToId,
        },
      );
      return Either.right(_parseMessage(res.data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, l10n.chatSendFailed));
    } catch (e) {
      return Either.left(ChatFailure(e.toString()));
    }
  }

  Future<Either<ChatFailure, ChatMessage>> sendVoice({
    required File audioFile,
    required int durationMs,
    String? replyToId,
  }) async {
    try {
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
        if (replyToId != null && replyToId.isNotEmpty) 'reply_to_id': replyToId,
      });

      final res = await _dio.post<Map<String, dynamic>>(
        '$_base/messages/voice',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return Either.right(_parseMessage(res.data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, l10n.chatVoiceSendFailed));
    } catch (e) {
      return Either.left(ChatFailure(e.toString()));
    }
  }

  Future<Either<ChatFailure, ChatMessage>> deleteMessage(String id) async {
    try {
      final res = await _dio.delete<Map<String, dynamic>>(
        '$_base/messages/$id',
      );
      return Either.right(_parseMessage(res.data));
    } on DioException catch (e) {
      return Either.left(_mapDio(e, l10n.chatDeleteFailed));
    } catch (e) {
      return Either.left(ChatFailure(e.toString()));
    }
  }

  ChatMessagePage _parsePage(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is! Map) {
      return const ChatMessagePage(items: [], hasMore: false);
    }
    final items = <ChatMessage>[];
    final rawItems = data['items'];
    if (rawItems is List) {
      for (final raw in rawItems.whereType<Map>()) {
        items.add(ChatMessage.fromJson(Map<String, dynamic>.from(raw)));
      }
    }
    return ChatMessagePage(items: items, hasMore: data['has_more'] == true);
  }

  ChatMessage _parseMessage(Map<String, dynamic>? body) {
    final data = body?['data'];
    if (data is! Map) {
      throw DioException(
        requestOptions: RequestOptions(path: _base),
        message: l10n.chatSendFailed,
      );
    }
    return ChatMessage.fromJson(Map<String, dynamic>.from(data));
  }

  ChatFailure _mapDio(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map) {
      var message = data['message']?.toString() ?? fallback;
      if (error.response?.statusCode == 429) {
        final retry = error.response?.headers.value('retry-after');
        if (retry != null && retry.isNotEmpty) {
          message = '$message ($retry)';
        }
      }
      return ChatFailure(message, errorCode: data['error_code']?.toString());
    }
    return ChatFailure(switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => l10n.chatServerTimeout,
      DioExceptionType.connectionError => l10n.chatConnectionFailed,
      _ => fallback,
    });
  }
}
