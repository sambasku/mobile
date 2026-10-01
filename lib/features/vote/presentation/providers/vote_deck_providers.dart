import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/domain/entities/word_summary.dart';
import '../../../dictionary/domain/providers/dictionary_domain_providers.dart';
import '../../../dictionary/domain/usecases/list_latest_words_use_case.dart';
import '../../../my_votes/presentation/providers/my_votes_providers.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../../domain/entities/vote_target.dart';
import '../../domain/failures/vote_failure.dart';
import '../../domain/providers/vote_domain_providers.dart';
import 'vote_providers.dart';
import 'vote_submit_queue.dart';

part 'vote_deck_providers.g.dart';

/// Jenis aksi terakhir yang bisa di-rewind (satu langkah).
enum VoteDeckRewindKind { skip, upvote, downvote }

class VoteDeckRewindEntry {
  const VoteDeckRewindEntry({
    required this.item,
    required this.kind,
  });

  final VoteDeckItem item;
  final VoteDeckRewindKind kind;

  /// Nilai toggle untuk undo vote; null jika skip.
  int? get voteValue => switch (kind) {
        VoteDeckRewindKind.upvote => 1,
        VoteDeckRewindKind.downvote => -1,
        VoteDeckRewindKind.skip => null,
      };
}

class VoteDeckState {
  const VoteDeckState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.rewindEntry,
  });

  final List<VoteDeckItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final VoteDeckRewindEntry? rewindEntry;

  bool get canRewind => rewindEntry != null;

  VoteDeckState copyWith({
    List<VoteDeckItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    VoteDeckRewindEntry? rewindEntry,
    bool clearCursor = false,
    bool clearRewind = false,
  }) {
    return VoteDeckState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      rewindEntry: clearRewind ? null : (rewindEntry ?? this.rewindEntry),
    );
  }
}

/// Antrean deck nilai kata (login). keepAlive + watch auth.
@Riverpod(keepAlive: true)
class VoteDeckController extends _$VoteDeckController {
  static const _pageSize = 10;

  /// ID yang baru diskip di instance ini, termasuk sebelum POST selesai.
  final Set<String> _locallySkipped = {};

