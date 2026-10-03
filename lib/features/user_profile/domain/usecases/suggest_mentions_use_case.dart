import 'package:fpdart/fpdart.dart';

import '../entities/public_profile.dart';
import '../failures/user_profile_failure.dart';
import '../repositories/user_profile_repository.dart';

/// Suggest username untuk autocomplete mention (38-api-mention.md).
class SuggestMentionsUseCase {
  const SuggestMentionsUseCase(this._repository);

  final UserProfileRepository _repository;

  Future<Either<UserProfileFailure, List<MentionSuggestion>>> call(
    String query,
  ) =>
      _repository.suggestMentions(query);
}
