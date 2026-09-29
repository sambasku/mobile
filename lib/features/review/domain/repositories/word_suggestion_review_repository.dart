import 'package:fpdart/fpdart.dart';

import '../entities/word_suggestion_review.dart';
import '../failures/review_failure.dart';

abstract class WordSuggestionReviewRepository {
  Future<Either<ReviewFailure, WordSuggestionListPage>> list({
    String? status,
    int limit = 20,
    String? cursor,
  });

  Future<Either<ReviewFailure, WordSuggestionDetail>> detail(String id);

  Future<Either<ReviewFailure, Unit>> approve(String id, {String? comment});

  Future<Either<ReviewFailure, Unit>> reject(
    String id, {
    required String comment,
  });
}
