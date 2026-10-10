import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/word_summary.dart';
import '../../domain/failures/dictionary_failure.dart';
import '../../domain/providers/dictionary_domain_providers.dart';
import '../../domain/usecases/list_words_use_case.dart';
import '../../domain/usecases/search_words_use_case.dart';
import '../models/word_list_state.dart';
import '../providers/search_history_provider.dart';

part 'word_list_providers.g.dart';

/// Debounce filter q - sama dengan pencarian beranda (400 ms).
const _kDebounceMs = 400;

/// Notifier halaman Daftar Kata A-Z (18-api-list-words.md). Meniru
/// DictionarySearchNotifier: debounce, req id guard anti stale response,
/// sync lock anti double-fire. Bedanya: halaman 1 dimuat sejak build
/// (bukan idle menunggu query), q kosong = full A-Z.
///
/// keepAlive: cache list + posisi fetch tetap saat keluar ke detail /
/// beranda lalu kembali - jangan reload A-Z dari nol tiap buka.
///
/// PENTING: early-return (stale / !mounted) JANGAN tinggalkan
/// `isLoading: true` tanpa in-flight request - itu biang infinite
/// skeleton saat user back lalu masuk lagi (terutama korpus kosong).
@Riverpod(keepAlive: true)
class WordListNotifier extends _$WordListNotifier {
  Timer? _debounce;
  int _loadReqId = 0;
  int _loadMoreReqId = 0;
  bool _isLoadingSync = false;
  bool _isLoadingMoreSync = false;

