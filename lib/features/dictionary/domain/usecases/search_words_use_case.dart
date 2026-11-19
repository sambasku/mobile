import 'package:fpdart/fpdart.dart';

import '../entities/word_summary.dart';
import '../failures/dictionary_failure.dart';
import '../repositories/dictionary_repository.dart';

class SearchWordsUseCase {
  const SearchWordsUseCase(this._repository);

  final DictionaryRepository _repository;

  Future<Either<DictionaryFailure, WordSearchPage>> call(
    SearchWordsParams params,
  ) {
    return _repository.searchWords(
      query: params.query.trim(),
      limit: params.limit,
      cursor: params.cursor,
      searchIn: params.searchIn,
      recordMiss: params.recordMiss,
    );
  }
}

class SearchWordsParams {
  const SearchWordsParams({
    required this.query,
    this.limit = 20,
    this.cursor,
    this.searchIn = 'lemma',
    this.recordMiss = true,
  });

  final String query;
  final int limit;
  final String? cursor;
  final String searchIn;

  /// false = explore/typeahead; true = Enter / Cari / blur idle.
  final bool recordMiss;
}
