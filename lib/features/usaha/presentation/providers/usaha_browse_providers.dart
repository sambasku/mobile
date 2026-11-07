import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/usaha_remote_datasource.dart';
import '../../domain/entities/usaha.dart';
import 'usaha_providers.dart';

/// Kunci daftar: ganti chip/filter = halaman pertama baru.
class UsahaBrowseQuery {
  const UsahaBrowseQuery({this.categoryId, this.regionId, this.q = ''});

  final String? categoryId;

  /// Filter kecamatan (ULID atau slug katalog publik).
  final String? regionId;
  final String q;

  @override
  bool operator ==(Object other) =>
      other is UsahaBrowseQuery &&
      other.categoryId == categoryId &&
      other.regionId == regionId &&
      other.q == q;

  @override
  int get hashCode => Object.hash(categoryId, regionId, q);
}

class UsahaBrowseState {
  const UsahaBrowseState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreFailed = false,
  });

  final List<Usaha> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool loadMoreFailed;

  UsahaBrowseState copyWith({
    List<Usaha>? items,
    String? nextCursor,
    bool clearCursor = false,
    bool? hasMore,
    bool? isLoadingMore,
    bool? loadMoreFailed,
  }) {
    return UsahaBrowseState(
      items: items ?? this.items,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

final usahaBrowseProvider = AsyncNotifierProvider.autoDispose
    .family<UsahaBrowse, UsahaBrowseState, UsahaBrowseQuery>(UsahaBrowse.new);

class UsahaBrowse extends AsyncNotifier<UsahaBrowseState> {
  UsahaBrowse(this.query);

  final UsahaBrowseQuery query;

  @override
  Future<UsahaBrowseState> build() => _fetchState();

  Future<UsahaBrowseState> _fetchState() async {
    final page = await ref
        .read(usahaRepositoryProvider)
        .listPage(
          limit: usahasPageSize,
          categoryId: query.categoryId,
          regionId: query.regionId,
          q: query.q,
        );
    return UsahaBrowseState(
      items: page.items,
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
    state = AsyncData(current.copyWith(isLoadingMore: true, loadMoreFailed: false));
    try {
      final page = await ref
          .read(usahaRepositoryProvider)
          .listPage(
            limit: usahasPageSize,
            before: current.nextCursor,
            categoryId: query.categoryId,
            regionId: query.regionId,
            q: query.q,
          );
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      final seen = latest.items.map((u) => u.id).toSet();
      final fresh = page.items.where((u) => seen.add(u.id)).toList();
      if (fresh.isEmpty) {
        state = AsyncData(
          latest.copyWith(
            isLoadingMore: false,
            hasMore: false,
            clearCursor: true,
            loadMoreFailed: false,
          ),
        );
        return;
      }
      state = AsyncData(
        latest.copyWith(
          items: [...latest.items, ...fresh],
          nextCursor: page.nextCursor,
          hasMore: page.nextCursor != null,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      final latest = state.value ?? current;
      state = AsyncData(
        latest.copyWith(isLoadingMore: false, loadMoreFailed: true),
      );
    }
  }

  /// Muat ulang. `keepItems` = jangan kosongkan list lama saat refresh.
  ///
  /// Tanpa `keepItems` layar pindah ke skeleton; dengan `keepItems` grid tetap
  /// terpasang sehingga `ScrollController` tidak lepas dan `RefreshIndicator`
  /// tidak ter-unmount saat pull-to-refresh.
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
