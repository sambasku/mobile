import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/i18n/l10n.dart';

class PlaceContributionException implements Exception {
  const PlaceContributionException(this.message, {this.code});

  final String message;
  final String? code;
}

class PlaceOption {
  const PlaceOption({required this.id, required this.name});

  final String id;
  final String name;
}

class PlaceProposal {
  const PlaceProposal({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    this.placeId,
    this.type,
    this.rejectReason,
  });

  final String id;
  final String name;
  final String status;
  final int createdAt;
  final String? placeId;
  final String? type;

  /// Copy alasan penolakan siap tampil (label + catatan) saat ditolak.
  final String? rejectReason;
}

/// Panggilan usulan wisata. Kredit diisi server, bukan klien.
class PlaceContributionApi {
  PlaceContributionApi(this._dio);

  final Dio _dio;

  Future<List<PlaceOption>> categories() =>
      _options('/api/v1/place-categories', {'limit': 100});

  Future<List<PlaceOption>> regions({required String type, String? parentId}) =>
      _options('/api/v1/regions', {
        'limit': 200,
        'type': type,
        'parent_id': ?parentId,
      });

  Future<String> uploadImage(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });
    final res = await _send(
      () => _dio.post<dynamic>(
        '/api/v1/images',
        queryParameters: const {'purpose': 'place'},
        data: form,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {Headers.contentTypeHeader: null},
        ),
      ),
    );
    final data = _dataMap(res.data);
    final url = data['url'];
    if (url is! String || url.isEmpty) {
      throw PlaceContributionException(l10n.exploreUploadImageFailed);
    }
    return url;
  }

  Future<void> submit(Map<String, dynamic> body) async {
    await _send(
      () => _dio.post<dynamic>('/api/v1/place-contributions', data: body),
    );
  }

  Future<void> appendImages(String slug, List<String> urls) async {
    await _send(
      () => _dio.post<dynamic>(
        '/api/v1/places/${Uri.encodeComponent(slug)}/images',
        data: {'urls': urls},
      ),
    );
  }

  Future<List<PlaceProposal>> mine() async {
    final res = await _send(
      () => _dio.get<dynamic>('/api/v1/place-contributions/mine'),
    );
    final data = _dataMap(res.data);
    final items = data['items'];
    if (items is! List) return const [];
    return [
      for (final raw in items.whereType<Map>())
        PlaceProposal(
          id: '${raw['id']}',
          name: '${(raw['payload'] as Map?)?['name'] ?? 'Usulan'}',
          status: '${raw['status'] ?? 'pending'}',
          createdAt: (raw['created_at'] as num?)?.toInt() ?? 0,
          placeId: raw['place_id'] == null ? null : '${raw['place_id']}',
          type: () {
            final payload = raw['payload'];
            if (payload is! Map) return null;
            final type = payload['type'];
            return type is String && type.isNotEmpty ? type : null;
          }(),
          rejectReason: raw['reject_reason_display'] == null
              ? null
              : '${raw['reject_reason_display']}',
        ),
    ];
  }

  Future<void> cancel(String id) async {
    await _send(
      () => _dio.delete<dynamic>(
        '/api/v1/place-contributions/${Uri.encodeComponent(id)}',
      ),
    );
  }

  Future<List<PlaceOption>> _options(
    String path,
    Map<String, dynamic> query,
  ) async {
    final res = await _send(
      () => _dio.get<dynamic>(path, queryParameters: query),
    );
    final data = _dataMap(res.data);
    final items = data['items'];
    if (items is! List) return const [];
    return [
      for (final raw in items.whereType<Map>())
        if (raw['id'] != null && raw['name'] != null)
          PlaceOption(id: '${raw['id']}', name: '${raw['name']}'),
    ];
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
        throw PlaceContributionException(
          message is String && message.isNotEmpty
              ? message
              : l10n.placeSaveFailed,
          code: data['error_code'] as String?,
        );
      }
      throw PlaceContributionException(l10n.placeSaveFailed);
    }
  }
}

Map<String, dynamic> _dataMap(Object? body) {
  if (body is Map && body['data'] is Map) {
    return Map<String, dynamic>.from(body['data'] as Map);
  }
  return const {};
}
