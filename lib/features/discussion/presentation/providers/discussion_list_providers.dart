import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../vote/domain/providers/vote_domain_providers.dart';
import '../../data/discussion_providers.dart';
import '../../domain/discussion_models.dart';

class DiscussionListState {
  const DiscussionListState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.status,
    this.sort = 'latest',
  });

  final List<DiscussionItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String? status;
  final String sort;

  DiscussionListState copyWith({
    List<DiscussionItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    String? status,
    String? sort,
    bool clearCursor = false,
  }) {
    return DiscussionListState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      status: status ?? this.status,
      sort: sort ?? this.sort,
    );
  }
}

final discussionFeedSortProvider =
    NotifierProvider.autoDispose<DiscussionFeedSort, String>(
      DiscussionFeedSort.new,
    );

class DiscussionFeedSort extends Notifier<String> {
  @override
  String build() => 'latest';

  void select(String sort) => state = sort;
}

final discussionFeedProvider =
    AsyncNotifierProvider.autoDispose<
      DiscussionFeedController,
      DiscussionListState
    >(DiscussionFeedController.new);

class DiscussionFeedController
    extends AsyncNotifier<DiscussionListState> {
  static const _pageSize = 20;

  @override
  Future<DiscussionListState> build() async {
    final sort = ref.watch(discussionFeedSortProvider);
    final page = await ref
        .watch(discussionRepositoryProvider)
        .listPublished(limit: _pageSize, sort: sort);
    final value = page.match((failure) => throw failure, (v) => v);
    final items = await _attachMyVotes(value.items);
    return DiscussionListState(
      items: items,
      nextCursor: value.nextCursor,
      hasMore: value.hasMore,
      sort: sort,
    );
  }

  Future<List<DiscussionItem>> _attachMyVotes(
    List<DiscussionItem> items,
  ) async {
    if (items.isEmpty) return items;
    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return items;

    final mine = await ref.watch(getMyVotesUseCaseProvider)(
      items.map((i) => i.voteTarget).toList(growable: false),
    );
    return mine.match(
      (failure) => items,
      (map) => items
          .map(
            (i) => map.containsKey(i.voteTarget.key)
                ? i.copyWith(myVote: map[i.voteTarget.key])
                : i,
          )
          .toList(growable: false),
    );
  }

  Future<DiscussionFailure?> toggleHelpVote(
    DiscussionItem item,
    int value,
  ) async {
    final current = state.value;
    if (current == null) {
      return const DiscussionFailure('Belum siap');
    }

    final result = await ref.watch(toggleVoteUseCaseProvider)(
      target: item.voteTarget,
      value: value,
    );
    return result.match(
      (failure) => DiscussionFailure(
        failure.message,
        errorCode: failure.errorCode,
      ),
      (view) {
        state = AsyncData(
          current.copyWith(
            items: [
              for (final i in current.items)
                i.id == item.id
                    ? i.copyWith(upvotes: view.upvotes, myVote: view.myVote)
                    : i,
            ],
          ),
        );
        return null;
      },
    );
  }

  Future<DiscussionFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final page = await ref
        .read(discussionRepositoryProvider)
        .listPublished(
          limit: _pageSize,
          cursor: current.nextCursor,
          sort: current.sort,
        );
    final failureOrNull = page.match(
      (failure) => failure,
      (_) => null,
    );
    if (failureOrNull != null) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
      return failureOrNull;
    }
    final value = page.match((_) => throw StateError('unreachable'), (v) => v);
    final more = await _attachMyVotes(value.items);
    state = AsyncData(
      current.copyWith(
        items: [...current.items, ...more],
        nextCursor: value.nextCursor,
        hasMore: value.hasMore,
        isLoadingMore: false,
      ),
    );
    return null;
  }
}

final myDiscussionsStatusFilterProvider =
    NotifierProvider.autoDispose<MyDiscussionsStatusFilter, String?>(
      MyDiscussionsStatusFilter.new,
    );

