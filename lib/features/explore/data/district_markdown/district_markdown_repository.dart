import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/district_markdown_base_url.dart';

/// Sumber artikel markdown kecamatan dari CDN (repo data via jsDelivr).
///
/// File statis: cache lama aman. 404/timeout -> null (soft-fail, halaman
/// tetap tampil normal tanpa artikel).
class DistrictMarkdownRepository {
  DistrictMarkdownRepository({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              responseType: ResponseType.plain,
            ),
          );

  final Dio _dio;

  /// Ambil markdown artikel kecamatan. Null = tidak tersedia (404/offline).
  Future<String?> fetchBySlug(String slug) async {
    final url = '${DistrictMarkdownBaseUrl.district}$slug.md';
    try {
      final res = await _dio.get<String>(url);
      final body = res.data;
      if (res.statusCode == 200 && body != null && body.trim().isNotEmpty) {
        return body;
      }
      return null;
    } on DioException {
      return null;
    }
  }
}

/// Provider repo (dibuat terpisah agar mudah di-mock di test).
final districtMarkdownRepositoryProvider =
    Provider<DistrictMarkdownRepository>((ref) => DistrictMarkdownRepository());

/// Artikel markdown per slug (`AsyncValue` String?); null = tidak tersedia.
final districtMarkdownProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, slug) => ref
      .watch(districtMarkdownRepositoryProvider)
      .fetchBySlug(slug),
);
