import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/places_remote_datasource.dart';
import '../../domain/entities/place.dart';
import 'places_providers.dart';

/// Kunci daftar: ganti chip atau kata cari = halaman pertama baru.
class PlacesBrowseQuery {
  const PlacesBrowseQuery({required this.category, this.type, this.q = ''});

  final PlaceCategory category;
  final PlaceType? type;
  final String q;

  @override
  bool operator ==(Object other) =>
      other is PlacesBrowseQuery &&
      other.category == category &&
      other.type == type &&
      other.q == q;

  @override
  int get hashCode => Object.hash(category, type, q);
}

class PlacesBrowseState {
  const PlacesBrowseState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Place> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  PlacesBrowseState copyWith({
    List<Place>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return PlacesBrowseState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

final placesBrowseProvider = AsyncNotifierProvider.autoDispose
    .family<PlacesBrowse, PlacesBrowseState, PlacesBrowseQuery>(
      PlacesBrowse.new,
    );

class PlacesBrowse extends AsyncNotifier<PlacesBrowseState> {
  PlacesBrowse(this.query);

  final PlacesBrowseQuery query;

  @override
  Future<PlacesBrowseState> build() => _fetchState();

  Future<PlacesBrowseState> _fetchState() async {
    final page = await ref
        .read(placesRepositoryProvider)
        .listPage(
          category: query.category.name,
          type: query.type?.name,
          q: query.q.isEmpty ? null : query.q,
          limit: placesBrowsePageSize,
        );
    return PlacesBrowseState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.nextCursor != null && page.items.isNotEmpty,
    );
  }

  /// Muat ulang halaman pertama. [keepItems] menahan daftar yang sudah ada
  /// saat pull-to-refresh gagal.
  Future<void> reload({bool keepItems = false}) async {
    if (!keepItems) state = const AsyncLoading();
    final next = await AsyncValue.guard(_fetchState);
    if (!ref.mounted) return;
    if (keepItems && next.hasError) return;
    state = next;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.nextCursor == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(isLoadingMore: true, loadMoreFailed: false),
    );
    try {
      final page = await ref
          .read(placesRepositoryProvider)
          .listPage(
            category: query.category.name,
            type: query.type?.name,
            q: query.q.isEmpty ? null : query.q,
            before: current.nextCursor,
            limit: placesBrowsePageSize,
          );
      if (!ref.mounted) return;
      if (page.items.isEmpty) {
        state = AsyncData(
          current.copyWith(
            isLoadingMore: false,
            hasMore: false,
            clearCursor: true,
          ),
        );
        return;
      }
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
          clearCursor: page.nextCursor == null,
          hasMore: page.nextCursor != null,
          isLoadingMore: false,
          loadMoreFailed: false,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }
}
