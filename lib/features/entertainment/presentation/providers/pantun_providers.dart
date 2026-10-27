import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../vote/domain/entities/vote_view.dart';
import '../../../vote/domain/providers/vote_domain_providers.dart';
import '../../data/pantun_api.dart';
import '../../domain/pantun_models.dart';

class PantunFeedState {
  const PantunFeedState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<Pantun> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
}

final pantunFeedProvider =
    AsyncNotifierProvider.autoDispose<PantunFeedController, PantunFeedState>(
      PantunFeedController.new,
    );

class PantunFeedController extends AsyncNotifier<PantunFeedState> {
  static const _pageSize = 20;

  @override
  Future<PantunFeedState> build() async {
    final page = await ref
        .watch(pantunApiProvider)
        .listPublished(limit: _pageSize);
    final items = await _attachMyVotes(page.items);
    return PantunFeedState(
      items: items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  /// Seed myVote per pantun (batch) saat login; gagal = bukan blocker
  /// (tombol tampil tanpa state aktif, toggle tetap jalan).
  Future<List<Pantun>> _attachMyVotes(List<Pantun> items) async {
    if (items.isEmpty) return items;

    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return items;

    final mine = await ref.watch(getMyVotesUseCaseProvider)(
      items.map((p) => p.voteTarget).toList(growable: false),
    );
    if (!ref.mounted) return items;
    return mine.match(
      (failure) => items,
      (map) => items
          .map(
            (p) => map.containsKey(p.voteTarget.key)
                ? p.copyWith(myVote: map[p.voteTarget.key])
                : p,
          )
          .toList(growable: false),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(pantunApiProvider)
          .listPublished(limit: _pageSize, cursor: current.nextCursor);
      if (!ref.mounted) return;
      state = AsyncData(
        PantunFeedState(
          items: [...current.items, ...await _attachMyVotes(page.items)],
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        ),
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(current.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// Toggle vote pantun di feed. Return pesan error (null = sukses).
  Future<String?> toggleVote(Pantun pantun, int value) async {
    final current = state.value;
    if (current == null) return 'Pantun belum dimuat';

    final result = await ref.watch(toggleVoteUseCaseProvider)(
      target: pantun.voteTarget,
      value: value,
    );
    if (!ref.mounted) return null;
    return result.match((failure) => failure.message, (view) {
      _applyVote(current, pantun.voteTarget.key, view);
      return null;
    });
  }

  void _applyVote(PantunFeedState current, String key, VoteView view) {
    state = AsyncData(
      current.copyWith(
        items: [
          for (final p in current.items)
            p.voteTarget.key == key
                ? p.copyWith(
                    upvotes: view.upvotes,
                    downvotes: view.downvotes,
                    myVote: view.myVote,
                  )
                : p,
        ],
      ),
    );
  }

  /// Hapus pantun milik sendiri dari feed. Return pesan error (null = sukses).
  Future<String?> deletePantun(Pantun pantun) async {
    final current = state.value;
    if (current == null) return 'Pantun belum dimuat';
    try {
      await ref.read(pantunApiProvider).deletePantun(pantun.id);
      if (!ref.mounted) return null;
      state = AsyncData(
        current.copyWith(
          items: current.items
              .where((p) => p.id != pantun.id)
              .toList(growable: false),
        ),
      );
      return null;
    } on PantunFailure catch (e) {
      return e.message;
    } catch (_) {
      return 'Gagal menghapus pantun. Coba lagi ya.';
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

extension on PantunFeedState {
  PantunFeedState copyWith({
    List<Pantun>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return PantunFeedState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final pantunDetailProvider = AsyncNotifierProvider.autoDispose
    .family<PantunDetailController, PantunDetail, String>(
      PantunDetailController.new,
    );

/// Hasil pencarian pantun (induk + balasan). autoDispose: query berganti
/// terus saat user mengetik, data lama langsung dibuang.
final pantunSearchProvider = FutureProvider.autoDispose
    .family<List<Pantun>, String>((ref, q) async {
      return ref.watch(pantunApiProvider).search(q);
    });

class PantunDetailController extends AsyncNotifier<PantunDetail> {
  PantunDetailController(this.id);

  final String id;

  @override
  Future<PantunDetail> build() async {
    final detail = await ref.watch(pantunApiProvider).getDetail(id);
    final pantun = await _attachMyVotes([detail.pantun]);
    final replies = await _attachMyVotes(detail.replies);
    return PantunDetail(pantun.first, replies);
  }

  Future<List<Pantun>> _attachMyVotes(List<Pantun> items) async {
    final published = items
        .where((p) => p.status == 'published')
        .toList(growable: false);
    if (published.isEmpty) return items;

    final auth = await ref.watch(authStatusProvider.future);
    if (!auth.isAuth) return items;

    final mine = await ref.watch(getMyVotesUseCaseProvider)(
      published.map((p) => p.voteTarget).toList(growable: false),
    );
    if (!ref.mounted) return items;
    return mine.match(
      (failure) => items,
      (map) => items
          .map(
            (p) => map.containsKey(p.voteTarget.key)
                ? p.copyWith(myVote: map[p.voteTarget.key])
                : p,
          )
          .toList(growable: false),
    );
  }

  /// Toggle vote pantun/balasan di halaman detail. Return pesan error.
  Future<String?> toggleVote(Pantun target, int value) async {
    final current = state.value;
    if (current == null) return 'Pantun belum dimuat';

    final result = await ref.watch(toggleVoteUseCaseProvider)(
      target: target.voteTarget,
      value: value,
    );
    if (!ref.mounted) return null;
    return result.match((failure) => failure.message, (view) {
      final key = target.voteTarget.key;
      state = AsyncData(
        PantunDetail(
          current.pantun.voteTarget.key == key
              ? _voted(current.pantun, view)
              : current.pantun,
          [
            for (final r in current.replies)
              r.voteTarget.key == key ? _voted(r, view) : r,
          ],
        ),
      );
      return null;
    });
  }

  Pantun _voted(Pantun p, VoteView view) => p.copyWith(
    upvotes: view.upvotes,
    downvotes: view.downvotes,
    myVote: view.myVote,
  );

  /// Hapus pantun pembuka milik sendiri. Return pesan error (null = sukses).
  Future<String?> deletePantun() async {
    final current = state.value;
    if (current == null) return 'Pantun belum dimuat';
    try {
      await ref.read(pantunApiProvider).deletePantun(current.pantun.id);
      return null;
    } on PantunFailure catch (e) {
      return e.message;
    } catch (_) {
      return 'Gagal menghapus pantun. Coba lagi ya.';
    }
  }
}
