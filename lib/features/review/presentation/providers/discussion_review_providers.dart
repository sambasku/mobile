import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../discussion/data/discussion_providers.dart';
import '../../../discussion/domain/discussion_models.dart';
import '../../domain/review_access.dart';

/// Ada minimal satu diskusi pending_review.
final discussionReviewHasPendingProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(authStatusProvider).value;
  if (!canModerateDiscussions(auth?.role)) return false;
  final page = await ref.watch(discussionRepositoryProvider).listAdmin(
    status: 'pending_review',
    limit: 1,
  );
  return page.match((_) => false, (value) => value.items.isNotEmpty);
});

class DiscussionReviewListState {
  const DiscussionReviewListState({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<DiscussionItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  DiscussionReviewListState copyWith({
    List<DiscussionItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return DiscussionReviewListState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final discussionReviewListProvider = AsyncNotifierProvider.autoDispose<
    DiscussionReviewListController, DiscussionReviewListState>(
  DiscussionReviewListController.new,
);

class DiscussionReviewListController
    extends AsyncNotifier<DiscussionReviewListState> {
  static const _pageSize = 20;

  @override
  Future<DiscussionReviewListState> build() async {
    final page = await ref.watch(discussionRepositoryProvider).listAdmin(
      status: 'pending_review',
      limit: _pageSize,
    );
    return page.match(
      (failure) => throw failure,
      (value) => DiscussionReviewListState(
        items: value.items,
        nextCursor: value.nextCursor,
        hasMore: value.hasMore,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final page = await ref.read(discussionRepositoryProvider).listAdmin(
      status: 'pending_review',
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    page.match(
      (failure) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      },
      (value) {
        state = AsyncData(
          DiscussionReviewListState(
            items: [...current.items, ...value.items],
            nextCursor: value.nextCursor,
            hasMore: value.hasMore,
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
        items: current.items.where((e) => e.id != id).toList(),
      ),
    );
  }
}

final discussionReviewDetailProvider = FutureProvider.autoDispose
    .family<DiscussionItem, String>((ref, id) async {
  final result =
      await ref.watch(discussionRepositoryProvider).getAdminDetail(id);
  return result.match((failure) => throw failure, (item) => item);
});

void invalidateDiscussionReview(WidgetRef ref) {
  ref.invalidate(discussionReviewListProvider);
  ref.invalidate(discussionReviewHasPendingProvider);
}
