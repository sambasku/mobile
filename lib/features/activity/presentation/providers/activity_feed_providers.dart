import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/cache/cache_providers.dart';
import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/activity_feed_repository.dart';
import '../../domain/entities/feed_activity_item.dart';
import '../../../../core/i18n/l10n.dart';

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
  // `GET /users/me` gagal) → jangan sembunyikan apa pun. Saat tidak yaku siapa
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
    this.hasLoaded = false,
  });

  final List<FeedActivityItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? nextCursor;
  final bool hasMore;
  final String? errorMessage;

  /// #193: pernah selesai satu kali load (sukses ATAU gagal) - penanda
  /// "sudah pernah fetch" yang jujur, bukan hack `isLoading && items.isEmpty`
  /// (yang menyamakan "belum pernah" dengan "sedang dimuat").
  final bool hasLoaded;

  ActivityFeedState copyWith({
    List<FeedActivityItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? nextCursor,
    bool? hasMore,
    String? errorMessage,
    bool? hasLoaded,
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
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}

/// #193: feed per kategori chips. LAZY by design - hemat request + query
/// Turso: hanya `all` yang auto-load di frame pertama. Kategori lain mulai
/// kosong (`hasLoaded: false`) dan baru fetch saat chip PERTAMA kali di-tap
/// (`ensureLoaded`). Tanpa autoDispose: state per kategori bertahan selama
/// sesi, pindah-pindah chip = nol request.
class ActivityFeedNotifier extends Notifier<ActivityFeedState> {
  ActivityFeedNotifier(this.category);

  /// Kategori argumen family. Disimpan di field (bukan dibaca dari `ref`):
  /// Riverpod 3 tidak mengekspos argumen family ke `Notifier` manual.
  final FeedCategory category;

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

    // #193: hanya kategori `all` yang auto-load (beranda harus terisi di frame
    // pertama). Kategori lain menunggu `ensureLoaded` dari tap chip.
    if (category == FeedCategory.all) {
      Future.microtask(load);
      return const ActivityFeedState(isLoading: true);
    }
    return const ActivityFeedState();
  }

  /// #193: fetch hanya bila belum pernah. Chip yang sudah dimuat = nol
  /// request (state di memori), dipanggil dari tap chip.
  void ensureLoaded() {
    if (state.hasLoaded || _isLoadingSync) return;
    load();
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
      // #167: pastikan authStatus resolve (atau timeout 2s) sebelum fetch
      // pertama. Tanpa ini flag `excludeSelf` dibaca saat future masih
      // loading → false → data sendiri flash → reload. Timeout/storage
      // error: lanjut saja - backend kini selalu exclude saat Bearer sah.
      try {
        await ref
            .read(authStatusProvider.future)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
      final page = await ref
          .read(activityFeedRepositoryProvider)
          .list(
            limit: _pageSize,
            forceRefresh: forceRefresh,
            excludeSelf: ref.read(excludeSelfFeedProvider),
            category: category,
          );
      if (!ref.mounted || reqId != _loadReqId) return;
      state = state.copyWith(
        isLoading: false,
        items: page.items,
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
        hasMore: page.hasMore,
        // Gagal/sukses tetap "pernah load": error tampil, retry manual via
        // pull-to-refresh. Tidak ada loop retry per tap.
        hasLoaded: true,
      );
    } catch (e) {
      if (ref.mounted && reqId == _loadReqId) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: l10n.feedLoadFailed,
          hasLoaded: true,
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
            category: category,
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
    NotifierProvider.family<ActivityFeedNotifier, ActivityFeedState, FeedCategory>(
  ActivityFeedNotifier.new,
);
