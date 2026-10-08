import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/activity_feed_repository.dart';
import '../../domain/entities/feed_activity_item.dart';

final activityFeedRepositoryProvider = Provider<ActivityFeedRepository>((ref) {
  return ActivityFeedRepository(
    ref.watch(dioProvider),
    cache: ref.watch(cachedJsonClientProvider),
  );
});

/// Feed beranda menyembunyikan karya sendiri - HANYA saat login.
final excludeSelfFeedProvider = Provider<bool>((ref) {
  final auth = ref.watch(authStatusProvider).value;
  if (!(auth?.isAuth ?? false)) return false;
  // `isAuth` true tapi `userId` masih null (prefs belum terisi, sync
  // `GET /users/me` gagal) → jangan sembunyikan apa pun. Saat tidak yakin siapa
  // dirinya, menampilkan semua lebih aman daripada feed kosong tanpa penjelasan.
  //
  // Ini juga mencegah flag terkirim tanpa viewer: server mengabaikan
  // `exclude_self` kalau tidak ada Bearer sah, jadi hasilnya tetap utuh.
  return (auth?.userId ?? '').trim().isNotEmpty;
});

class ActivityFeedState {
  const ActivityFeedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.nextCursor,
    this.hasMore = false,
    this.errorMessage,
  });

  final List<FeedActivityItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? nextCursor;
  final bool hasMore;
  final String? errorMessage;

  ActivityFeedState copyWith({
    List<FeedActivityItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? nextCursor,
    bool? hasMore,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool clearCursor = false,
  }) {
    return ActivityFeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class ActivityFeedNotifier extends Notifier<ActivityFeedState> {
  static const _pageSize = 20;

  int _loadReqId = 0;
  int _loadMoreReqId = 0;
  bool _isLoadingSync = false;
  bool _isLoadingMoreSync = false;

  @override
  ActivityFeedState build() {
    // Login/logout → muat ulang. Tanpa ini feed tamu yang sudah ter-cache tetap
    // tampil di layar setelah user login. Sengaja hanya `isAuth` + `userId`:
    // ganti avatar atau display name tidak boleh memanggil ulang feed.
    ref.listen(excludeSelfFeedProvider, (prev, next) {
      if (prev != null && prev != next) Future.microtask(load);
    });
    Future.microtask(load);
    return const ActivityFeedState(isLoading: true);
  }

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoadingSync || !ref.mounted) return;
    _isLoadingSync = true;
    final reqId = ++_loadReqId;
    _loadMoreReqId++;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      clearErrorMessage: true,
      clearCursor: true,
      hasMore: false,
    );

    try {
      final page = await ref
          .read(activityFeedRepositoryProvider)
          .list(
            limit: _pageSize,
            forceRefresh: forceRefresh,
            excludeSelf: ref.read(excludeSelfFeedProvider),
          );
      if (!ref.mounted || reqId != _loadReqId) return;
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        hasMore: page.hasMore,
      );
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

  Future<void> loadMore() async {
    final current = state;
    if (_isLoadingMoreSync ||
        !ref.mounted ||
        current.isLoading ||
        current.isLoadingMore ||
        !current.hasMore ||
        current.nextCursor == null) {
      return;
    }
    _isLoadingMoreSync = true;
    final reqId = ++_loadMoreReqId;

    state = current.copyWith(isLoadingMore: true);

    try {
      final page = await ref
          .read(activityFeedRepositoryProvider)
          .list(
            limit: _pageSize,
            cursor: current.nextCursor,
            // Wajib ikut di loadMore: cursor halaman berikutnya tanpa flag akan
            // mengembalikan karya sendiri dan bocor ke ekor feed.
            excludeSelf: ref.read(excludeSelfFeedProvider),
          );
      if (!ref.mounted || reqId != _loadMoreReqId) return;
      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...page.items],
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        hasMore: page.hasMore,
      );
    } catch (_) {
      if (ref.mounted && reqId == _loadMoreReqId) {
        state = state.copyWith(isLoadingMore: false);
      }
    } finally {
      if (reqId == _loadMoreReqId) {
        _isLoadingMoreSync = false;
      }
    }
  }
}

final activityFeedProvider =
    NotifierProvider<ActivityFeedNotifier, ActivityFeedState>(
      ActivityFeedNotifier.new,
    );
