import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../my_votes/domain/entities/my_vote_item.dart';
import '../../../my_votes/domain/failures/my_vote_failure.dart';
import '../../../my_votes/domain/providers/my_vote_domain_providers.dart';
import '../../data/providers/vote_data_providers.dart';
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
    this.priorVoteIds = const {},
  });

  final List<VoteDeckItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final String q;

  /// meaningId -> 1 | -1 untuk vote dalam sesi ini (kartu tetap).
  final Map<String, int> sessionVotes;

  /// Vote yang sudah ada sebelum sesi (cache antrean / vote lama ikut).
  final Set<String> priorVoteIds;

  int? sessionVoteOf(String meaningId) => sessionVotes[meaningId];

  bool isPriorVote(String meaningId) => priorVoteIds.contains(meaningId);

  PeriksaKataFeedState copyWith({
    List<VoteDeckItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    String? q,
    Map<String, int>? sessionVotes,
    Set<String>? priorVoteIds,
    bool clearCursor = false,
  }) {
    return PeriksaKataFeedState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      q: q ?? this.q,
      sessionVotes: sessionVotes ?? this.sessionVotes,
      priorVoteIds: priorVoteIds ?? this.priorVoteIds,
    );
  }
}

/// Feed Periksa Kata - terpisah dari [VoteDeckController].
@Riverpod(keepAlive: true)
class PeriksaKataFeedController extends _$PeriksaKataFeedController {
  static const _pageSize = 20;

  String _q = '';
  final Map<String, int> _sessionVotes = {};
  final Set<String> _priorVoteIds = {};

