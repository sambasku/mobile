import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/usaha.dart';
import '../models/usaha_dto.dart';

/// Ukuran halaman daftar usaha. Batas API 500; 40 cukup untuk layar ponsel.
const usahasPageSize = 40;

/// Pagar kalau server mengulang cursor.
const usahasMaxPages = 20;

/// Katalog usaha dari API publik (`/api/v1/usaha`).
class UsahaRemoteDatasource {
  UsahaRemoteDatasource(this._dio);

  final Dio _dio;

  Future<UsahaPage> fetchPage({
    int limit = usahasPageSize,
    String? before,
    String? categoryId,
    String? regionId,
    String? villageId,
    String? kind,
    String? operationalStatus,
    String? q,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/usaha',
      queryParameters: {
        'limit': limit,
        if (before != null && before.isNotEmpty) 'before': before,
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
        if (regionId != null && regionId.isNotEmpty) 'region_id': regionId,
        if (villageId != null && villageId.isNotEmpty) 'village_id': villageId,
        if (kind != null && kind.isNotEmpty) 'kind': kind,
        if (operationalStatus != null && operationalStatus.isNotEmpty)
          'operational_status': operationalStatus,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      },
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final data = _dataMap(res.data);
    return UsahaPage(
      items: UsahaDto.listFromJson(data['items'] as List<dynamic>? ?? const []),
      nextCursor: _cursor(data),
    );
  }

  Future<Usaha?> fetchBySlug(String slug) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/usaha/${Uri.encodeComponent(slug)}',
        options: Options(receiveTimeout: const Duration(seconds: 8)),
      );
      final data = _dataMap(res.data);
      return UsahaDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<UsahaCategoryRef>> fetchCategories() async {
    final res = await _dio.get<dynamic>(
      '/api/v1/usaha-categories',
      queryParameters: {'limit': 100},
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final data = _dataMap(res.data);
    final items = data['items'];
    if (items is! List) return const [];
    return [
      for (final raw in items.whereType<Map>())
        if (raw['id'] != null && raw['name'] != null)
          UsahaCategoryRef(id: '${raw['id']}', name: '${raw['name']}'),
    ];
  }

  /// Usaha yang dikelola user login + ringkasan pengajuan pending.
  Future<UsahaMine> fetchMine() async {
    final res = await _dio.get<dynamic>('/api/v1/usaha/mine');
    final data = _dataMap(res.data);
    return UsahaMine(
      items: UsahaDto.listFromJson(data['items'] as List<dynamic>? ?? const []),
      pendingClaimCount: data['pending_claim_count'] is num
          ? (data['pending_claim_count'] as num).toInt()
          : 0,
    );
  }

  String? _cursor(Map<String, dynamic> data) {
    final cursor = data['next_cursor'];
    if (cursor is! String || cursor.trim().isEmpty) return null;
    return cursor;
  }
}

/// Panggilan pengajuan/klaim/laporan usaha.
class UsahaContributionApi {
  UsahaContributionApi(this._dio);

  final Dio _dio;

  /// Usulan usaha baru. Boleh anonim (rate limit 5/jam per IP).
  Future<void> submit(UsahaContributionDraft draft) async {
    await _send(
      () => _dio.post<dynamic>(
        '/api/v1/usaha-contributions',
        data: draft.toBody(),
      ),
    );
  }

  /// Usulan milik user yang login (kind `new` saja).
  Future<List<UsahaContribution>> mine() async {
    final res = await _send(
      () => _dio.get<dynamic>('/api/v1/usaha-contributions/mine'),
    );
    final data = _dataMap(res.data);
    final items = data['items'];
    if (items is! List) return const [];
    return [
      for (final raw in items.whereType<Map>())
        ?UsahaContributionDto.fromJson(Map<String, dynamic>.from(raw)),
    ];
  }

  /// Batalkan usulan yang masih menunggu / perlu revisi.
  Future<void> cancel(String id) async {
    await _send(
      () => _dio.delete<dynamic>(
        '/api/v1/usaha-contributions/${Uri.encodeComponent(id)}',
      ),
    );
  }

  /// Ajukan klaim pengelolaan.
  Future<void> claim(
    String slug, {
    required String contactEvidence,
    String? note,
  }) async {
    await _send(
      () => _dio.post<dynamic>(
        '/api/v1/usaha/${Uri.encodeComponent(slug)}/claims',
        data: {
          'contact_evidence': contactEvidence,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      ),
    );
  }

  /// Klaim milik user (status terbaru).
  Future<List<UsahaClaim>> myClaims() async {
    final res = await _send(
      () => _dio.get<dynamic>('/api/v1/usaha/claims/mine'),
    );
    final data = _dataMap(res.data);
    final items = data['items'];
    if (items is! List) return const [];
    return [
      for (final raw in items.whereType<Map>())
        ?UsahaClaimDto.fromJson(Map<String, dynamic>.from(raw)),
    ];
  }

  /// Batalkan klaim yang masih pending.
  Future<void> cancelClaim(String id) async {
    await _send(
      () => _dio.delete<dynamic>(
        '/api/v1/usaha/claims/${Uri.encodeComponent(id)}',
      ),
    );
  }

  /// Laporkan usaha (data usang/salah/tutup).
  Future<void> report(
    String slug, {
    required String reasonCode,
    String? note,
  }) async {
    await _send(
      () => _dio.post<dynamic>(
        '/api/v1/usaha/${Uri.encodeComponent(slug)}/reports',
        data: {
          'reason_code': reasonCode,
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      ),
    );
  }

  /// Ajukan perubahan oleh pengelola terverifikasi.
  Future<void> submitManagerChange({
    required String kind,
    required String usahaId,
    String? itemId,
    Map<String, dynamic> payload = const {},
    List<String> fields = const [],
  }) async {
    await _send(
      () => _dio.post<dynamic>(
        '/api/v1/usaha-contributions/manager',
        data: {
          'kind': kind,
          'usaha_id': usahaId,
          if (itemId != null && itemId.isNotEmpty) 'item_id': itemId,
          'payload': payload,
          if (fields.isNotEmpty) 'fields': fields,
        },
      ),
    );
  }

  /// Unggah foto usaha (multipart, maks 5 MB) - hasilnya URL publik.
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
        queryParameters: {'purpose': 'usaha'},
        data: form,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          headers: {Headers.contentTypeHeader: null},
        ),
      ),
    );
    final url = _dataMap(res.data)['url'];
    if (url is! String || url.isEmpty) {
      throw const UsahaException('Unggah foto gagal');
    }
    return url;
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
        throw UsahaException(
          message is String && message.isNotEmpty
              ? message
              : 'Gagal menyimpan. Coba lagi ya.',
          code: data['error_code'] as String?,
        );
      }
      throw const UsahaException('Gagal menyimpan. Coba lagi ya.');
    }
  }
}

Map<String, dynamic> _dataMap(Object? body) {
  if (body is Map && body['data'] is Map) {
    return Map<String, dynamic>.from(body['data'] as Map);
  }
  return const {};
}
