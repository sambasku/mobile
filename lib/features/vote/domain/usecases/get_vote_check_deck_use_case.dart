import 'package:fpdart/fpdart.dart';

import '../entities/vote_deck_item.dart';
import '../failures/vote_failure.dart';
import '../repositories/vote_repository.dart';

class GetVoteCheckDeckUseCase {
  const GetVoteCheckDeckUseCase(this._repository);

  final VoteRepository _repository;

  Future<Either<VoteFailure, VoteDeckPage>> call({
    int limit = 20,
    String? cursor,
    String? q,
    bool randomize = false,
  }) =>
      _repository.getCheckDeck(
        limit: limit,
        cursor: cursor,
        q: q,
        randomize: randomize,
      );
}
