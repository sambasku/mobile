import 'package:fpdart/fpdart.dart';

import '../entities/word_detail.dart';
import '../failures/dictionary_failure.dart';
import '../repositories/dictionary_repository.dart';

class GetWordByLemmaUseCase {
  const GetWordByLemmaUseCase(this._repository);

  final DictionaryRepository _repository;

  Future<Either<DictionaryFailure, WordDetail>> call(
    String lemma, {
    bool forceRefresh = false,
  }) =>
      _repository.getWordByLemma(lemma, forceRefresh: forceRefresh);
}
