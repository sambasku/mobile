import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/word_suggestion_review.dart';
import '../../domain/failures/review_failure.dart';
import '../../domain/repositories/word_suggestion_review_repository.dart';
import 'review_repository_impl.dart';

const _base = '/api/v1/admin/word-suggestions';

WordSuggestionSummary _parseSummary(Map<String, dynamic> json) {
  final summary = asStringKeyMap(json['summary_changes']);
  return WordSuggestionSummary(
    id: json['id']?.toString() ?? '',
    wordId: json['word_id']?.toString() ?? '',
    wordLemma: json['word_lemma']?.toString() ?? '',
    contributorId: json['contributor_id']?.toString() ?? '',
    contributorUsername: json['contributor_username']?.toString(),
    contributorDisplayName: json['contributor_display_name']?.toString(),
    reason: json['reason']?.toString() ?? '',
    reasonCode: json['reason_code']?.toString() ?? 'other',
    status: json['status']?.toString() ?? '',
    createdAt: json['created_at']?.toString() ?? '',
    summaryLemma: summary['lemma']?.toString(),
    summaryNotes: summary['notes']?.toString(),
    meaningsCount: (summary['meanings_count'] as num?)?.toInt() ?? 0,
    imagesCount: (summary['images_count'] as num?)?.toInt() ?? 0,
  );
}

WordSuggestionFieldDiff _parseFieldDiff(Object? raw) {
  final map = asStringKeyMap(raw);
  return WordSuggestionFieldDiff(
    current: map['current']?.toString(),
    proposed: map['proposed']?.toString(),
    changed: map['changed'] == true,
  );
}

WordSuggestionDetail _parseDetail(Map<String, dynamic> data) {
  final suggestion = asStringKeyMap(data['suggestion']);
  final diff = asStringKeyMap(data['diff']);
  final categories = asStringKeyMap(diff['categories']);
  final relations = asStringKeyMap(diff['relations']);
  final variants = asStringKeyMap(diff['variants']);
  final images = asStringKeyMap(diff['images']);
  final meanings = diff['meanings'];
  final meaningsChanged = meanings is List
      ? meanings.whereType<Map>().length
      : 0;

  List countList(Object? raw, String key) {
    final map = asStringKeyMap(raw);
    final list = map[key];
    return list is List ? list : const [];
  }

  return WordSuggestionDetail(
    id: suggestion['id']?.toString() ?? '',
    wordId: suggestion['word_id']?.toString() ?? '',
    wordLemma: suggestion['word_lemma']?.toString() ?? '',
    contributorId: suggestion['contributor_id']?.toString() ?? '',
    contributorUsername: suggestion['contributor_username']?.toString(),
    contributorDisplayName: suggestion['contributor_display_name']?.toString(),
    reason: suggestion['reason']?.toString() ?? '',
    reasonCode: suggestion['reason_code']?.toString() ?? 'other',
    status: suggestion['status']?.toString() ?? '',
    createdAt: suggestion['created_at']?.toString() ?? '',
    lemmaDiff: _parseFieldDiff(diff['lemma']),
    notesDiff: _parseFieldDiff(diff['notes']),
    meaningsChanged: meaningsChanged,
    categoriesAdded: countList(categories, 'added').length,
    categoriesRemoved: countList(categories, 'removed').length,
    relationsAdded: countList(relations, 'added').length,
    relationsRemoved: countList(relations, 'removed').length,
    variantsAdded: countList(variants, 'added').length,
    variantsRemoved: countList(variants, 'removed').length,
    imagesAdded: countList(images, 'added').length,
    imagesRemoved: countList(images, 'removed').length,
  );
}

class WordSuggestionReviewRepositoryImpl
    implements WordSuggestionReviewRepository {
  WordSuggestionReviewRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Either<ReviewFailure, WordSuggestionListPage>> list({
    String? status,
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        _base,
        queryParameters: {
          'limit': limit,
          if (status != null && status.isNotEmpty) 'status': status,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final body = res.data ?? const <String, dynamic>{};
      final data = body['data'];
      final meta = body['meta'];
      final items = <WordSuggestionSummary>[];
      if (data is List) {
        for (final raw in data.whereType<Map>()) {
          items.add(_parseSummary(asStringKeyMap(raw)));
        }
      }
      return Either.right(
        WordSuggestionListPage(
          items: items,
          nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
          hasMore: meta is Map && meta['has_more'] == true,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal memuat antrean usulan edit'));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  @override
  Future<Either<ReviewFailure, WordSuggestionDetail>> detail(String id) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('$_base/$id');
      final data = asStringKeyMap(res.data?['data']);
      return Either.right(_parseDetail(data));
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal memuat detail usulan edit'));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  @override
  Future<Either<ReviewFailure, Unit>> approve(
    String id, {
    String? comment,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '$_base/$id/approve',
        data: {
          if (comment != null && comment.trim().isNotEmpty)
            'comment': comment.trim(),
        },
      );
      return Either.right(unit);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal menyetujui usulan'));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }

  @override
  Future<Either<ReviewFailure, Unit>> reject(
    String id, {
    required String comment,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '$_base/$id/reject',
        data: {'comment': comment.trim()},
      );
      return Either.right(unit);
    } on DioException catch (error) {
      return Either.left(_mapDio(error, 'Gagal menolak usulan'));
    } catch (error) {
      return Either.left(ReviewFailure(error.toString()));
    }
  }
}

ReviewFailure _mapDio(DioException error, String fallback) {
  final data = error.response?.data;
  if (data is Map) {
    final message = data['message']?.toString();
    final code = data['error_code']?.toString() ?? data['code']?.toString();
    if (message != null && message.isNotEmpty) {
      return ReviewFailure(message, errorCode: code);
    }
  }
  return ReviewFailure(fallback, errorCode: error.response?.statusCode?.toString());
}
