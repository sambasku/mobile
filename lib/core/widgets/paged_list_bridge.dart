import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

/// Bridge [PagingController] (infinite_scroll_pagination v5) dengan state
/// Riverpod yang memakai pola cursor: `items` (append-only), `nextCursor`,
/// `hasMore`, dan `loadMore()` pada notifier.
///
/// Pembagian peran:
/// - [PagingController] = mesin autoload & virtualisasi (invisibleItemsThreshold,
///   mutex anti double-fetch, indicator status halaman).
/// - State Riverpod = sumber data list yang dirender (append oleh `loadMore`).
/// - List paged view diberi `state: <PagingState>` hasil [buildPagingState]
///   dan `fetchNextPage: controller.fetchNextPage`.
///
/// Kontrak state Riverpod:
/// - `items: List<Item>` (append-only; loadMore menambah di ekor)
/// - `hasMore: bool`
/// - `loadMore(): Future<void>` pada notifier (no-op saat tidak ada halaman lagi)
///
/// ponytail: bridge tipis tanpa abstraksi tambahan; kalau nanti semua notifier
/// pindah ke pola library (PagingController di provider), file ini dihapus.
PagingState<int, Item> buildPagingState<Item>({
  required List<Item> items,
  required bool hasMore,
  int loadedPages = 1,
  bool isLoading = false,
}) {
  // Items disimpan sebagai SATU halaman penuh (snapshot semua yang sudah
  // dimuat); key per halaman tidak dipakai untuk fetch (fetchNextPage hanya
  // memicu loadMore Riverpod), cukup penomoran urut.
  return PagingState<int, Item>(
    pages: [items],
    keys: [loadedPages],
    hasNextPage: hasMore,
    isLoading: isLoading,
  );
}

/// Hook halaman: buat controller yang memicu `loadMore()` notifier Riverpod
/// saat autoload. Buat di initState StatefulWidget, dispose di dispose().
PagingController<int, Item> createPagingController<Item>({
  required Future<void> Function() loadMore,
  void Function(Object error)? onError,
}) {
  return PagingController<int, Item>(
    getNextPageKey: (state) => state.nextIntPageKey,
    // fetchPage hanya menjembatani trigger autoload -> loadMore Riverpod.
    // Return halaman KOSONG: data asli dirender dari state Riverpod, dan
    // [buildPagingState] selalu overwrite `pages` dengan snapshot terbaru,
    // jadi halaman kosong ini tidak pernah tampil.
    fetchPage: (_) async {
      try {
        await loadMore();
      } catch (e) {
        onError?.call(e);
        rethrow;
      }
      return const [];
    },
  );
}
