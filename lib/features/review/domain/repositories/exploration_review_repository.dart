import 'package:fpdart/fpdart.dart';

import '../entities/exploration_proposal.dart';
import '../failures/review_failure.dart';

/// Filter list admin usulan eksplorasi (acara: periksa/riwayat + cari).
class ExplorationListQuery {
  const ExplorationListQuery({
    this.decided = false,
    this.q = '',
  });

  final bool decided;
  final String q;

  @override
  bool operator ==(Object other) =>
      other is ExplorationListQuery &&
      other.decided == decided &&
      other.q == q;

  @override
  int get hashCode => Object.hash(decided, q);
}

abstract class ExplorationReviewRepository {
  Future<Either<ReviewFailure, List<ExplorationProposal>>> listPending(
    ExplorationReviewDomain domain, {
    ExplorationListQuery query = const ExplorationListQuery(),
  });

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
