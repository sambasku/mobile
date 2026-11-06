import 'package:fpdart/fpdart.dart';

import '../entities/exploration_proposal.dart';
import '../failures/review_failure.dart';

abstract class ExplorationReviewRepository {
  Future<Either<ReviewFailure, List<ExplorationProposal>>> listPending(
    ExplorationReviewDomain domain,
  );

  Future<Either<ReviewFailure, Unit>> approve(
    ExplorationReviewDomain domain,
    String id,
  );

  Future<Either<ReviewFailure, Unit>> reject(
    ExplorationReviewDomain domain,
    String id, {
    required String reasonCode,
    String? reasonText,
  });

  Future<Either<ReviewFailure, Unit>> requestRevision(
    ExplorationReviewDomain domain,
    String id, {
    required String note,
  });
}
