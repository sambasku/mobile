import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/place_markdown_base_url.dart';

/// Sumber artikel markdown wisata dari CDN (repo `data` via jsDelivr).
///
/// File statis: cache lama aman. 404/timeout -> null (soft-fail, CTA tidak
/// pernah muncul).
class PlaceMarkdownRepository {
  PlaceMarkdownRepository({Dio? dio})
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

  /// Ambil markdown artikel wisata. Null = tidak tersedia (404/offline).
  Future<String?> fetchBySlug(String slug) async {
    final url = '${PlaceMarkdownBaseUrl.places}$slug.md';
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

/// Provider repo (terpisah agar mudah di-mock di test).
final placeMarkdownRepositoryProvider =
    Provider<PlaceMarkdownRepository>((ref) => PlaceMarkdownRepository());

/// Artikel markdown per slug: AsyncValue String nullable, null = tidak tersedia.
final placeMarkdownProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, slug) => ref
      .watch(placeMarkdownRepositoryProvider)
      .fetchBySlug(slug),
);