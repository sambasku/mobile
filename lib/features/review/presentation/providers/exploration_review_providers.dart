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

/// List pending per domain (tanpa cursor - admin list penuh seperti console).
final explorationPendingListProvider = FutureProvider.autoDispose
    .family<List<ExplorationProposal>, ExplorationReviewDomain>((
  ref,
  domain,
) async {
  final auth = ref.watch(authStatusProvider).value;
  if (!canReviewQueue(auth?.role)) return const [];
  final result =
      await ref.watch(explorationReviewRepositoryProvider).listPending(domain);
  return result.match((failure) => throw failure, (items) => items);
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

/// Detail = item dari cache list (tidak ada GET-by-id admin).
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
}
