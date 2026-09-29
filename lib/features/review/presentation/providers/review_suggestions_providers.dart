import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/repositories/word_suggestion_review_repository_impl.dart';
import '../../domain/entities/word_suggestion_review.dart';
import '../../domain/repositories/word_suggestion_review_repository.dart';
import '../../domain/review_access.dart';
import 'discussion_review_providers.dart';
import 'review_providers.dart';

final wordSuggestionReviewRepositoryProvider =
    Provider<WordSuggestionReviewRepository>(
  (ref) => WordSuggestionReviewRepositoryImpl(ref.watch(dioProvider)),
);

/// Ada minimal satu usulan edit pending (admin word-suggestions).
final reviewSuggestionsHasPendingProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(authStatusProvider).value;
  if (!canReviewQueue(auth?.role)) return false;
  final page = await ref.watch(wordSuggestionReviewRepositoryProvider).list(
    status: 'pending',
    limit: 1,
  );
  return page.match((_) => false, (value) => value.items.isNotEmpty);
});

/// Titik oranye hub/profil: kontribusi, usulan edit, atau diskusi pending.
final reviewHubHasPendingProvider = FutureProvider<bool>((ref) async {
  final contrib = await ref.watch(reviewQueueHasPendingProvider.future);
  if (contrib) return true;
  final suggestions = await ref.watch(reviewSuggestionsHasPendingProvider.future);
  if (suggestions) return true;
  return ref.watch(discussionReviewHasPendingProvider.future);
});

class ReviewSuggestionsListState {
  const ReviewSuggestionsListState({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<WordSuggestionSummary> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  ReviewSuggestionsListState copyWith({
    List<WordSuggestionSummary>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return ReviewSuggestionsListState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final reviewSuggestionsListProvider = AsyncNotifierProvider.autoDispose<
    ReviewSuggestionsListController, ReviewSuggestionsListState>(
  ReviewSuggestionsListController.new,
);

class ReviewSuggestionsListController
    extends AsyncNotifier<ReviewSuggestionsListState> {
  static const _pageSize = 20;

  @override
  Future<ReviewSuggestionsListState> build() async {
    final page = await ref.watch(wordSuggestionReviewRepositoryProvider).list(
      status: 'pending',
      limit: _pageSize,
    );
    return page.match(
      (failure) => throw failure,
      (value) => ReviewSuggestionsListState(
        items: value.items,
        nextCursor: value.nextCursor,
        hasMore: value.hasMore,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final page = await ref.read(wordSuggestionReviewRepositoryProvider).list(
      status: 'pending',
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    page.match(
      (_) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (value) {
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...value.items],
            nextCursor: value.nextCursor,
            hasMore: value.hasMore,
            isLoadingMore: false,
            clearCursor: value.nextCursor == null,
          ),
        );
      },
    );
  }

  void drop(String id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: current.items.where((item) => item.id != id).toList(),
      ),
    );
  }
}

final reviewSuggestionDetailProvider = FutureProvider.autoDispose
    .family<WordSuggestionDetail, String>((ref, id) async {
  final result =
      await ref.watch(wordSuggestionReviewRepositoryProvider).detail(id);
  return result.match((failure) => throw failure, (detail) => detail);
});

void invalidateReviewSuggestions(WidgetRef ref) {
  ref.invalidate(reviewSuggestionsHasPendingProvider);
  ref.invalidate(reviewHubHasPendingProvider);
  ref.invalidate(reviewSuggestionsListProvider);
}
