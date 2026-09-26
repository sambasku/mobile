import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/repositories/review_repository_impl.dart';
import '../../domain/entities/review_contribution.dart';
import '../../domain/repositories/review_repository.dart';
import '../../domain/review_access.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepositoryImpl(ref.watch(dioProvider)),
);

/// Titik oranye: ada minimal satu usulan menunggu. Gagal jaringan = tidak ada titik.
final reviewQueueHasPendingProvider = FutureProvider<bool>((ref) async {
  final auth = ref.watch(authStatusProvider).value;
  if (!canReviewQueue(auth?.role)) return false;
  final page = await ref.watch(reviewRepositoryProvider).list(
    status: 'pending',
    limit: 1,
  );
  return page.match((_) => false, (value) => value.items.isNotEmpty);
});

class ReviewQueueQuery {
  const ReviewQueueQuery({this.entityType, this.wordId});

  final String? entityType;
  final String? wordId;

  @override
  bool operator ==(Object other) =>
      other is ReviewQueueQuery &&
      other.entityType == entityType &&
      other.wordId == wordId;

  @override
  int get hashCode => Object.hash(entityType, wordId);
}

class ReviewQueueState {
  const ReviewQueueState({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<ReviewItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  ReviewQueueState copyWith({
    List<ReviewItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return ReviewQueueState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final reviewQueueProvider = AsyncNotifierProvider.autoDispose
    .family<ReviewQueueController, ReviewQueueState, ReviewQueueQuery>(
      ReviewQueueController.new,
    );

class ReviewQueueController extends AsyncNotifier<ReviewQueueState> {
  ReviewQueueController(this.query);

  final ReviewQueueQuery query;
  static const _pageSize = 20;

  @override
  Future<ReviewQueueState> build() async {
    final page = await ref.watch(reviewRepositoryProvider).list(
      status: 'pending',
      entityType: query.entityType,
      wordId: query.wordId,
      limit: _pageSize,
    );
    return page.match(
      (failure) => throw failure,
      (value) => ReviewQueueState(
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
    final page = await ref.read(reviewRepositoryProvider).list(
      status: 'pending',
      entityType: query.entityType,
      wordId: query.wordId,
      limit: _pageSize,
      cursor: current.nextCursor,
    );
    page.match(
      (failure) {
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

final reviewDetailProvider = FutureProvider.autoDispose.family<ReviewDetail, String>((
  ref,
  id,
) async {
  final result = await ref.watch(reviewRepositoryProvider).detail(id);
  return result.match((failure) => throw failure, (detail) => detail);
});

/// State sesi tinjau satu layar: urutan ID pending + index aktif.
class ReviewSessionState {
  const ReviewSessionState({
    required this.ids,
    required this.index,
    this.query = const ReviewQueueQuery(),
    this.hasMore = false,
    this.nextCursor,
    this.rewindSkipId,
  });

  final List<String> ids;
  final int index;
  final ReviewQueueQuery query;
  final bool hasMore;
  final String? nextCursor;

  /// ID item yang baru di-lewati (satu langkah rewind). Null = tidak bisa rewind.
  final String? rewindSkipId;

  String? get currentId {
    if (ids.isEmpty || index < 0 || index >= ids.length) return null;
    return ids[index];
  }

  String? get nextId {
    final next = index + 1;
    if (next < 0 || next >= ids.length) return null;
    return ids[next];
  }

  /// Posisi 1-based untuk UI progress ("3 dari 24").
  int get position => ids.isEmpty ? 0 : index + 1;

  int get total => ids.length;

  bool get isExhausted => currentId == null;

  bool get canRewind => rewindSkipId != null;

  ReviewSessionState copyWith({
    List<String>? ids,
    int? index,
    ReviewQueueQuery? query,
    bool? hasMore,
    String? nextCursor,
    String? rewindSkipId,
    bool clearCursor = false,
    bool clearRewind = false,
  }) {
    return ReviewSessionState(
      ids: ids ?? this.ids,
      index: index ?? this.index,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      rewindSkipId:
          clearRewind ? null : (rewindSkipId ?? this.rewindSkipId),
    );
  }
}

final reviewSessionProvider =
    NotifierProvider<ReviewSessionController, ReviewSessionState?>(
      ReviewSessionController.new,
    );

class ReviewSessionController extends Notifier<ReviewSessionState?> {
  static const _pageSize = 20;

  @override
  ReviewSessionState? build() => null;

  void start({
    required List<String> ids,
    int index = 0,
    ReviewQueueQuery query = const ReviewQueueQuery(),
    bool hasMore = false,
    String? nextCursor,
  }) {
    if (ids.isEmpty) {
      state = null;
      return;
    }
    final safeIndex = index.clamp(0, ids.length - 1);
    state = ReviewSessionState(
      ids: List<String>.of(ids),
      index: safeIndex,
      query: query,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
    _prefetchAround();
  }

  /// Mulai sesi dari isi antrean yang sudah dimuat; [startId] opsional.
  void startFromQueue(
    ReviewQueueState queue, {
    required ReviewQueueQuery query,
    String? startId,
  }) {
    final ids = queue.items.map((item) => item.id).toList(growable: false);
    if (ids.isEmpty) {
      state = null;
      return;
    }
    var index = 0;
    if (startId != null) {
      final found = ids.indexOf(startId);
      index = found >= 0 ? found : 0;
    }
    start(
      ids: ids,
      index: index,
      query: query,
      hasMore: queue.hasMore,
      nextCursor: queue.nextCursor,
    );
  }

  /// Deep link / satu ID saja: sesi dengan item tunggal, lalu coba isi dari antrean.
  Future<void> startWithId(
    String id, {
    ReviewQueueQuery query = const ReviewQueueQuery(),
  }) async {
    start(ids: [id], index: 0, query: query);
    final queue = ref.read(reviewQueueProvider(query)).value;
    if (queue != null && queue.items.isNotEmpty) {
      startFromQueue(queue, query: query, startId: id);
      return;
    }
    try {
      final page = await ref.read(reviewRepositoryProvider).list(
        status: 'pending',
        entityType: query.entityType,
        wordId: query.wordId,
        limit: _pageSize,
      );
      page.match((_) {}, (value) {
        if (value.items.isEmpty) return;
        startFromQueue(
          ReviewQueueState(
            items: value.items,
            nextCursor: value.nextCursor,
            hasMore: value.hasMore,
          ),
          query: query,
          startId: id,
        );
      });
    } catch (_) {
      // Tetap pakai sesi satu ID.
    }
  }

  void clear() => state = null;

  /// Setelah approve / reject / correct yang menutup usulan.
  /// `true` = masih ada item berikutnya; `false` = sesi habis.
  /// Keputusan server tidak bisa di-rewind - hapus entri rewind skip.
  Future<bool> advanceAfterDecision(String decidedId) async {
    final current = state;
    if (current == null) return false;

    ref.read(reviewQueueProvider(current.query).notifier).drop(decidedId);
    ref.invalidate(reviewQueueHasPendingProvider);

    return _advancePast(decidedId, clearRewind: true);
  }

  /// Lewati tanpa keputusan - usulan tetap pending di server/antrean.
  /// Hanya keluar dari sesi saat ini. Menyimpan [rewindSkipId] untuk undo.
  Future<bool> skipCurrent() async {
    final current = state;
    final id = current?.currentId;
    if (current == null || id == null) return false;
    return _advancePast(id, rewindSkipId: id);
  }

  /// Kembalikan item yang baru di-lewati ke posisi aktif.
  /// Hanya untuk skip (approve/reject tidak punya reverse API).
  bool rewindSkip() {
    final current = state;
    final id = current?.rewindSkipId;
    if (current == null || id == null) return false;

    final ids = List<String>.of(current.ids);
    // Sudah di antrean (race) → cukup pindah index ke sana.
    final existing = ids.indexOf(id);
    if (existing >= 0) {
      state = current.copyWith(index: existing, clearRewind: true);
      _prefetchAround();
      return true;
    }

    final insertAt = current.index.clamp(0, ids.length);
    ids.insert(insertAt, id);
    state = current.copyWith(
      ids: ids,
      index: insertAt,
      clearRewind: true,
    );
    _prefetchAround();
    return true;
  }

  Future<bool> _advancePast(
    String id, {
    String? rewindSkipId,
    bool clearRewind = false,
  }) async {
    final current = state;
    if (current == null) return false;

    final ids = List<String>.of(current.ids)..remove(id);
    final removedIndex = current.ids.indexOf(id);
    var newIndex = current.index;
    if (removedIndex >= 0 && removedIndex < current.index) {
      newIndex = current.index - 1;
    } else if (removedIndex == current.index) {
      newIndex = current.index;
    }
    if (ids.isNotEmpty && newIndex >= ids.length) {
      newIndex = ids.length - 1;
    }

    if (ids.isEmpty) {
      state = current.copyWith(ids: const [], index: 0, clearRewind: true);
      final appended = await _appendMore();
      if (appended && state != null && state!.ids.isNotEmpty) {
        // Skip: jangan tampilkan ulang item yang baru dilewati dari page yang sama.
        final filtered = state!.ids.where((x) => x != id).toList();
        if (filtered.isEmpty) {
          state = null;
          return false;
        }
        state = state!.copyWith(
          ids: filtered,
          index: 0,
          rewindSkipId: rewindSkipId,
          clearRewind: clearRewind,
        );
        _prefetchAround();
        return true;
      }
      state = null;
      return false;
    }

    state = current.copyWith(
      ids: ids,
      index: newIndex,
      rewindSkipId: rewindSkipId,
      clearRewind: clearRewind,
    );
    if (state!.hasMore && state!.ids.length - state!.index <= 3) {
      await _appendMore();
    }
    _prefetchAround();
    return state?.currentId != null;
  }

  Future<bool> _appendMore() async {
    final current = state;
    if (current == null || !current.hasMore) return false;

    final page = await ref.read(reviewRepositoryProvider).list(
      status: 'pending',
      entityType: current.query.entityType,
      wordId: current.query.wordId,
      limit: _pageSize,
      cursor: current.nextCursor,
    );

    return page.match(
      (_) => false,
      (value) {
        final existing = current.ids.toSet();
        final added = [
          for (final item in value.items)
            if (!existing.contains(item.id)) item.id,
        ];
        if (added.isEmpty && !value.hasMore) {
          state = current.copyWith(
            hasMore: false,
            clearCursor: true,
          );
          return false;
        }
        state = current.copyWith(
          ids: [...current.ids, ...added],
          nextCursor: value.nextCursor,
          hasMore: value.hasMore,
          clearCursor: value.nextCursor == null,
        );
        return added.isNotEmpty;
      },
    );
  }

  void _prefetchAround() {
    final current = state;
    if (current == null) return;
    final id = current.currentId;
    if (id != null) {
      // Baca provider untuk memicu fetch; error tetap di AsyncValue.
      ref.read(reviewDetailProvider(id));
    }
    final next = current.nextId;
    if (next != null) {
      ref.read(reviewDetailProvider(next));
    }
    // Prefetch satu lagi supaya advance cepat tidak kena cold fetch.
    final afterNext = current.index + 2;
    if (afterNext >= 0 && afterNext < current.ids.length) {
      ref.read(reviewDetailProvider(current.ids[afterNext]));
    }
  }
}

void invalidateReviewQueue(WidgetRef ref) {
  ref.invalidate(reviewQueueHasPendingProvider);
  ref.invalidate(reviewQueueProvider);
}
