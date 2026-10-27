import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/entities/my_vote_item.dart';
import '../../domain/entities/my_vote_page.dart';
import '../../domain/failures/my_vote_failure.dart';
import '../../domain/repositories/my_vote_repository.dart';
import '../../../../core/i18n/l10n.dart';

MyVoteItem parseMyVoteItem(Map<String, dynamic> map) {
  final rawWord = map['word'];
  MyVoteWord? word;
  if (rawWord is Map) {
    final wordMap = Map<String, dynamic>.from(rawWord);
    word = MyVoteWord(
      id: wordMap['id']?.toString() ?? '',
      lemma: wordMap['lemma']?.toString() ?? '',
      wordType: wordMap['word_type']?.toString() ?? '',
      isVerified: wordMap['is_verified'] == true,
    );
  }
  return MyVoteItem(
    id: map['id']?.toString() ?? '',
    targetType: map['target_type']?.toString() ?? '',
    targetId: map['target_id']?.toString() ?? '',
    value: map['value'] is int ? map['value'] as int : int.tryParse('${map['value']}') ?? 0,
    votedAt: map['voted_at']?.toString() ?? '',
    word: word,
  );
}

class MyVoteRepositoryImpl implements MyVoteRepository {
  MyVoteRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<Either<MyVoteFailure, MyVotePage>> listHistory({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        '/api/v1/votes/history',
        queryParameters: {
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      final body = res.data ?? const <String, dynamic>{};
      final data = body['data'];
      final meta = body['meta'];
      final items = <MyVoteItem>[];
      if (data is List) {
        for (final raw in data.whereType<Map>()) {
          items.add(parseMyVoteItem(Map<String, dynamic>.from(raw)));
        }
      }
      return Either.right(
        MyVotePage(
          items: items,
          nextCursor: meta is Map ? meta['next_cursor']?.toString() : null,
          hasMore: meta is Map && meta['has_more'] == true,
        ),
      );
    } on DioException catch (error) {
      return Either.left(_mapDio(error));
    } catch (error) {
      return Either.left(MyVoteFailure(error.toString()));
    }
  }

  MyVoteFailure _mapDio(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      return MyVoteFailure(
        data['message']?.toString() ?? l10n.myVotesLoadFailed,
        errorCode: data['error_code']?.toString(),
      );
    }
    return MyVoteFailure(l10n.myVotesLoadFailed);
  }
}
