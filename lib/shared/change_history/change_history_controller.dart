import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/network/network_providers.dart';
import 'change_history_models.dart';

String wordChangeHistoryPath(String wordId) =>
    '/api/v1/words/${Uri.encodeComponent(wordId)}/change-history';

String placeChangeHistoryPath(String slug) =>
    '/api/v1/places/${Uri.encodeComponent(slug)}/change-history';

String cuisineChangeHistoryPath(String slug) =>
    '/api/v1/culinary/cuisines/${Uri.encodeComponent(slug)}/change-history';

class ChangeHistoryListState {
  const ChangeHistoryListState({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final List<ChangeHistoryEntry> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  ChangeHistoryListState copyWith({
    List<ChangeHistoryEntry>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ChangeHistoryListState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

/// Key = path endpoint riwayat (`wordChangeHistoryPath`, dst).
final changeHistoryControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ChangeHistoryController, ChangeHistoryListState, String>(
      ChangeHistoryController.new,
    );

class ChangeHistoryController extends AsyncNotifier<ChangeHistoryListState> {
  ChangeHistoryController(this.path);

  final String path;
  static const _pageSize = 20;

  Future<ChangeHistoryPageData> _fetch({String? cursor}) async {
    final res = await ref
        .read(dioProvider)
        .get<Map<String, dynamic>>(
          path,
          queryParameters: {'limit': _pageSize, 'cursor': ?cursor},
        );
    return ChangeHistoryPageData.fromResponse(res.data);
  }

  @override
  Future<ChangeHistoryListState> build() async {
    final page = await _fetch();
    return ChangeHistoryListState(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await _fetch(cursor: current.nextCursor);
      if (!ref.mounted) return;
      state = AsyncData(
        ChangeHistoryListState(
          items: [...current.items, ...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
        ),
      );
    } catch (_) {
      if (!ref.mounted) return;
      // Gagal muat lanjutan: pertahankan daftar, tombol "muat lebih" tetap ada.
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
}
