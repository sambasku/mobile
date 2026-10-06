import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/review_search_miss.dart';
import '../../domain/failures/review_failure.dart';

const _base = '/api/v1/admin/search-misses';

ReviewSearchMiss _parse(Map<String, dynamic> json) {
  return ReviewSearchMiss(
    id: json['id']?.toString() ?? '',
    term: json['term']?.toString() ?? '',
    searchIn: json['direction']?.toString() ?? 'lemma',
    hitCount: int.tryParse(json['hit_count']?.toString() ?? '') ?? 0,
    isVisible: json['is_visible'] == true,
    isFulfilled: json['is_fulfilled'] == true,
  );
}

/// Repo panel pencarian kosong verifikator (#88).
/// List admin (semua miss) + toggle tayang ke beranda publik.
class ReviewSearchMissRepositoryImpl {
  ReviewSearchMissRepositoryImpl(this._dio);

  final Dio _dio;

  /// `fulfilled=false` = default panel: miss yang belum jadi kata.
  Future<Either<ReviewFailure,ReviewSearchMissPageData>> list({
    bool? fulfilled,
    bool? visible,
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _base,
        queryParameters: {
          'limit': limit,
          'fulfilled': ?fulfilled,
          'visible': ?visible,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final body = res.data ?? const <String, dynamic>{};
      final data = body['data'];
      final meta = body['meta'];
      return Either.right(
        ReviewSearchMissPageData(
          items: [
            if (data is List)
              for (final raw in data)
                if (raw is Map)
                  _parse(Map<String, dynamic>.from(raw)),
          ],
          nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
          hasMore: meta is Map && meta['has_more'] == true,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal memuat pencarian kosong'));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  /// Toggle tayang beranda publik. API emit event feed search_miss
  /// show/hide otomatis — tidak ada kerjaan feed tambahan di sisi mobile.
  Future<Either<ReviewFailure, Unit>> setVisible(String id, bool visible) async {
    try {
      await _dio.patch<Map<String, dynamic>>(
        '$_base/$id',
        data: {'is_visible': visible},
      );
      return Either.right(unit);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal mengubah tayang'));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  ReviewFailure _mapDio(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map) {
      return ReviewFailure(
        data['message']?.toString() ?? fallback,
        errorCode: data['error_code']?.toString(),
      );
    }
    return ReviewFailure(fallback);
  }
}
