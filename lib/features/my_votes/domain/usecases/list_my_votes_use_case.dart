import 'package:fpdart/fpdart.dart';

import '../entities/my_vote_page.dart';
import '../failures/my_vote_failure.dart';
import '../repositories/my_vote_repository.dart';

class ListMyVotesUseCase {
  const ListMyVotesUseCase(this._repo);

  final MyVoteRepository _repo;

  Future<Either<MyVoteFailure, MyVotePage>> call({
    int limit = 20,
    String? cursor,
    String? targetType,
    String? communityStatus,
    String? q,
  }) {
    return _repo.listHistory(
      limit: limit,
      cursor: cursor,
      targetType: targetType,
      communityStatus: communityStatus,
      q: q,
    );
  }
}