  @override
  Future<VoteDeckState> build() async {
    final auth = ref.watch(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) return const VoteDeckState();

    final result = await ref.watch(getVoteDeckUseCaseProvider)(limit: _pageSize);
    final page = result.match((failure) => throw failure, (page) => page);
    return VoteDeckState(
      items: [
        for (final item in page.items)
          if (!_locallySkipped.contains(item.id)) item,
      ],
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
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
    final result = await ref.watch(getVoteDeckUseCaseProvider)(
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    return result.match(
      (failure) {
        final latest = state.value ?? current;
        state = AsyncData(latest.copyWith(isLoadingMore: false));
        return failure;
      },
      (page) {
        final latest = state.value ?? current;
        final seen = latest.items.map((item) => item.id).toSet();
        state = AsyncData(
          VoteDeckState(
            isLoadingMore: false,
            items: [
              ...latest.items,
              for (final item in page.items)
                if (!seen.contains(item.id) && !_locallySkipped.contains(item.id))
                  item,
            ],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
            rewindEntry: latest.rewindEntry,
          ),
        );
        return null;
      },
    );
  }

  /// Optimistic: buang kartu lokal + enqueue submit background.
  void castOptimistic({
    required VoteDeckItem item,
    required int value,
  }) {
    _dropLocal(
      item.id,
      rewind: VoteDeckRewindEntry(
        item: item,
        kind: value == 1
            ? VoteDeckRewindKind.upvote
            : VoteDeckRewindKind.downvote,
      ),
    );
    ref.read(voteSubmitQueueProvider.notifier).enqueue(
          item: item,
          value: value,
        );
  }

  /// Lewati tanpa vote. Kartu tidak kembali untuk user ini.
  void skipAndAdvance(VoteDeckItem item) {
    AnalyticsService.instance.log(
      AnalyticsEvents.voteDeckSwipe,
      params: {'direction': 'skip', 'word_id': item.id},
    );
    _locallySkipped.add(item.id);
    _dropLocal(
      item.id,
      rewind: VoteDeckRewindEntry(
        item: item,
        kind: VoteDeckRewindKind.skip,
      ),
    );
    ref.read(voteSubmitQueueProvider.notifier).enqueueSkip(item: item);
  }

  /// Buka detail dari kartu. Vote di detail = kartu dianggap sudah dinilai
  /// (dibuang + bisa di-undo). Return true kalau kartu dibuang.
  ///
  /// Di controller (keepAlive), bukan widget: detail = route root, selama
  /// terbuka widget deck diganti stub dan ikut dispose.
  Future<bool> openDetail(
    VoteDeckItem item,
    Future<Object?> Function() push,
  ) async {
    final target = VoteTarget(type: 'word', id: item.id);
    // VoteController autoDispose: tahan hidup supaya myVote terbaca setelah pop.
    final sub = ref.listen(voteControllerProvider(target), (_, _) {});
    try {
      await push();
      final my = sub.read().value?.myVote;
      if (my == null) return false;
      _dropLocal(
        item.id,
        rewind: VoteDeckRewindEntry(
          item: item,
          kind: my == 1
              ? VoteDeckRewindKind.upvote
              : VoteDeckRewindKind.downvote,
        ),
      );
      return true;
    } finally {
      sub.close();
    }
  }

  /// Kembalikan kartu gagal submit ke depan antrean.
  void reinsertFront(VoteDeckItem item) {
    final current = state.value;
    if (current == null) return;
    _locallySkipped.remove(item.id);
    final withoutDup =
        current.items.where((i) => i.id != item.id).toList();
    final clearRewind = current.rewindEntry?.item.id == item.id;
    state = AsyncData(
      current.copyWith(
        items: [item, ...withoutDup],
        clearRewind: clearRewind,
      ),
    );
  }

  /// Kembalikan kartu terakhir (skip lokal, cancel queue, atau toggle-off).
  Future<VoteFailure?> rewind() async {
    final current = state.value;
    final entry = current?.rewindEntry;
    if (current == null || entry == null) return null;

    final value = entry.voteValue;
    if (entry.kind == VoteDeckRewindKind.skip) {
      _locallySkipped.remove(entry.item.id);
      final failure = await ref
          .read(voteSubmitQueueProvider.notifier)
          .undoSkip(entry.item.id);
      if (failure != null) {
        _locallySkipped.add(entry.item.id);
        return failure;
      }
    } else if (value != null) {
      final queue = ref.read(voteSubmitQueueProvider.notifier);
      final cancelled = queue.cancelQueued(entry.item.id);
      if (!cancelled) {
        // Sudah in-flight atau selesai → tunggu settle lalu undo di server.
        await queue.waitUntilNotInFlight(entry.item.id);
        final target = VoteTarget(type: 'word', id: entry.item.id);
        final result = await ref.watch(toggleVoteUseCaseProvider)(
          target: target,
          value: value,
        );
        final failure = result.match((f) => f, (_) => null);
        if (failure != null) return failure;
        ref.invalidate(myVotesListControllerProvider);
        ref.invalidate(voteControllerProvider(target));
      }
    }

    final withoutDup =
        current.items.where((i) => i.id != entry.item.id).toList();
    state = AsyncData(
      current.copyWith(
        items: [entry.item, ...withoutDup],
        clearRewind: true,
      ),
    );
    return null;
  }

  void _dropLocal(String wordId, {VoteDeckRewindEntry? rewind}) {
    final current = state.value;
    if (current == null) return;
    final remaining = current.items.where((i) => i.id != wordId).toList();
    state = AsyncData(
      current.copyWith(items: remaining, rewindEntry: rewind),
    );
    if (remaining.length <= 2 && current.hasMore) {
      loadMore();
    }
  }
}

/// Sample kartu untuk tamu (read-only) dari GET /words/latest.
@riverpod
Future<List<WordSummary>> voteDeckGuestSamples(Ref ref) async {
  final result = await ref.watch(listLatestWordsUseCaseProvider)(
    const ListLatestWordsParams(limit: 2),
  );
  return result.match(
    (_) => <WordSummary>[],
    (page) => page.items.take(2).toList(),
  );
}
