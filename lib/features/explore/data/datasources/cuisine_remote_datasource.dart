import 'package:dio/dio.dart';
import '../models/cuisine_dto.dart';

/// Ukuran halaman daftar kuliner. Batas API 500; 40 cukup untuk ponsel.
const cuisinesPageSize = 40;

/// Pagar kalau server mengulang cursor.
const cuisinesMaxPages = 20;

/// Katalog kuliner dari API publik (`/api/v1/culinary/cuisines`).
///
/// Pindah dari CDN `cuisines.json` (fitur kuliner): data kini dimoderasi
/// backend, atribusi gambar tetap verbatim dari kolom `images_json`.
class CuisineRemoteDatasource {
  CuisineRemoteDatasource(this._dio);

  final Dio _dio;

  /// Satu halaman kuliner. `q` difilter server (LIKE nama).
  Future<CuisinePage> fetchPage({
    int limit = cuisinesPageSize,
    String? before,
    String? categoryId,
    String? q,
  }) async {
    final res = await _dio.get<dynamic>(
      '/api/v1/culinary/cuisines',
      queryParameters: {
        'limit': limit,
        if (before != null && before.isNotEmpty) 'before': before,
        if (categoryId != null && categoryId.isNotEmpty)
          'category_id': categoryId,
        if (q != null && q.trim().isNotEmpty) 'q': q.trim(),
      },
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final data = _dataMap(res.data);
    return CuisinePage(
      items: CuisineDto.fromJson(data).cuisines,
      nextCursor: _cursor(data),
    );
  }

  Future<void> recordView(String slug) async {
    await _dio.post<dynamic>(
      '/api/v1/culinary/cuisines/${Uri.encodeComponent(slug)}/view',
      options: Options(sendTimeout: const Duration(seconds: 5)),
    );
  }

  /// Detail by slug + `usaha[]` (JOIN relasi). Null bila 404.
  Future<CuisineDtoItem?> fetchBySlug(String slug) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/v1/culinary/cuisines/${Uri.encodeComponent(slug)}',
        options: Options(receiveTimeout: const Duration(seconds: 8)),
      );
      return CuisineDto.itemFromJson(_dataMap(res.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}

/// Satu halaman kuliner + cursor berikutnya.
class CuisinePage {
  const CuisinePage({required this.items, this.nextCursor});

  final List<CuisineDtoItem> items;
  final String? nextCursor;
}

String? _cursor(Map<String, dynamic> data) {
  final cursor = data['next_cursor'];
  return cursor is String && cursor.trim().isNotEmpty ? cursor : null;
}

Map<String, dynamic> _dataMap(Object? body) {
  if (body is Map && body['data'] is Map) {
    return Map<String, dynamic>.from(body['data'] as Map);
  }
  return const {};
}