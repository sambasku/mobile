import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/i18n/l10n.dart';

class VoiceToken {
  const VoiceToken({
    required this.token,
    required this.url,
    required this.room,
  });

  final String token;
  final String url;
  final String room;

  factory VoiceToken.fromJson(Map<String, dynamic> json) {
    return VoiceToken(
      token: json['token']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      room: json['room']?.toString() ?? '',
    );
  }
}

class VoiceFailure {
  const VoiceFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;
}

enum VoiceRoomEventKind { joined, left, disconnect, joinFailed }

class VoiceRepository {
  VoiceRepository(this._dio);

  final Dio _dio;

  /// Analitik internal (DB). Gagal diam - jangan ganggu sesi voice.
  Future<void> reportEvent({
    required VoiceRoomEventKind kind,
    String? room,
    String? errorCode,
    String? detail,
    String? platform,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/api/v1/voice/events',
        data: <String, dynamic>{
          'kind': switch (kind) {
            VoiceRoomEventKind.joined => 'joined',
            VoiceRoomEventKind.left => 'left',
            VoiceRoomEventKind.disconnect => 'disconnect',
            VoiceRoomEventKind.joinFailed => 'join_failed',
          },
          if (room != null && room.isNotEmpty) 'room': room,
          if (errorCode != null && errorCode.isNotEmpty) 'errorCode': errorCode,
          if (detail != null && detail.isNotEmpty) 'detail': detail,
          if (platform != null && platform.isNotEmpty) 'platform': platform,
        },
      );
    } catch (_) {
      // ponytail: analytics best-effort
    }
  }

  Future<Either<VoiceFailure, VoiceToken>> mintToken() async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/api/v1/voice/token');
      final data = res.data?['data'];
      if (data is! Map) {
        return Either.left(VoiceFailure(l10n.voiceJoinFailed));
      }
      final token = VoiceToken.fromJson(Map<String, dynamic>.from(data));
      if (token.token.isEmpty || token.url.isEmpty) {
        return Either.left(VoiceFailure(l10n.voiceJoinFailed));
      }
      return Either.right(token);
    } on DioException catch (e) {
      final data = e.response?.data;
      final code = data is Map
          ? (data['error_code'] ?? data['error'])?.toString()
          : null;
      final status = e.response?.statusCode;
      if (status == 403) {
        return Either.left(
          VoiceFailure(l10n.voiceRoomDisabled, errorCode: code),
        );
      }
      if (status == 409 || code == 'VOICE_ROOM_FULL') {
        return Either.left(
          VoiceFailure(l10n.voiceRoomFull, errorCode: code ?? 'VOICE_ROOM_FULL'),
        );
      }
      if (status == 503 ||
          status == 502 ||
          code == 'VOICE_UNAVAILABLE' ||
          code == 'BAD_GATEWAY') {
        return Either.left(
          VoiceFailure(l10n.voiceUnavailable, errorCode: code),
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Either.left(
          VoiceFailure(l10n.voiceUnavailable, errorCode: 'VOICE_UNAVAILABLE'),
        );
      }
      return Either.left(VoiceFailure(l10n.voiceJoinFailed, errorCode: code));
    } catch (e) {
      return Either.left(VoiceFailure(e.toString()));
    }
  }
}
