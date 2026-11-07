import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/encyclopedia_providers.dart';
import '../../domain/encyclopedia.entity.dart';

/// Kunci daftar: ganti chip/kategori atau kata cari = halaman pertama baru.
class EncyclopediaListQuery {
  const EncyclopediaListQuery({this.categoryId, this.q = ''});
  final String? categoryId;
  final String q;

  @override
  bool operator ==(Object other) =>
      other is EncyclopediaListQuery &&
      other.categoryId == categoryId &&
      other.q == q;

  @override
  int get hashCode => Object.hash(categoryId, q);
}

class EncyclopediaListState {
  const EncyclopediaListState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<EncyclopediaArticleListItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  EncyclopediaListState copyWith({
    List<EncyclopediaArticleListItem>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return EncyclopediaListState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

final encyclopediaCategoriesProvider = FutureProvider.autoDispose<
  List<EncyclopediaCategory>
>((ref) async {
  final resp = await ref.watch(encyclopediaRepositoryProvider).getCategories();
  return resp.data?.items ?? [];
});

final encyclopediaListProvider = AsyncNotifierProvider.autoDispose
    .family<EncyclopediaList, EncyclopediaListState, EncyclopediaListQuery>(
      EncyclopediaList.new,
    );

class EncyclopediaList extends AsyncNotifier<EncyclopediaListState> {
  EncyclopediaList(this.query);
  final EncyclopediaListQuery query;

  Map<String, dynamic> _params({String? cursor}) => {
    if (query.categoryId case final id? when id.isNotEmpty) 'category_id': id,
    if (query.q.isNotEmpty) 'q': query.q,
    'cursor': ?cursor,
    'limit': 20,
  };

  @override
  Future<EncyclopediaListState> build() async {
    final page = await ref
        .read(encyclopediaRepositoryProvider)
        .listArticles(_params());
    if (!ref.mounted) return const EncyclopediaListState();
    return EncyclopediaListState(
      items: page.data?.items ?? [],
      nextCursor: page.data?.nextCursor,
      hasMore: page.data?.hasMore ?? false,
    );
  }

  Future<void> reload({bool keepItems = false}) async {
    if (!ref.mounted) return;
    final previous = state.value;
    if (!keepItems) state = const AsyncLoading();
    final next = await AsyncValue.guard(
      () async {
        final page = await ref
            .read(encyclopediaRepositoryProvider)
            .listArticles(_params());
        return EncyclopediaListState(
          items: page.data?.items ?? [],
          nextCursor: page.data?.nextCursor,
          hasMore: page.data?.hasMore ?? false,
        );
      },
    );
    if (!ref.mounted) return;
    state = keepItems && next.hasError && previous != null
        ? AsyncData(previous)
        : next;
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
          .read(encyclopediaRepositoryProvider)
          .listArticles(_params(cursor: current.nextCursor));
      if (!ref.mounted) return;
      final s = state.value ?? current;
      final items = page.data?.items ?? [];
      state = AsyncData(
        items.isEmpty
            ? s.copyWith(isLoadingMore: false, hasMore: false, clearCursor: true)
            : s.copyWith(
                items: [...s.items, ...items],
                nextCursor: page.data?.nextCursor,
                clearCursor: page.data?.nextCursor == null,
                hasMore: page.data?.hasMore ?? false,
                isLoadingMore: false,
              ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      final s = state.value ?? current;
      state = AsyncData(s.copyWith(isLoadingMore: false, loadMoreFailed: true));
    }
  }
}