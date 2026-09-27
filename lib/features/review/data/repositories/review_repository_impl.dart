import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/review_contribution.dart';
import '../../domain/failures/review_failure.dart';
import '../../domain/repositories/review_repository.dart';

const _base = '/api/v1/admin/contributions';

ReviewItem parseReviewItem(Map<String, dynamic> json) {
  return ReviewItem(
    id: json['id']?.toString() ?? '',
    contributorUsername: json['contributor_username']?.toString(),
    contributorDisplayName: json['contributor_display_name']?.toString(),
    entityType: json['entity_type']?.toString() ?? '',
    entityId: json['entity_id']?.toString() ?? '',
    action: json['action']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    createdAt: json['created_at']?.toString() ?? '',
    wordLemma: json['word_lemma']?.toString(),
  );
}

Map<String, dynamic> asStringKeyMap(Object? raw) {
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  return const {};
}

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Either<ReviewFailure, ReviewListPage>> list({
    String? status,
    String? entityType,
    String? wordId,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _base,
        queryParameters: {
          'limit': limit,
          'status': ?status,
          'entity_type': ?entityType,
          if (wordId != null && wordId.isNotEmpty) 'word_id': wordId,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final body = res.data ?? const <String, dynamic>{};
      final data = body['data'];
      final meta = body['meta'];
      final items = <ReviewItem>[];
      if (data is List) {
        for (final raw in data.whereType<Map>()) {
          items.add(parseReviewItem(asStringKeyMap(raw)));
        }
      }
      return Either.right(
        ReviewListPage(
          items: items,
          nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
          hasMore: meta is Map && meta['has_more'] == true,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal memuat antrean review'));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  @override
  Future<Either<ReviewFailure, ReviewDetail>> detail(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('$_base/$id');
      final data = asStringKeyMap(res.data?['data']);
      final contribution = parseReviewItem(asStringKeyMap(data['contribution']));
      final review = data['review'];
      return Either.right(
        ReviewDetail(
          contribution: contribution,
          entity: asStringKeyMap(data['entity']),
          reviewComment: review is Map ? review['comment']?.toString() : null,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal memuat detail usulan'));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> approve(
    String id, {
    String? comment,
  }) {
    return _decide(id, 'approve', {
      if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
  }

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> reject(
    String id, {
    required String comment,
  }) {
    return _decide(id, 'reject', {'comment': comment.trim()});
  }

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> correct(
    String id,
    Map<String, dynamic> body,
  ) {
    return _decide(id, 'correct', body);
  }

  Future<Either<ReviewFailure, ReviewDecisionResult>> _decide(
    String id,
    String action,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('$_base/$id/$action', data: body);
      final data = asStringKeyMap(res.data?['data']);
      return Either.right(
        ReviewDecisionResult(
          status: data['status']?.toString() ?? '',
          mergedIntoWordId: data['merged_into_word_id']?.toString(),
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal menyimpan keputusan'));
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
    if (error.response?.statusCode == 403) {
      return ReviewFailure(
        'Role tidak diizinkan mengakses endpoint ini',
        errorCode: 'FORBIDDEN',
      );
    }
    return ReviewFailure(fallback);
  }
}
