import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/repositories/meaning_report_review_repository_impl.dart';
import '../../domain/review_access.dart';

final meaningReportReviewRepositoryProvider =
    Provider<MeaningReportReviewRepository>(
  (ref) => MeaningReportReviewRepository(ref.watch(dioProvider)),
);

final meaningReportReviewHasPendingProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(authStatusProvider).value;
  if (!canReviewQueue(auth?.role)) return false;
  final page = await ref.watch(meaningReportReviewRepositoryProvider).list(
        limit: 1,
      );
  return page.items.isNotEmpty;
});

class MeaningReportReviewListState {
  const MeaningReportReviewListState({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<MeaningReportReviewItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  MeaningReportReviewListState copyWith({
    List<MeaningReportReviewItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MeaningReportReviewListState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class MeaningReportReviewListNotifier
    extends AsyncNotifier<MeaningReportReviewListState> {
  @override
  Future<MeaningReportReviewListState> build() async {
    final page = await ref.watch(meaningReportReviewRepositoryProvider).list();
    return MeaningReportReviewListState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    if (!ref.mounted) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref.read(meaningReportReviewRepositoryProvider).list(
            cursor: current.nextCursor,
          );
      if (!ref.mounted) return;
      state = AsyncData(
        MeaningReportReviewListState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        ),
      );
    } catch (error, stack) {
      if (!ref.mounted) return;
      state = AsyncError(error, stack);
    }
  }

  void drop(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: current.items.where((e) => e.id != id).toList(),
      ),
    );
  }
}

final meaningReportReviewListProvider =
    AsyncNotifierProvider<
      MeaningReportReviewListNotifier,
      MeaningReportReviewListState
    >(MeaningReportReviewListNotifier.new);

final meaningReportReviewDetailProvider =
    FutureProvider.family<MeaningReportReviewItem, String>((ref, id) async {
      return ref.watch(meaningReportReviewRepositoryProvider).getById(id);
    });

void invalidateMeaningReportReview(WidgetRef ref) {
  ref.invalidate(meaningReportReviewListProvider);
  ref.invalidate(meaningReportReviewHasPendingProvider);
}
