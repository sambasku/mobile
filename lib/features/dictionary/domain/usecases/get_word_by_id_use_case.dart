import 'package:fpdart/fpdart.dart';

import '../entities/word_detail.dart';
import '../failures/dictionary_failure.dart';
import '../repositories/dictionary_repository.dart';

class GetWordByIdUseCase {
  const GetWordByIdUseCase(this._repository);

  final DictionaryRepository _repository;

  Future<Either<DictionaryFailure, WordDetail>> call(
    String id, {
    bool forceRefresh = false,
    String? focusMeaningId,
    bool includeUnverified = false,
  }) =>
      _repository.getWordById(
        id,
        forceRefresh: forceRefresh,
        focusMeaningId: focusMeaningId,
        includeUnverified: includeUnverified,
      );
}
