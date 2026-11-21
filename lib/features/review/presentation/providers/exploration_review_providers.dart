import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/repositories/exploration_review_repository_impl.dart';
import '../../domain/entities/exploration_proposal.dart';
import '../../domain/repositories/exploration_review_repository.dart';
import '../../domain/review_access.dart';

final explorationReviewRepositoryProvider =
    Provider<ExplorationReviewRepository>(
  (ref) => ExplorationReviewRepositoryImpl(ref.watch(dioProvider)),
);

/// Argumen list usulan (domain + filter periksa/riwayat + q).
class ExplorationListArgs {
  const ExplorationListArgs({
    required this.domain,
    this.decided = false,
    this.q = '',
  });

  final ExplorationReviewDomain domain;
  final bool decided;
  final String q;

  @override
  bool operator ==(Object other) =>
      other is ExplorationListArgs &&
      other.domain == domain &&
      other.decided == decided &&
      other.q == q;

  @override
  int get hashCode => Object.hash(domain, decided, q);
}

/// List admin per domain (+ filter acara).
final explorationListProvider = FutureProvider.autoDispose
    .family<List<ExplorationProposal>, ExplorationListArgs>((ref, args) async {
  final auth = ref.watch(authStatusProvider).value;
  if (!canReviewQueue(auth?.role)) return const [];
  final result = await ref.watch(explorationReviewRepositoryProvider).listPending(
        args.domain,
        query: ExplorationListQuery(decided: args.decided, q: args.q),
      );
  return result.match((failure) => throw failure, (items) => items);
});

/// List pending default (hub badge + domain non-acara).
final explorationPendingListProvider = FutureProvider.autoDispose
    .family<List<ExplorationProposal>, ExplorationReviewDomain>((
  ref,
  domain,
) async {
  return ref.watch(
    explorationListProvider(
      ExplorationListArgs(domain: domain),
    ).future,
  );
});

final explorationHasPendingProvider =
    FutureProvider.autoDispose.family<bool, ExplorationReviewDomain>((
  ref,
  domain,
) async {
  final auth = ref.watch(authStatusProvider).value;
  if (!canReviewQueue(auth?.role)) return false;
  final items = await ref.watch(explorationPendingListProvider(domain).future);
  return items.isNotEmpty;
});

/// Detail = item dari cache list pending (tidak ada GET-by-id admin).
final explorationDetailProvider = FutureProvider.autoDispose
    .family<ExplorationProposal, (ExplorationReviewDomain, String)>((
  ref,
  args,
) async {
  final (domain, id) = args;
  final items = await ref.watch(explorationPendingListProvider(domain).future);
  final match = items.where((item) => item.id == id);
  if (match.isEmpty) {
    throw StateError('proposal_not_found');
  }
  return match.first;
});

void invalidateExplorationReview(
  WidgetRef ref,
  ExplorationReviewDomain domain,
) {
  ref.invalidate(explorationPendingListProvider(domain));
  ref.invalidate(explorationHasPendingProvider(domain));
  // Invalidate semua varian filter list (periksa/riwayat + q).
  ref.invalidate(explorationListProvider);
}
