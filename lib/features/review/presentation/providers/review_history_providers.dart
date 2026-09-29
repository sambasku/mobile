import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/review_contribution.dart';
import 'review_providers.dart';

class ReviewHistoryStatusFilter {
  const ReviewHistoryStatusFilter(this.value, this.label);
  final String? value;
  final String label;
}

const reviewHistoryStatusFilters = [
  ReviewHistoryStatusFilter(null, 'Semua'),
  ReviewHistoryStatusFilter('approved', 'Disetujui'),
  ReviewHistoryStatusFilter('rejected', 'Ditolak'),
  ReviewHistoryStatusFilter('corrected', 'Dikoreksi'),
  ReviewHistoryStatusFilter('pending', 'Dibuka ulang'),
];

class ReviewHistoryState {
  const ReviewHistoryState({
    required this.items,
    this.statusFilter,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<ReviewItem> items;
  final String? statusFilter;
  final String? nextCursor;
  final bool hasMore;

  ReviewHistoryState copyWith({
    List<ReviewItem>? items,
    String? statusFilter,
    bool clearStatusFilter = false,
    String? nextCursor,
    bool? hasMore,
  }) {
    return ReviewHistoryState(
      items: items ?? this.items,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ReviewHistoryController extends AsyncNotifier<ReviewHistoryState> {
  static const _limit = 20;
  String? _statusFilter;

  @override
  Future<ReviewHistoryState> build() => _fetch();

  String? get statusFilter => _statusFilter;

  Future<void> setStatusFilter(String? status) async {
    _statusFilter = status;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<ReviewHistoryState> _fetch({String? cursor}) async {
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.list(
      status: _statusFilter,
      mine: true,
      limit: _limit,
      cursor: cursor,
    );
    return result.fold(
      (failure) => throw failure,
      (page) => ReviewHistoryState(
        items: page.items,
        statusFilter: _statusFilter,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
      ),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.nextCursor == null) {
      return;
    }
    final repo = ref.read(reviewRepositoryProvider);
    final result = await repo.list(
      status: _statusFilter,
      mine: true,
      limit: _limit,
      cursor: current.nextCursor,
    );
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (page) {
        state = AsyncData(
          current.copyWith(
            items: [...current.items, ...page.items],
            nextCursor: page.nextCursor,
            hasMore: page.hasMore,
          ),
        );
      },
    );
  }
}

final reviewHistoryControllerProvider =
    AsyncNotifierProvider.autoDispose<ReviewHistoryController, ReviewHistoryState>(
  ReviewHistoryController.new,
);
