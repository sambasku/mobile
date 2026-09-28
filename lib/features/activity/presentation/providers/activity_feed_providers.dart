import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../data/activity_feed_repository.dart';
import '../../domain/entities/feed_activity_item.dart';

final activityFeedRepositoryProvider = Provider<ActivityFeedRepository>((ref) {
  return ActivityFeedRepository(
    ref.watch(dioProvider),
    cache: ref.watch(cachedJsonClientProvider),
  );
});

class ActivityFeedState {
  const ActivityFeedState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<FeedActivityItem> items;
  final bool isLoading;
  final String? errorMessage;

  ActivityFeedState copyWith({
    List<FeedActivityItem>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ActivityFeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class ActivityFeedNotifier extends Notifier<ActivityFeedState> {
  int _loadReqId = 0;
  bool _isLoadingSync = false;

  @override
  ActivityFeedState build() {
    Future.microtask(load);
    return const ActivityFeedState(isLoading: true);
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoadingSync || !ref.mounted) return;
    _isLoadingSync = true;
    final reqId = ++_loadReqId;

    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final items = await ref.read(activityFeedRepositoryProvider).list(
            forceRefresh: forceRefresh,
          );
      if (!ref.mounted || reqId != _loadReqId) return;
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      if (ref.mounted && reqId == _loadReqId) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Gagal memuat aktivitas.',
        );
      }
    } finally {
      if (reqId == _loadReqId) {
        _isLoadingSync = false;
      }
    }
  }
}

final activityFeedProvider =
    NotifierProvider<ActivityFeedNotifier, ActivityFeedState>(
  ActivityFeedNotifier.new,
);
