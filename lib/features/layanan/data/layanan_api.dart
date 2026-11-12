import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/i18n/l10n.dart';
import '../domain/layanan.dart';

class LayananException implements Exception {
  LayananException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class LayananApi {
  LayananApi(this._dio);

  final Dio _dio;

  Future<List<LayananEntry>> list({String? regionId, String? category}) async {
    final params = <String, dynamic>{};
    if (regionId != null && regionId.isNotEmpty) {
      params['region_id'] = regionId;
    }
    if (category != null && category.isNotEmpty) {
      params['category'] = category;
    }
    final res = await _dio.get<dynamic>(
      '/api/v1/layanan',
      queryParameters: params.isEmpty ? null : params,
    );
    final data = _map(res.data);
    final items = data['items'];
    if (items is! List) return const [];
    return items.whereType<Map>().map((raw) => _entry(raw)).toList();
  }

  Future<LayananEntry?> bySlug(String slug) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/layanan/${Uri.encodeComponent(slug)}',
      );
      return _entry(_map(res.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> submit(Map<String, dynamic> body) async {
    await _dio.post<dynamic>('/api/v1/layanan-contributions', data: body);
  }

  /// Unggah logo layanan (multipart, maks 5 MB) - hasilnya URL publik.
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
        queryParameters: {'purpose': 'layanan'},
        data: form,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {Headers.contentTypeHeader: null},
        ),
      );
      final url = _map(res.data)['url'];
      if (url is! String || url.isEmpty) {
        throw LayananException(l10n.layananUploadImageFailed);
      }
      return url;
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map) {
        final message = data['message'];
        throw LayananException(
          message is String && message.isNotEmpty
              ? message
              : l10n.layananUploadImageFailed,
          code: data['error_code'] as String?,
        );
      }
      throw LayananException(l10n.layananUploadImageFailed);
    }
  }

  Future<List<LayananProposal>> mine() async {
    final res = await _dio.get<dynamic>('/api/v1/layanan-contributions/mine');
    final items = _map(res.data)['items'];
    if (items is! List) return const [];
    return items.whereType<Map>().map((raw) {
      final payload = raw['payload'];
      final map = payload is Map ? payload : const {};
      return LayananProposal(
        id: '${raw['id']}',
        kind: '${raw['kind']}',
        status: '${raw['status']}',
        name: '${map['name'] ?? ''}',
        phones: _phones(map['phones']),
        revisionNote: raw['revision_note'] as String?,
      );
    }).toList();
  }

  Map<String, dynamic> _map(Object? body) {
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map) return Map<String, dynamic>.from(body);
    return const {};
  }

  LayananEntry _entry(Map raw) {
    final updated = DateTime.tryParse('${raw['updated_at']}') ?? DateTime.now();
    return LayananEntry(
      id: '${raw['id']}',
      slug: '${raw['slug']}',
      category: '${raw['category']}',
      name: '${raw['name']}',
      phones: _phones(raw['phones']),
      logoUrl: raw['logo_url'] as String?,
      addressText: raw['address_text'] as String?,
      lat: (raw['lat'] as num?)?.toDouble(),
      lng: (raw['lng'] as num?)?.toDouble(),
      mapsUrl: raw['maps_url'] as String?,
      regionId: '${raw['region_id']}',
      regionName: raw['region_name'] as String?,
      regionSlug: raw['region_slug'] as String?,
      villageName: raw['village_name'] as String?,
      note: raw['note'] as String?,
      updatedAt: updated.toLocal(),
    );
  }

  List<LayananPhone> _phones(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((row) {
          return LayananPhone(
            phone: '${row['phone'] ?? ''}',
            note: row['note'] as String?,
            whatsapp: row['whatsapp'] as String?,
          );
        })
        .where((p) => p.phone.isNotEmpty)
        .toList();
  }
}

String layananErrorMessage(Object error) {
  if (error is LayananException) return error.message;
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
  }
  return '';
}
