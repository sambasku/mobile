import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/my_comment_item.dart';
import '../../domain/entities/my_comment_page.dart';
import '../../domain/failures/my_comment_failure.dart';
import '../../domain/repositories/my_comment_repository.dart';
import '../../../../core/i18n/l10n.dart';

MyCommentItem parseMyCommentItem(Map<String, dynamic> map) {
  final lemma = map['word_lemma']?.toString();
  return MyCommentItem(
    id: map['id']?.toString() ?? '',
    wordId: map['word_id']?.toString() ?? '',
    wordLemma: lemma == null || lemma.isEmpty ? null : lemma,
    body: map['body']?.toString() ?? '',
    status: map['status']?.toString() ?? '',
    createdAt: map['created_at']?.toString() ?? '',
    reviewedAt: map['reviewed_at']?.toString(),
  );
}

class MyCommentRepositoryImpl implements MyCommentRepository {
  MyCommentRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Either<MyCommentFailure, MyCommentPage>> listMine({
    int limit = 20,
    String? cursor,
    String? status,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/comments/my',
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      final body = res.data ?? const <String, dynamic>{};
      final data = body['data'];
      final meta = body['meta'];
      final items = <MyCommentItem>[];
      if (data is List) {
        for (final raw in data.whereType<Map>()) {
          items.add(parseMyCommentItem(Map<String, dynamic>.from(raw)));
        }
      }
      return Either.right(
        MyCommentPage(
          items: items,
          nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
          hasMore: meta is Map && meta['has_more'] == true,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(MyCommentFailure(error.toString()));
    }
  }

  MyCommentFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      return MyCommentFailure(
        data['message']?.toString() ?? l10n.myCommentsLoadFailed,
        errorCode: data['error_code']?.toString(),
      );
    }
    return MyCommentFailure(l10n.myCommentsLoadFailed);
  }
}
