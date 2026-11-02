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
      state = AsyncData(
        latest.copyWith(
          items: [...latest.items, ...page.items],
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

  /// Pull-to-refresh (item lama tetap tampil sampai data baru datang).
  Future<void> reload({bool keepItems = false}) async {
    if (!ref.mounted) return;
    final previous = state.value?.items;
    state = const AsyncLoading();
    try {
      final next = await _fetchState();
      if (!ref.mounted) return;
      if (keepItems && previous != null && previous.isNotEmpty) {
        state = AsyncData(next.copyWith(items: previous));
      } else {
        state = AsyncData(next);
      }
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncError(e, st);
    }
  }
}
