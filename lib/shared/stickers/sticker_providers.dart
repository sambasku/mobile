import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/network/network_providers.dart';
import '../../features/auth/presentation/providers/auth_status_providers.dart';
import 'sticker_models.dart';
import 'sticker_repository.dart';

final stickerRepositoryProvider = Provider<StickerRepository>((ref) {
  return StickerRepository(ref.watch(dioProvider));
});

enum StickerDeckTab { catalog, favorites, mine }

class StickerPickerState {
  const StickerPickerState({
    this.items = const [],
    this.categories = const [],
    this.nextCursor,
    this.categorySlug,
    this.tab = StickerDeckTab.catalog,
    this.q = '',
    this.loading = false,
    this.loadingMore = false,
    this.error,
  });

  final List<CatalogSticker> items;
  final List<String> categories;
  final String? nextCursor;
  final String? categorySlug;
  final StickerDeckTab tab;
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
    StickerDeckTab? tab,
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
      tab: tab ?? this.tab,
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
      tab: StickerDeckTab.catalog,
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

  void setTab(StickerDeckTab tab) {
    if (state.tab == tab) return;
    state = state.copyWith(tab: tab);
  }

  Future<void> setCategory(String? categorySlug) {
    return reload(categorySlug: categorySlug, q: state.q);
  }

  Future<void> setQuery(String q) {
    if (state.tab != StickerDeckTab.catalog) {
      state = state.copyWith(q: q);
      return Future.value();
    }
    return reload(categorySlug: state.categorySlug, q: q);
  }

  Future<void> loadMore() async {
    if (state.tab != StickerDeckTab.catalog) return;
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

/// Hasil toggle favorit untuk feedback UI.
class StickerFavoriteToggleResult {
  const StickerFavoriteToggleResult({
    required this.isFavorite,
    this.errorCode,
  });

  final bool isFavorite;
  final String? errorCode;

  bool get ok => errorCode == null;
}

/// Favorit bisa berupa stiker asli atau salinan fork milik user (sourceStickerId = asal).
bool _matchesSticker(CatalogSticker s, String stickerId) =>
    s.id == stickerId || s.sourceStickerId == stickerId;

CatalogSticker? _favoriteFor(List<CatalogSticker> items, String stickerId) {
  for (final s in items) {
    if (_matchesSticker(s, stickerId)) return s;
  }
  return null;
}

class StickerFavoritesState {
  const StickerFavoritesState({
    this.items = const [],
    this.loading = false,
    this.loaded = false,
    this.inFlight = const {},
  });

  final List<CatalogSticker> items;
  final bool loading;
  final bool loaded;
  final Set<String> inFlight;

  bool contains(String stickerId) =>
      items.any((s) => _matchesSticker(s, stickerId));
  bool isBusy(String stickerId) => inFlight.contains(stickerId);

  StickerFavoritesState copyWith({
    List<CatalogSticker>? items,
    bool? loading,
    bool? loaded,
    Set<String>? inFlight,
  }) {
    return StickerFavoritesState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loaded: loaded ?? this.loaded,
      inFlight: inFlight ?? this.inFlight,
    );
  }
}

final stickerFavoritesProvider =
    NotifierProvider<StickerFavoritesController, StickerFavoritesState>(
  StickerFavoritesController.new,
);

class StickerFavoritesController extends Notifier<StickerFavoritesState> {
  String? _activeUserId;

  @override
  StickerFavoritesState build() {
    final auth = ref.watch(authStatusProvider).value;
    final userId = (auth?.isAuth == true) ? auth?.userId : null;
    if (_activeUserId != null && _activeUserId != userId) {
      final prevUser = _activeUserId!;
      unawaited(ref.read(stickerRepositoryProvider).clearUserCache(prevUser));
    }
    _activeUserId = userId;
    if (userId != null && userId.isNotEmpty) {
      Future.microtask(() => load(force: false));
    }
    return const StickerFavoritesState();
  }

  Future<void> load({bool force = true}) async {
    final userId = _activeUserId;
    if (userId == null || userId.isEmpty) {
      state = const StickerFavoritesState(loaded: true);
      return;
    }
    if (!force && (state.loaded || state.loading)) return;
    final repo = ref.read(stickerRepositoryProvider);
    if (!state.loaded) {
      final cached = await repo.readCachedFavorites(userId);
      if (!ref.mounted || _activeUserId != userId) return;
      if (cached.isNotEmpty) {
        state = state.copyWith(items: cached);
      }
    }
    state = state.copyWith(loading: true);
    final fresh = await repo.fetchFavorites(userId);
    if (!ref.mounted || _activeUserId != userId) return;
    state = state.copyWith(items: fresh, loading: false, loaded: true);
  }

