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

/// Kredensial coturn time-limited dari GET /api/v1/voice/turn-creds.
class TurnCredentials {
  const TurnCredentials({
    required this.urls,
    required this.username,
    required this.credential,
    required this.ttl,
    required this.expiryEpoch,
  });

  final List<String> urls;
  final String username;
  final String credential;
  final int ttl;
  final int expiryEpoch;

  /// Sisa umur (detik) sampai expiry di username. Negatif = sudah lewat.
  int remainingSec({DateTime? now}) {
    final epoch = (now ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    return expiryEpoch - epoch;
  }

  bool get isFreshEnough => remainingSec() > 300;

  factory TurnCredentials.fromJson(Map<String, dynamic> json) {
    final urlsRaw = json['urls'];
    final urls = urlsRaw is List
        ? urlsRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];
    final username = json['username']?.toString() ?? '';
    final credential = json['credential']?.toString() ?? '';
    final ttl = switch (json['ttl']) {
      final int n => n,
      final num n => n.toInt(),
      final String s => int.tryParse(s) ?? 0,
      _ => 0,
    };
    final head = username.split(':').first;
    final expiryEpoch = int.tryParse(head) ?? 0;
    return TurnCredentials(
      urls: urls,
      username: username,
      credential: credential,
      ttl: ttl,
      expiryEpoch: expiryEpoch,
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

  TurnCredentials? _cachedTurn;

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
      if (code == 'VOICE_ALREADY_JOINED') {
        return Either.left(
          VoiceFailure(
            l10n.voiceAlreadyJoinedOtherDevice,
            errorCode: 'VOICE_ALREADY_JOINED',
          ),
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

  /// Fetch TURN creds. Cache memory; refresh jika sisa < 300 detik.
  Future<TurnCredentials?> fetchTurnCredentials({bool force = false}) async {
    final cached = _cachedTurn;
    if (!force && cached != null && cached.isFreshEnough) {
      return cached;
    }
    final res = await _dio.get<Map<String, dynamic>>(
      '/api/v1/voice/turn-creds',
    );
    final data = res.data?['data'];
    if (data is! Map) return null;
    final creds = TurnCredentials.fromJson(Map<String, dynamic>.from(data));
    if (creds.urls.isEmpty ||
        creds.username.isEmpty ||
        creds.credential.isEmpty ||
        creds.expiryEpoch <= 0) {
      return null;
    }
    _cachedTurn = creds;
    return creds;
  }

  /// 1 retry lalu null → caller connect tanpa TURN.
  Future<TurnCredentials?> resolveIceServers() async {
    try {
      final first = await fetchTurnCredentials();
      if (first != null) return first;
    } catch (_) {
      // retry below
    }
    try {
      return await fetchTurnCredentials(force: true);
    } catch (_) {
      return null;
    }
  }
}