class MyDiscussionsStatusFilter extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? status) => state = status;
}

final myDiscussionsProvider =
    AsyncNotifierProvider.autoDispose<
      MyDiscussionsController,
      DiscussionListState
    >(MyDiscussionsController.new);

class MyDiscussionsController
    extends AsyncNotifier<DiscussionListState> {
  static const _pageSize = 20;

  @override
  Future<DiscussionListState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    final status = ref.watch(myDiscussionsStatusFilterProvider);
    if (!(auth?.isAuth ?? false)) {
      return DiscussionListState(status: status);
    }
    final page = await ref
        .watch(discussionRepositoryProvider)
        .listMine(limit: _pageSize, status: status);
    return page.match(
      (failure) => throw failure,
      (value) => DiscussionListState(
        items: value.items,
        nextCursor: value.nextCursor,
        hasMore: value.hasMore,
        status: status,
      ),
    );
  }

  Future<DiscussionFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    final page = await ref
        .read(discussionRepositoryProvider)
        .listMine(
          limit: _pageSize,
          cursor: current.nextCursor,
          status: current.status,
        );
    return page.match(
      (failure) {
        state = AsyncData(current.copyWith(isLoadingMore: false));
        return failure;
      },
      (value) {
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...value.items],
            nextCursor: value.nextCursor,
            hasMore: value.hasMore,
            isLoadingMore: false,
          ),
        );
        return null;
      },
    );
  }
}

class DiscussionDetailState {
  const DiscussionDetailState({
    required this.item,
    this.isSubmittingReply = false,
  });

  final DiscussionItem item;
  final bool isSubmittingReply;

  DiscussionDetailState copyWith({
    DiscussionItem? item,
    bool? isSubmittingReply,
  }) {
    return DiscussionDetailState(
      item: item ?? this.item,
      isSubmittingReply: isSubmittingReply ?? this.isSubmittingReply,
    );
  }
}

final discussionDetailProvider = AsyncNotifierProvider.autoDispose
    .family<DiscussionDetailController, DiscussionDetailState, String>(
      DiscussionDetailController.new,
    );

