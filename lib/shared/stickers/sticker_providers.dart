import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/network/network_providers.dart';
import 'sticker_models.dart';
import 'sticker_repository.dart';

final stickerRepositoryProvider = Provider<StickerRepository>((ref) {
  return StickerRepository(ref.watch(dioProvider));
});

class StickerPickerState {
  const StickerPickerState({
    this.items = const [],
    this.categories = const [],
    this.nextCursor,
    this.categorySlug,
    this.q = '',
    this.loading = false,
    this.loadingMore = false,
    this.error,
  });

  final List<CatalogSticker> items;
  final List<String> categories;
  final String? nextCursor;
  final String? categorySlug;
  final String q;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  StickerPickerState copyWith({
    List<CatalogSticker>? items,
    List<String>? categories,
    Object? nextCursor = _unset,
    Object? categorySlug = _unset,
    String? q,
    bool? loading,
    bool? loadingMore,
    Object? error = _unset,
  }) {
    return StickerPickerState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      nextCursor: identical(nextCursor, _unset)
          ? this.nextCursor
          : nextCursor as String?,
      categorySlug: identical(categorySlug, _unset)
          ? this.categorySlug
          : categorySlug as String?,
      q: q ?? this.q,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: identical(error, _unset) ? this.error : error,
    );
  }

  static const Object _unset = Object();
}

final stickerPickerProvider =
    NotifierProvider<StickerPickerController, StickerPickerState>(
  StickerPickerController.new,
);

class StickerPickerController extends Notifier<StickerPickerState> {
  @override
  StickerPickerState build() => const StickerPickerState();

  Future<void> reload({
    String? categorySlug,
    String? q,
  }) async {
    final nextCat = categorySlug;
    final nextQ = q ?? state.q;
    state = state.copyWith(
      loading: true,
      error: null,
      categorySlug: nextCat,
      q: nextQ,
      items: const [],
      nextCursor: null,
    );
    final page = await ref.read(stickerRepositoryProvider).fetchPage(
          q: nextQ,
          categorySlug: nextCat,
        );
    if (!ref.mounted) return;
    state = state.copyWith(
      loading: false,
      items: page.items,
      categories: page.categories,
      nextCursor: page.nextCursor,
    );
  }

  Future<void> setCategory(String? categorySlug) {
    return reload(categorySlug: categorySlug, q: state.q);
  }

  Future<void> setQuery(String q) {
    return reload(categorySlug: state.categorySlug, q: q);
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    final cursor = state.nextCursor;
    state = state.copyWith(loadingMore: true);
    final page = await ref.read(stickerRepositoryProvider).fetchPage(
          q: state.q,
          categorySlug: state.categorySlug,
          cursor: cursor,
        );
    if (!ref.mounted) return;
    state = state.copyWith(
      loadingMore: false,
      items: [...state.items, ...page.items],
      categories: page.categories.isNotEmpty ? page.categories : state.categories,
      nextCursor: page.nextCursor,
    );
  }
}

/// Resolve satu stiker by id (bubble chat / komentar).
final stickerLookupProvider =
    FutureProvider.family<CatalogSticker?, String>((ref, id) {
  return ref.watch(stickerRepositoryProvider).fetchById(id);
});