  Future<StickerFavoriteToggleResult> toggle(CatalogSticker sticker) async {
    final userId = _activeUserId;
    if (userId == null || userId.isEmpty) {
      return const StickerFavoriteToggleResult(
        isFavorite: false,
        errorCode: 'UNAUTHORIZED',
      );
    }
    if (state.isBusy(sticker.id)) {
      return StickerFavoriteToggleResult(isFavorite: state.contains(sticker.id));
    }
    final existing = _favoriteFor(state.items, sticker.id);
    final wasFav = existing != null;
    final prevItems = state.items;
    final nextItems = wasFav
        ? prevItems
            .where((s) => !_matchesSticker(s, sticker.id))
            .toList(growable: false)
        : [sticker, ...prevItems.where((s) => !_matchesSticker(s, sticker.id))];

    state = state.copyWith(
      items: nextItems,
      inFlight: {...state.inFlight, sticker.id},
    );

    final repo = ref.read(stickerRepositoryProvider);
    try {
      if (existing != null) {
        await repo.removeFavorite(existing.id);
      } else {
        final saved = await repo.addFavorite(sticker.id);
        if (ref.mounted && _activeUserId == userId) {
          final merged = [
            saved,
            ...state.items.where(
              (s) => s.id != saved.id && !_matchesSticker(s, sticker.id),
            ),
          ];
          state = state.copyWith(items: merged);
        }
      }
      if (ref.mounted && _activeUserId == userId) {
        await repo.writeCachedFavorites(userId, state.items);
        state = state.copyWith(
          inFlight: {...state.inFlight}..remove(sticker.id),
        );
      }
      return StickerFavoriteToggleResult(isFavorite: !wasFav);
    } on StickerApiException catch (e) {
      if (ref.mounted && _activeUserId == userId) {
        state = state.copyWith(
          items: prevItems,
          inFlight: {...state.inFlight}..remove(sticker.id),
        );
      }
      return StickerFavoriteToggleResult(
        isFavorite: wasFav,
        errorCode: e.errorCode ?? 'ERROR',
      );
    } catch (_) {
      if (ref.mounted && _activeUserId == userId) {
        state = state.copyWith(
          items: prevItems,
          inFlight: {...state.inFlight}..remove(sticker.id),
        );
      }
      return StickerFavoriteToggleResult(
        isFavorite: wasFav,
        errorCode: 'ERROR',
      );
    }
  }
}

class MyStickersState {
  const MyStickersState({
    this.items = const [],
    this.loading = false,
    this.loaded = false,
  });

  final List<CatalogSticker> items;
  final bool loading;
  final bool loaded;

  MyStickersState copyWith({
    List<CatalogSticker>? items,
    bool? loading,
    bool? loaded,
  }) {
    return MyStickersState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      loaded: loaded ?? this.loaded,
    );
  }
}

final myStickersProvider =
    NotifierProvider<MyStickersController, MyStickersState>(
  MyStickersController.new,
);

class MyStickersController extends Notifier<MyStickersState> {
  String? _activeUserId;

  @override
  MyStickersState build() {
    final auth = ref.watch(authStatusProvider).value;
    final userId = (auth?.isAuth == true) ? auth?.userId : null;
    _activeUserId = userId;
    if (userId != null && userId.isNotEmpty) {
      Future.microtask(() => load(force: false));
    }
    return const MyStickersState();
  }

  Future<void> load({bool force = true}) async {
    final userId = _activeUserId;
    if (userId == null || userId.isEmpty) {
      state = const MyStickersState(loaded: true);
      return;
    }
    if (!force && (state.loaded || state.loading)) return;
    final repo = ref.read(stickerRepositoryProvider);
    if (!state.loaded) {
      final cached = await repo.readCachedMine(userId);
      if (!ref.mounted || _activeUserId != userId) return;
      if (cached.isNotEmpty) {
        state = state.copyWith(items: cached);
      }
    }
    state = state.copyWith(loading: true);
    final fresh = await repo.fetchMine(userId);
    if (!ref.mounted || _activeUserId != userId) return;
    state = state.copyWith(items: fresh, loading: false, loaded: true);
  }

  void prepend(CatalogSticker sticker) {
    final userId = _activeUserId;
    final next = [sticker, ...state.items.where((s) => s.id != sticker.id)];
    state = state.copyWith(items: next, loaded: true);
    if (userId != null && userId.isNotEmpty) {
      unawaited(ref.read(stickerRepositoryProvider).writeCachedMine(userId, next));
    }
  }

  Future<String?> deleteMine(String stickerId) async {
    final userId = _activeUserId;
    if (userId == null || userId.isEmpty) return 'UNAUTHORIZED';
    final repo = ref.read(stickerRepositoryProvider);
    try {
      await repo.deleteMine(stickerId);
      if (!ref.mounted || _activeUserId != userId) return null;
      final next =
          state.items.where((s) => s.id != stickerId).toList(growable: false);
      state = state.copyWith(items: next);
      await repo.writeCachedMine(userId, next);
      // Hapus juga dari daftar favorit lokal jika sebelumnya difavoritkan.
      unawaited(ref.read(stickerFavoritesProvider.notifier).load(force: true));
      return null;
    } on StickerApiException catch (e) {
      return e.errorCode ?? 'ERROR';
    } catch (_) {
      return 'ERROR';
    }
  }
}

/// Resolve satu stiker by id (bubble chat / komentar).
final stickerLookupProvider =
    FutureProvider.family<CatalogSticker?, String>((ref, id) {
  return ref.watch(stickerRepositoryProvider).fetchById(id);
});