  @override
  Future<PeriksaKataFeedState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      return PeriksaKataFeedState(
        q: _q,
        sessionVotes: Map.of(_sessionVotes),
        priorVoteIds: Set.of(_priorVoteIds),
      );
    }

    final result = await ref.watch(getVoteCheckDeckUseCaseProvider)(
      limit: _pageSize,
      q: _q.isEmpty ? null : _q,
      randomize: false,
    );
    final page = result.match((failure) => throw failure, (page) => page);
    final items = await _withDeckLiveCounts(page.items);
    await _seedPriorVotes(items);
    return PeriksaKataFeedState(
      items: items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
      q: _q,
      sessionVotes: Map.of(_sessionVotes),
      priorVoteIds: Set.of(_priorVoteIds),
    );
  }

  Future<List<VoteDeckItem>> _withDeckLiveCounts(
    List<VoteDeckItem> items,
  ) async {
    if (items.isEmpty) return items;
    final targets = [
      for (final item in items) VoteTarget(type: 'meaning', id: item.id),
    ];
    final countsResult = await ref.read(getVoteCountsUseCaseProvider)(targets);
    return countsResult.match(
      (_) => items,
      (counts) => [
        for (final row in items)
          row.copyWith(
            upvotes: counts['meaning:${row.id}']?.upvotes ?? row.upvotes,
            downvotes: counts['meaning:${row.id}']?.downvotes ?? row.downvotes,
          ),
      ],
    );
  }

  /// Antrean seharusnya tanpa makna yang sudah divote. Kalau cache/race
  /// masih menyertakan vote lama, seed ke sessionVotes supaya UI aktif
  /// dan user bisa batal dengan tap tombol yang sama.
  Future<void> _seedPriorVotes(List<VoteDeckItem> items) async {
    if (items.isEmpty) return;
    final targets = [
      for (final item in items) VoteTarget(type: 'meaning', id: item.id),
    ];
    final mine = await ref.read(getMyVotesUseCaseProvider)(targets);
    mine.match((_) {}, (map) {
      for (final entry in map.entries) {
        final parts = entry.key.split(':');
        if (parts.length < 2 || parts.first != 'meaning') continue;
        final meaningId = parts.sublist(1).join(':');
        if (meaningId.isEmpty) continue;
        _sessionVotes.putIfAbsent(meaningId, () => entry.value);
        _priorVoteIds.add(meaningId);
      }
    });
  }

  Future<void> refresh() async {
    _sessionVotes.clear();
    _priorVoteIds.clear();
    ref.invalidateSelf();
    await future;
  }

  void setQuery(String raw) {
    final next = raw.trim();
    if (next == _q) return;
    _q = next;
    _sessionVotes.clear();
    _priorVoteIds.clear();
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
    if (result.isLeft()) {
      final failure = result.getLeft().toNullable()!;
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(isLoadingMore: false));
      return failure;
    }
    final page = result.getRight().toNullable()!;
    final pageItems = await _withDeckLiveCounts(page.items);
    await _seedPriorVotes(pageItems);
    final latest = state.value ?? current;
    final seen = {for (final i in latest.items) i.id};
    final merged = [
      ...latest.items,
      for (final item in pageItems)
        if (!seen.contains(item.id)) item,
    ];
    state = AsyncData(
      latest.copyWith(
        isLoadingMore: false,
        items: merged,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        sessionVotes: Map.of(_sessionVotes),
        priorVoteIds: Set.of(_priorVoteIds),
      ),
    );
    return null;
  }

  /// Vote makna (toggle): arah baru / ganti arah / tap ulang = batal.
  /// Kartu tetap di feed sampai refresh (filter personal API).
  Future<VoteFailure?> vote({
    required VoteDeckItem item,
    required int value,
  }) async {
    if (!ref.mounted) return null;

    final result = await ref.read(toggleVoteUseCaseProvider)(
      target: VoteTarget(type: 'meaning', id: item.id),
      value: value,
    );
    if (!ref.mounted) return null;
    return result.match(
      (failure) => failure,
      (view) {
        if (view.myVote == null) {
          _sessionVotes.remove(item.id);
          _priorVoteIds.remove(item.id);
        } else {
          _sessionVotes[item.id] = view.myVote!;
        }
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
            priorVoteIds: Set.of(_priorVoteIds),
          ),
        );
        return null;
      },
    );
  }

  /// Lewati tanpa vote - makna tidak muncul lagi di feed user ini (POST /votes/skips).
  Future<VoteFailure?> skip(VoteDeckItem item) async {
    if (!ref.mounted) return null;

    final result =
        await ref.read(voteRepositoryProvider).skipMeaning(item.id);
    if (!ref.mounted) return null;
    return result.match(
      (failure) => failure,
      (_) {
        final current = state.value;
        if (current == null) return null;
        state = AsyncData(
          current.copyWith(
            items: [
              for (final row in current.items)
                if (row.id != item.id) row,
            ],
            sessionVotes: Map.of(_sessionVotes),
            priorVoteIds: Set.of(_priorVoteIds),
          ),
        );
        return null;
      },
    );
  }

  /// Sinkron dari luar (mis. revisi di riwayat) ke sessionVotes + counts kartu.
  void syncExternalVote({
    required String meaningId,
    required int? myVote,
    int? upvotes,
    int? downvotes,
  }) {
    if (myVote == null) {
      _sessionVotes.remove(meaningId);
      _priorVoteIds.remove(meaningId);
    } else {
      _sessionVotes[meaningId] = myVote;
    }
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final row in current.items)
            if (row.id == meaningId)
              row.copyWith(
                upvotes: upvotes ?? row.upvotes,
                downvotes: downvotes ?? row.downvotes,
              )
            else
              row,
        ],
        sessionVotes: Map.of(_sessionVotes),
        priorVoteIds: Set.of(_priorVoteIds),
      ),
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
    final items = await _withLiveCounts(page.items);
    return PeriksaKataHistoryState(
      items: items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
      q: _q,
      communityStatus: _communityStatus,
    );
  }

  /// Total komunitas dari GET /votes/counts (staging history belum selalu
  /// mengirim upvotes/downvotes; counts publik = sumber akurat).
  Future<List<MyVoteItem>> _withLiveCounts(List<MyVoteItem> items) async {
    if (items.isEmpty) return items;
    final targets = [
      for (final row in items)
        VoteTarget(type: row.targetType, id: row.targetId),
    ];
    final countsResult = await ref.read(getVoteCountsUseCaseProvider)(targets);
    return countsResult.match(
      (_) => items,
      (counts) {
        return [
          for (final row in items)
            row.copyWith(
              upvotes:
                  counts['${row.targetType}:${row.targetId}']?.upvotes ??
                      row.upvotes,
              downvotes:
                  counts['${row.targetType}:${row.targetId}']?.downvotes ??
                      row.downvotes,
            ),
        ];
      },
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
    final failure = result.match((f) => f, (_) => null);
    if (failure != null) {
      final latest = state.value ?? current;
      state = AsyncData(latest.copyWith(isLoadingMore: false));
      return failure;
    }
    final page = result.match((f) => throw f, (p) => p);
    final enriched = await _withLiveCounts(page.items);
    if (!ref.mounted) return null;
    final latest = state.value ?? current;
    state = AsyncData(
      latest.copyWith(
        isLoadingMore: false,
        items: [...latest.items, ...enriched],
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ),
    );
    return null;
  }

  /// Revisi vote dari riwayat - toggle API; hanya pending.
  /// Batal (myVote null) → hapus dari daftar. Ganti arah → update value.
  Future<VoteFailure?> reviseVote({
    required MyVoteItem item,
    required int value,
  }) async {
    if (!ref.mounted) return null;
    if (!item.canReviseVote) return null;

    final result = await ref.read(toggleVoteUseCaseProvider)(
      target: VoteTarget(type: 'meaning', id: item.targetId),
      value: value,
    );
    if (!ref.mounted) return null;
    return result.match(
      (failure) => failure,
      (view) {
        final current = state.value;
        if (current == null) return null;

        final List<MyVoteItem> items;
        if (view.myVote == null) {
          items = [
            for (final row in current.items)
              if (row.id != item.id) row,
          ];
        } else {
          items = [
            for (final row in current.items)
              if (row.id == item.id)
                row.copyWith(
                  value: view.myVote!,
                  upvotes: view.upvotes,
                  downvotes: view.downvotes,
                )
              else
                row,
          ];
        }
        state = AsyncData(current.copyWith(items: items));

        ref
            .read(periksaKataFeedControllerProvider.notifier)
            .syncExternalVote(
              meaningId: item.targetId,
              myVote: view.myVote,
              upvotes: view.upvotes,
              downvotes: view.downvotes,
            );
        return null;
      },
    );
  }
}
