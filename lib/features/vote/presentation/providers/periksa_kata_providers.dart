import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../my_votes/domain/entities/my_vote_item.dart';
import '../../../my_votes/domain/failures/my_vote_failure.dart';
import '../../../my_votes/domain/providers/my_vote_domain_providers.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../../domain/entities/vote_target.dart';
import '../../domain/failures/vote_failure.dart';
import '../../domain/providers/vote_domain_providers.dart';

part 'periksa_kata_providers.g.dart';

class PeriksaKataFeedState {
  const PeriksaKataFeedState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.q = '',
    this.sessionVotes = const {},
  });

  final List<VoteDeckItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String q;

  /// meaningId -> 1 | -1 untuk vote dalam sesi ini (kartu tetap).
  final Map<String, int> sessionVotes;

  int? sessionVoteOf(String meaningId) => sessionVotes[meaningId];

  PeriksaKataFeedState copyWith({
    List<VoteDeckItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    String? q,
    Map<String, int>? sessionVotes,
    bool clearCursor = false,
  }) {
    return PeriksaKataFeedState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      q: q ?? this.q,
      sessionVotes: sessionVotes ?? this.sessionVotes,
    );
  }
}

/// Feed Periksa Kata - terpisah dari [VoteDeckController].
@Riverpod(keepAlive: true)
class PeriksaKataFeedController extends _$PeriksaKataFeedController {
  static const _pageSize = 20;

  String _q = '';
  final Map<String, int> _sessionVotes = {};

  @override
  Future<PeriksaKataFeedState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      return PeriksaKataFeedState(q: _q, sessionVotes: Map.of(_sessionVotes));
    }

    final result = await ref.watch(getVoteCheckDeckUseCaseProvider)(
      limit: _pageSize,
      q: _q.isEmpty ? null : _q,
      randomize: false,
    );
    final page = result.match((failure) => throw failure, (page) => page);
    return PeriksaKataFeedState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
      q: _q,
      sessionVotes: Map.of(_sessionVotes),
    );
  }

  Future<void> refresh() async {
    _sessionVotes.clear();
    ref.invalidateSelf();
    await future;
  }

  void setQuery(String raw) {
    final next = raw.trim();
    if (next == _q) return;
    _q = next;
    _sessionVotes.clear();
    ref.invalidateSelf();
  }

  Future<VoteFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.read(getVoteCheckDeckUseCaseProvider)(
      limit: _pageSize,
      cursor: current.nextCursor,
      q: _q.isEmpty ? null : _q,
      randomize: false,
    );
    return result.match(
      (failure) {
        final latest = state.value ?? current;
        state = AsyncData(latest.copyWith(isLoadingMore: false));
        return failure;
      },
      (page) {
        final latest = state.value ?? current;
        final seen = {for (final i in latest.items) i.id};
        final merged = [
          ...latest.items,
          for (final item in page.items)
            if (!seen.contains(item.id)) item,
        ];
        state = AsyncData(
          latest.copyWith(
            isLoadingMore: false,
            items: merged,
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
            sessionVotes: Map.of(_sessionVotes),
          ),
        );
        return null;
      },
    );
  }

  /// Vote makna; kartu tetap + tombol mati sampai refresh.
  Future<VoteFailure?> vote({
    required VoteDeckItem item,
    required int value,
  }) async {
    if (_sessionVotes.containsKey(item.id)) return null;

    final result = await ref.read(toggleVoteUseCaseProvider)(
      target: VoteTarget(type: 'meaning', id: item.id),
      value: value,
    );
    return result.match(
      (failure) => failure,
      (view) {
        _sessionVotes[item.id] = value;
        final current = state.value;
        if (current == null) return null;
        final items = [
          for (final row in current.items)
            if (row.id == item.id)
              row.copyWith(upvotes: view.upvotes, downvotes: view.downvotes)
            else
              row,
        ];
        state = AsyncData(
          current.copyWith(
            items: items,
            sessionVotes: Map.of(_sessionVotes),
          ),
        );
        return null;
      },
    );
  }
}

class PeriksaKataHistoryState {
  const PeriksaKataHistoryState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.q = '',
    this.communityStatus,
  });

  final List<MyVoteItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String q;

  /// null = Semua; pending | verified | rejected.
  final String? communityStatus;

  PeriksaKataHistoryState copyWith({
    List<MyVoteItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    String? q,
    String? communityStatus,
    bool clearStatus = false,
    bool clearCursor = false,
  }) {
    return PeriksaKataHistoryState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      q: q ?? this.q,
      communityStatus:
          clearStatus ? null : (communityStatus ?? this.communityStatus),
    );
  }
}

@Riverpod(keepAlive: true)
class PeriksaKataHistoryController extends _$PeriksaKataHistoryController {
  static const _pageSize = 20;

  String _q = '';
  String? _communityStatus;

  @override
  Future<PeriksaKataHistoryState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      return PeriksaKataHistoryState(
        q: _q,
        communityStatus: _communityStatus,
      );
    }

    final result = await ref.watch(listMyVotesUseCaseProvider)(
      limit: _pageSize,
      targetType: 'meaning',
      communityStatus: _communityStatus,
      q: _q.isEmpty ? null : _q,
    );
    final page = result.match((failure) => throw failure, (page) => page);
    return PeriksaKataHistoryState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
      q: _q,
      communityStatus: _communityStatus,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  void setQuery(String raw) {
    final next = raw.trim();
    if (next == _q) return;
    _q = next;
    ref.invalidateSelf();
  }

  void setCommunityStatus(String? status) {
    if (status == _communityStatus) return;
    _communityStatus = status;
    ref.invalidateSelf();
  }

  Future<MyVoteFailure?> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return null;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final result = await ref.read(listMyVotesUseCaseProvider)(
      limit: _pageSize,
      cursor: current.nextCursor,
      targetType: 'meaning',
      communityStatus: _communityStatus,
      q: _q.isEmpty ? null : _q,
    );
    return result.match(
      (failure) {
        final latest = state.value ?? current;
        state = AsyncData(latest.copyWith(isLoadingMore: false));
        return failure;
      },
      (page) {
        final latest = state.value ?? current;
        state = AsyncData(
          latest.copyWith(
            isLoadingMore: false,
            items: [...latest.items, ...page.items],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
          ),
        );
        return null;
      },
    );
  }
}