class DiscussionDetailController
    extends AsyncNotifier<DiscussionDetailState> {
  DiscussionDetailController(this.discussionId);

  final String discussionId;

  @override
  Future<DiscussionDetailState> build() async {
    final result = await ref
        .watch(discussionRepositoryProvider)
        .getDetail(discussionId);
    final item = result.match((failure) => throw failure, (item) => item);
    final withHelpVote = await _attachHelpMyVote(item);
    final replies = await _attachMyVotes(withHelpVote.replies);
    return DiscussionDetailState(
      item: withHelpVote.copyWith(replies: replies),
    );
  }

  Future<DiscussionItem> _attachHelpMyVote(DiscussionItem item) async {
    if (!item.isPublished) return item;

    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return item;

    final mine = await ref.watch(getMyVotesUseCaseProvider)([item.voteTarget]);
    return mine.match(
      (failure) => item,
      (map) => map.containsKey(item.voteTarget.key)
          ? item.copyWith(myVote: map[item.voteTarget.key])
          : item,
    );
  }

  /// Seed myVote per balasan (batch) saat login; gagal = bukan blocker.
  Future<List<DiscussionReply>> _attachMyVotes(
    List<DiscussionReply> items,
  ) async {
    if (items.isEmpty) return items;

    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return items;

    final published = items.where((r) => r.isPublished).toList(growable: false);
    if (published.isEmpty) return items;

    final mine = await ref.watch(getMyVotesUseCaseProvider)(
      published.map((r) => r.voteTarget).toList(growable: false),
    );
    return mine.match(
      (failure) => items,
      (map) => items
          .map(
            (r) => map.containsKey(r.voteTarget.key)
                ? r.copyWith(myVote: map[r.voteTarget.key])
                : r,
          )
          .toList(growable: false),
    );
  }

  Future<DiscussionFailure?> toggleHelpVote(int value) async {
    final current = state.value;
    if (current == null) {
      return const DiscussionFailure('Belum siap');
    }
    final item = current.item;
    if (!item.isPublished) {
      return const DiscussionFailure('Pertanyaan belum tayang');
    }

    final result = await ref.watch(toggleVoteUseCaseProvider)(
      target: item.voteTarget,
      value: value,
    );
    return result.match(
      (failure) => DiscussionFailure(
        failure.message,
        errorCode: failure.errorCode,
      ),
      (view) {
        state = AsyncData(
          current.copyWith(
            item: item.copyWith(
              upvotes: view.upvotes,
              myVote: view.myVote,
            ),
          ),
        );
        return null;
      },
    );
  }

  Future<DiscussionFailure?> toggleVote(
    DiscussionReply reply,
    int value,
  ) async {
    final current = state.value;
    if (current == null) {
      return const DiscussionFailure('Belum siap');
    }

    final result = await ref.watch(toggleVoteUseCaseProvider)(
      target: reply.voteTarget,
      value: value,
    );
    return result.match(
      (failure) => DiscussionFailure(
        failure.message,
        errorCode: failure.errorCode,
      ),
      (view) {
        final updated = reply.copyWith(
          upvotes: view.upvotes,
          downvotes: view.downvotes,
          myVote: view.myVote,
        );
        state = AsyncData(
          current.copyWith(
            item: current.item.copyWith(
              replies: [
                for (final r in current.item.replies)
                  r.id == updated.id ? updated : r,
              ],
            ),
          ),
        );
        return null;
      },
    );
  }

  Future<DiscussionFailure?> createReply(String body) async {
    final current = state.value;
    if (current == null) {
      return const DiscussionFailure('Belum siap');
    }
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return const DiscussionFailure('Balasan minimal 1 karakter');
    }
    state = AsyncData(current.copyWith(isSubmittingReply: true));
    final result = await ref
        .read(discussionRepositoryProvider)
        .createReply(discussionId: discussionId, body: trimmed);
    return result.match(
      (failure) {
        state = AsyncData(current.copyWith(isSubmittingReply: false));
        return failure;
      },
      (reply) {
        state = AsyncData(
          DiscussionDetailState(
            item: current.item.copyWith(
              replies: [...current.item.replies, reply],
            ),
          ),
        );
        return null;
      },
    );
  }

  Future<DiscussionFailure?> createReplyAudio({
    required File audioFile,
    required int durationMs,
    String? body,
  }) async {
    final current = state.value;
    if (current == null) {
      return const DiscussionFailure('Belum siap');
    }
    state = AsyncData(current.copyWith(isSubmittingReply: true));
    final result = await ref
        .read(discussionRepositoryProvider)
        .createReplyAudio(
          discussionId: discussionId,
          audioFile: audioFile,
          durationMs: durationMs,
          body: body,
        );
    return result.match(
      (failure) {
        state = AsyncData(current.copyWith(isSubmittingReply: false));
        return failure;
      },
      (reply) {
        state = AsyncData(
          DiscussionDetailState(
            item: current.item.copyWith(
              replies: [...current.item.replies, reply],
            ),
          ),
        );
        return null;
      },
    );
  }

  Future<DiscussionFailure?> deleteReply(DiscussionReply reply) async {
    final current = state.value;
    if (current == null) {
      return const DiscussionFailure('Belum siap');
    }
    final result = await ref
        .read(discussionRepositoryProvider)
        .deleteReply(reply.id);
    return result.match((failure) => failure, (_) {
      state = AsyncData(
        DiscussionDetailState(
          item: current.item.copyWith(
            replies: [
              for (final r in current.item.replies)
                if (r.id != reply.id) r,
            ],
          ),
        ),
      );
      return null;
    });
  }
}
