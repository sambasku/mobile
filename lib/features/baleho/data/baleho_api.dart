import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_error_text.dart';
import '../domain/baleho_models.dart';

class BalehoApiException implements Exception {
  BalehoApiException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class BalehoCreateResult {
  const BalehoCreateResult({
    required this.placementId,
    required this.creativeId,
  });

  final String placementId;
  final String creativeId;
}

class BalehoCreativeSummary {
  const BalehoCreativeSummary({
    required this.id,
    required this.fingerprint,
    this.title,
    this.mediaUrl,
    this.lastReferralUsername,
  });

  final String id;
  final String fingerprint;
  final String? title;
  final String? mediaUrl;
  final String? lastReferralUsername;

  factory BalehoCreativeSummary.fromJson(Map<String, dynamic> json) {
    return BalehoCreativeSummary(
      id: '${json['id']}',
      fingerprint: '${json['fingerprint'] ?? ''}',
      title: json['title'] as String?,
      mediaUrl: json['media_url'] as String?,
      lastReferralUsername: json['last_referral_username'] as String?,
    );
  }
}

class BalehoFrameDraft {
  const BalehoFrameDraft({
    required this.mediaType,
    required this.actionType,
    required this.actionPayload,
    this.mediaUrl,
    this.title,
    this.ctaLabel,
  });

  final String mediaType;
  final String? mediaUrl;
  final String? title;
  final String? ctaLabel;
  final String actionType;
  final String actionPayload;

  Map<String, dynamic> toJson() => {
        'media_type': mediaType,
        if (mediaUrl != null && mediaUrl!.isNotEmpty) 'media_url': mediaUrl,
        if (title != null && title!.isNotEmpty) 'title': title,
        if (ctaLabel != null && ctaLabel!.isNotEmpty) 'cta_label': ctaLabel,
        'action_type': actionType,
        'action_payload': actionPayload,
      };
}

class BalehoApi {
  BalehoApi(this._dio);

  final Dio _dio;

  Future<BalehoBoard> fetchBoard(int slide) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/baleho/boards/$slide',
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final data = _dataMap(res.data);
    return BalehoBoard.fromJson(data);
  }

  Future<BalehoCreateResult> createPlacement({
    required int col,
    required int row,
    required int w,
    required int h,
    required List<BalehoFrameDraft> frames,
    String? referralUsername,
    String? creativeId,
    String? entityType,
    String? entityId,
    int days = 30,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/baleho/placements',
        data: {
          'slide': 1,
          'col': col,
          'row': row,
          'w': w,
          'h': h,
          'days': days,
          if (referralUsername != null && referralUsername.trim().isNotEmpty)
            'referral_username': referralUsername.trim(),
          if (creativeId != null && creativeId.isNotEmpty)
            'creative_id': creativeId,
          if (entityType != null && entityType.isNotEmpty)
            'entity_type': entityType,
          if (entityId != null && entityId.isNotEmpty) 'entity_id': entityId,
          'frames': creativeId != null && creativeId.isNotEmpty
              ? <Map<String, dynamic>>[]
              : [for (final f in frames) f.toJson()],
        },
      );
      final data = _dataMap(res.data);
      return BalehoCreateResult(
        placementId: '${data['placement_id']}',
        creativeId: '${data['creative_id']}',
      );
    } on DioException catch (e) {
      throw _fromDio(e, codeFallback: 'BALEHO_CREATE_FAILED');
    }
  }

  Future<List<BalehoCreativeSummary>> listMyCreatives() async {
    try {
      final res = await _dio.get<dynamic>('/api/v1/baleho/creatives');
      final data = _dataMap(res.data);
      final items = data['items'];
      if (items is! List) return const [];
      return [
        for (final raw in items)
          if (raw is Map)
            BalehoCreativeSummary.fromJson(Map<String, dynamic>.from(raw)),
      ];
    } on DioException catch (e) {
      throw _fromDio(e, codeFallback: 'BALEHO_CREATE_FAILED');
    }
  }

  /// Fire-and-forget aman: gagal jaringan tidak dilempar ke UI.
  Future<void> recordEvent({
    required String placementId,
    String? frameId,
    required String eventType,
  }) async {
    // Placement client-only (slide 2 curated) tidak ada di DB.
    if (placementId.startsWith('baleho_fixed_')) return;
    try {
      await _dio.post<dynamic>(
        '/api/v1/baleho/events',
        data: {
          'placement_id': placementId,
          if (frameId != null && frameId.isNotEmpty) 'frame_id': frameId,
          'event_type': eventType,
        },
      );
    } catch (_) {
      // Telemetri - jangan ganggu UX.
    }
  }

  Future<String> uploadImage(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });
    try {
      final res = await _dio.post<dynamic>(
        '/api/v1/images',
        queryParameters: {'purpose': 'baleho'},
        data: form,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {Headers.contentTypeHeader: null},
        ),
      );
      final url = _dataMap(res.data)['url'];
      if (url is! String || url.isEmpty) {
        throw BalehoApiException(
          'BALEHO_UPLOAD_FAILED',
          code: 'BALEHO_UPLOAD_FAILED',
        );
      }
      return url;
    } on DioException catch (e) {
      throw _fromDio(e, codeFallback: 'BALEHO_UPLOAD_FAILED');
    }
  }

  BalehoApiException _fromDio(DioException e, {required String codeFallback}) {
    final data = e.response?.data;
    final code = data is Map
        ? (data['error_code'] as String? ?? codeFallback)
        : codeFallback;
    final message = apiErrorText(data, code);
    return BalehoApiException(message, code: code);
  }

  Map<String, dynamic> _dataMap(dynamic raw) {
    if (raw is Map && raw['data'] is Map) {
      return Map<String, dynamic>.from(raw['data'] as Map);
    }
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }
}
