import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/my_submission.dart';
import '../../domain/entities/my_submission_page.dart';
import '../../domain/failures/my_contribution_failure.dart';
import '../../domain/repositories/my_contribution_repository.dart';
import '../../../../core/i18n/l10n.dart';

MySubmission parseMySubmission(Map<String, dynamic> map) {
  return MySubmission(
    id: map['id']?.toString() ?? '',
    kind: map['kind']?.toString() ?? 'contribution',
    entityType: map['entity_type']?.toString() ?? 'word',
    lemma: map['lemma']?.toString(),
    status: map['status']?.toString() ?? 'pending',
    createdAt: map['created_at']?.toString() ?? '',
    reviewComment: map['review_comment']?.toString(),
    wordId: map['word_id']?.toString(),
    action: map['action']?.toString(),
    reason: map['reason']?.toString(),
    reasonCode: map['reason_code']?.toString(),
    reviewedAt: map['reviewed_at']?.toString(),
  );
}

class MyContributionRepositoryImpl implements MyContributionRepository {
  MyContributionRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Either<MyContributionFailure, MySubmissionPage>> listMine({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/contributions/my',
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final body = res.data ?? const <String, dynamic>{};
      final data = body['data'];
      final meta = body['meta'];
      final items = <MySubmission>[];
      if (data is List) {
        for (final raw in data.whereType<Map>()) {
          items.add(parseMySubmission(Map<String, dynamic>.from(raw)));
        }
      }
      return Either.right(
        MySubmissionPage(
          items: items,
          nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
          hasMore: meta is Map ? meta['has_more'] == true : false,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error, l10n.myContributionsLoadFailed));
    } catch (error) {
      return Either.left(MyContributionFailure(error.toString()));
    }
  }

  @override
  Future<Either<MyContributionFailure, MySubmission>> getMine({
    required String kind,
    required String id,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/contributions/my/$kind/$id',
      );
      final data = res.data?['data'];
      if (data is! Map) {
        return Either.left(MyContributionFailure(l10n.myContributionNotFound));
      }
      return Either.right(parseMySubmission(Map<String, dynamic>.from(data)));
    } on DioException catch (error) {
      return Either.left(_mapDio(error, l10n.myContributionDetailLoadFailed));
    } catch (error) {
      return Either.left(MyContributionFailure(error.toString()));
    }
  }

  MyContributionFailure _mapDio(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map) {
      return MyContributionFailure(
        data['message']?.toString() ?? fallback,
        errorCode: data['error_code']?.toString(),
      );
    }
    return MyContributionFailure(fallback);
  }
}
