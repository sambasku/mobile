import 'package:fpdart/fpdart.dart';

import '../entities/my_vote_page.dart';
import '../failures/my_vote_failure.dart';

abstract interface class MyVoteRepository {
  Future<Either<MyVoteFailure, MyVotePage>> listHistory({
    int limit = 20,
    String? cursor,
    String? targetType,
    String? communityStatus,
    String? q,
  });
}
