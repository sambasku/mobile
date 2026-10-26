import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/event_remote_datasource.dart';
import '../../domain/entities/event.dart';
import 'event_providers.dart';

/// Kunci daftar: ganti chip/filter = halaman pertama baru.
class EventBrowseQuery {
  const EventBrowseQuery({
    this.categoryId,
    this.regionId,
    this.q = '',
    this.notEnded = false,
    this.order = 'asc',
  });

  final String? categoryId;

  /// Filter kecamatan (ULID atau slug katalog publik).
  final String? regionId;
  final String q;

  /// Hanya acara yang belum selesai.
  final bool notEnded;

  /// "asc" = paling dekat dulu, "desc" = terbaru dulu.
  final String order;

  @override
  bool operator ==(Object other) =>
      other is EventBrowseQuery &&
      other.categoryId == categoryId &&
      other.regionId == regionId &&
      other.q == q &&
      other.notEnded == notEnded &&
      other.order == order;

  @override
  int get hashCode => Object.hash(categoryId, regionId, q, notEnded, order);
}

class EventBrowseState {
  const EventBrowseState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Event> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  EventBrowseState copyWith({
    List<Event>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return EventBrowseState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

final eventBrowseProvider = AsyncNotifierProvider.autoDispose
    .family<EventBrowse, EventBrowseState, EventBrowseQuery>(EventBrowse.new);

class EventBrowse extends AsyncNotifier<EventBrowseState> {
  EventBrowse(this.query);

  final EventBrowseQuery query;

  @override
  Future<EventBrowseState> build() => _fetchState();

  Future<EventBrowseState> _fetchState() async {
    final page = await ref
        .read(eventRepositoryProvider)
        .listPage(
          categoryId: query.categoryId,
          regionId: query.regionId,
          q: query.q,
          notEnded: query.notEnded,
          order: query.order,
          limit: eventsPageSize,
        );
    return EventBrowseState(
      items: page.events,
      nextCursor: page.nextCursor,
      hasMore: page.nextCursor != null,
    );
  }

  Future<void> loadMore() async {
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return;
    }
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref
          .read(eventRepositoryProvider)
          .listPage(
            before: current.nextCursor,
            categoryId: query.categoryId,
            regionId: query.regionId,
            q: query.q,
            notEnded: query.notEnded,
            order: query.order,
            limit: eventsPageSize,
          );
      if (!ref.mounted) return;
      final s = state.value ?? current;
      state = AsyncData(
        s.copyWith(
          items: [...s.items, ...page.events],
          nextCursor: page.nextCursor,
          hasMore: page.nextCursor != null,
          clearCursor: page.nextCursor == null,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      final s = state.value ?? current;
      state = AsyncData(s.copyWith(isLoadingMore: false, loadMoreFailed: true));
    }
  }

  /// Muat ulang. `keepItems` = jangan kosongkan list lama saat refresh.
  ///
  /// Tanpa `keepItems` layar pindah ke skeleton; dengan `keepItems` grid tetap
  /// terpasang sehingga `ScrollController` tidak lepas dan posisi scroll tidak
  /// balik ke atas saat pull-to-refresh.
  Future<void> reload({bool keepItems = false}) async {
    if (!ref.mounted) return;
    final previous = state.value;
    if (!keepItems) state = const AsyncLoading();
    final next = await AsyncValue.guard(_fetchState);
    if (!ref.mounted) return;
    // Refresh gagal: pertahankan data lama (jangan ganti layar jadi error).
    state = keepItems && next.hasError && previous != null
        ? AsyncData(previous)
        : next;
  }
}