  @override
  WordListState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _debounce = null;
    });

    // keepAlive: listener hilang saat pop, kembali saat push. Jika state
    // tersisa isLoading tanpa Future (race stale/dispose lama), pulihkan.
    // Riverpod 3: jangan baca/tulis `state` di dalam lifecycle - defer.
    ref.onResume(() {
      scheduleMicrotask(() {
        if (!ref.mounted) return;
        if (state.isLoading && !_isLoadingSync) {
          load();
        }
      });
    });

    // Muat halaman pertama segera (juga setelah invalidate/pull-to-refresh).
    scheduleMicrotask(load);
    return const WordListState(isLoading: true);
  }

  /// Batalkan request yang masih di udara. Dipakai saat mode atau q
  /// berubah supaya jawaban lama tidak menimpa state yang baru.
  void _dropInFlight() {
    _loadReqId++;
    _loadMoreReqId++;
    _isLoadingSync = false;
    _isLoadingMoreSync = false;
  }

  /// Filter q berubah (dari search box halaman list). Debounce 400 ms →
  /// reset + fetch halaman pertama dengan q baru (server-side). q kosong
  /// di mode Sambas → kembali full A-Z tanpa menunggu debounce.
  void onQueryChanged(String q) {
    final nextEmpty = q.trim().isEmpty;
    final alreadyIdleEmpty =
        nextEmpty &&
        state.q.trim().isEmpty &&
        !state.isLoading &&
        !_isLoadingSync &&
        state.items.isEmpty &&
        state.errorMessage == null;

    // Remount FTextField / echo onChange('') setelah empty load selesai
    // tidak boleh memicu refetch (bisa bikin skeleton + race).
    if (alreadyIdleEmpty) {
      if (q != state.q) state = state.copyWith(q: q);
      return;
    }

    state = state.copyWith(q: q, clearErrorMessage: true);
    if (nextEmpty) {
      _debounce?.cancel();
      if (state.searchIn == 'translation') {
        _dropInFlight();
        state = state.copyWith(
          items: const [],
          clearNextCursor: true,
          hasMore: false,
          isLoading: false,
          isLoadingMore: false,
          viaSearch: false,
        );
        return;
      }
      state = state.copyWith(
        items: const [],
        clearNextCursor: true,
        hasMore: false,
      );
      scheduleMicrotask(load);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: _kDebounceMs), load);
  }

  /// Filter kategori berubah (#50). Reset + fetch halaman pertama.
  void onCategoryChanged(String? category) {
    if (category == state.category) return;
    _debounce?.cancel();
    _dropInFlight();
    state = state.copyWith(
      category: category,
      items: const [],
      clearNextCursor: true,
      hasMore: false,
      isLoading: true,
      viaSearch: false,
      clearErrorMessage: true,
    );
    scheduleMicrotask(load);
  }

  /// Sambas (`lemma`) atau Indonesia (`translation`).
  void onSearchInChanged(String searchIn) {
    if (searchIn == state.searchIn) return;
    _debounce?.cancel();
    _dropInFlight();
    final idleTranslation = searchIn == 'translation' && state.q.trim().isEmpty;
    state = state.copyWith(
      searchIn: searchIn,
      items: const [],
      clearNextCursor: true,
      hasMore: false,
      viaSearch: false,
      isLoading: !idleTranslation,
      isLoadingMore: false,
      clearErrorMessage: true,
    );
    if (idleTranslation) return;
    scheduleMicrotask(load);
  }

  /// Halaman berikutnya (infinite scroll: `maxScrollExtent - 200`).
  Future<void> loadMore() async {
    if (_isLoadingMoreSync ||
        _isLoadingSync ||
        !ref.mounted ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasMore ||
        state.nextCursor == null) {
      return;
    }
    _isLoadingMoreSync = true;
    final reqId = ++_loadMoreReqId;
    final useSearch = state.searchIn == 'translation' || state.viaSearch;

    state = state.copyWith(isLoadingMore: true, clearErrorMessage: true);

    try {
      final result = useSearch
          ? await ref.read(searchWordsUseCaseProvider)(
              SearchWordsParams(
                query: state.q,
                cursor: state.nextCursor,
                searchIn: state.searchIn,
              ),
            )
          : await ref.read(listWordsUseCaseProvider)(
              ListWordsParams(q: state.q, cursor: state.nextCursor, category: state.category),
            );

      if (!ref.mounted || reqId != _loadMoreReqId) return;

      result.match(
        (failure) => state = state.copyWith(
          isLoadingMore: false,
          errorMessage: failure.message,
        ),
        (page) {
          final merged = [...state.items, ...page.items];
          state = state.copyWith(
            isLoadingMore: false,
            items: merged,
            nextCursor: page.nextCursor,
            clearNextCursor: page.nextCursor == null,
            hasMore: page.hasMore,
          );
        },
      );
    } catch (e) {
      if (ref.mounted && reqId == _loadMoreReqId) {
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: e.toString(),
        );
      }
    } finally {
      if (reqId == _loadMoreReqId) {
        _isLoadingMoreSync = false;
      }
    }
  }

  void _applyPage(WordSearchPage page, {required bool viaSearch}) {
    state = state.copyWith(
      isLoading: false,
      isLoadingMore: false,
      items: page.items,
      nextCursor: page.nextCursor,
      clearNextCursor: page.nextCursor == null,
      hasMore: page.hasMore,
      viaSearch: viaSearch,
    );
    if (viaSearch && state.q.trim().isNotEmpty) {
      AnalyticsService.instance.logSearchSubmit(
        queryLen: state.q.trim().length,
        searchIn: state.searchIn,
        hasResults: page.items.isNotEmpty,
      );
      // Riwayat hanya untuk query bermakna (bukan browse A-Z) dan ada
      // hasilnya - menyimpan query tanpa hasil menumpuk riwayat dengan
      // ketikan yang salah.
      if (page.items.isNotEmpty) {
        unawaited(ref.read(searchHistoryControllerProvider.notifier).record(
              state.q,
            ));
      }
    }
  }

  /// Halaman pertama (buka halaman / q berubah / pull-to-refresh).
  Future<void> load() async {
    if (_isLoadingSync || !ref.mounted) return;
    _isLoadingSync = true;
    final reqId = ++_loadReqId;
    _loadMoreReqId++;
    _isLoadingMoreSync = false;

    final q = state.q;
    final searchIn = state.searchIn;

    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      clearErrorMessage: true,
    );

    try {
      if (searchIn == 'translation' && q.trim().isEmpty) {
        if (!ref.mounted || reqId != _loadReqId) return;
        state = state.copyWith(
          isLoading: false,
          items: const [],
          clearNextCursor: true,
          hasMore: false,
          viaSearch: false,
        );
        return;
      }

      if (searchIn == 'translation') {
        final result = await ref.read(searchWordsUseCaseProvider)(
          SearchWordsParams(query: q, searchIn: 'translation'),
        );
        if (!ref.mounted || reqId != _loadReqId) return;
        result.match(
          (failure) => state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
          (page) => _applyPage(page, viaSearch: true),
        );
        return;
      }

      final listed = await ref.read(listWordsUseCaseProvider)(
        ListWordsParams(q: q, category: state.category),
      );
      if (!ref.mounted || reqId != _loadReqId) return;

      DictionaryFailure? failure;
      WordSearchPage? page;
      listed.match((error) => failure = error, (value) => page = value);
      final error = failure;
      if (error != null) {
        state = state.copyWith(isLoading: false, errorMessage: error.message);
        return;
      }

      final found = page;
      if (found == null) return;
      // Saringan Sambas kosong + q cukup panjang: coba pencarian lemma
      // (variasi penulisan + rekam search-miss bila tetap kosong).
      if (found.items.isEmpty && q.trim().length >= 2) {
        final searched = await ref.read(searchWordsUseCaseProvider)(
          SearchWordsParams(query: q, searchIn: 'lemma'),
        );
        if (!ref.mounted || reqId != _loadReqId) return;
        searched.match(
          (_) => _applyPage(found, viaSearch: false),
          (hits) => _applyPage(hits, viaSearch: true),
        );
        return;
      }

      _applyPage(found, viaSearch: false);
    } catch (e) {
      if (ref.mounted && reqId == _loadReqId) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    } finally {
      if (reqId == _loadReqId) {
        _isLoadingSync = false;
      }
    }
  }
}
