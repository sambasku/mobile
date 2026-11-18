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

class VoiceRepository {
  VoiceRepository(this._dio);

  final Dio _dio;

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
      if (status == 503) {
        return Either.left(
          VoiceFailure(l10n.voiceUnavailable, errorCode: code),
        );
      }
      return Either.left(VoiceFailure(l10n.voiceJoinFailed, errorCode: code));
    } catch (e) {
      return Either.left(VoiceFailure(e.toString()));
    }
  }
}
