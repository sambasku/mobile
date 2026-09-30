import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/word_summary.dart';
import '../../domain/providers/dictionary_domain_providers.dart';
import '../../domain/usecases/search_words_use_case.dart';

part 'word_complete_providers.g.dart';

/// State pemilih kata untuk entri "Lengkapi kata" di Area Verifikator.
///
/// Auto-dispose: state ikut hilang saat halaman ditutup, jadi kembali ke
/// hub tidak menyisakan query/hasil yang basi.
@Riverpod(keepAlive: false)
class WordCompleteNotifier extends _$WordCompleteNotifier {
  /// Sama dengan halaman detail kata supaya tidak terasa "lambat".
  static const _debounceMs = 400;

  static const _limit = 20;

  /// Di bawah ini hasil SEARCH membanjir dan tidak berguna.
  static const _minQueryLength = 2;

  Timer? _debounce;

  /// Generasi query. Naik setiap perubahan q sehingga jawaban request lama
  /// (yang masih di udara) tidak boleh menimpa state yang lebih baru.
  int _generation = 0;

  @override
  WordCompleteState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _debounce = null;
    });
    return const WordCompleteState();
  }

  /// q berubah dari search box. Kosong / terlalu pendek = idle, jangan
  /// fetch: supaya tidak ada request sia-sia saat user baru mulai mengetik.
  void onQueryChanged(String q) {
    _generation++;
    _debounce?.cancel();

    final trimmed = q.trim();
    state = state.copyWith(q: q, items: const [], clearErrorMessage: true);

    if (trimmed.length < _minQueryLength) {
      state = state.copyWith(isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);
    _debounce = Timer(
      const Duration(milliseconds: _debounceMs),
      () => _search(trimmed),
    );
  }

  Future<void> _search(String q) async {
    final generation = _generation;
    try {
      final result = await ref.read(searchWordsUseCaseProvider)(
        SearchWordsParams(query: q, limit: _limit, searchIn: 'lemma'),
      );
      if (!ref.mounted || generation != _generation) return;
      result.match(
        (failure) => state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        ),
        (page) => state = state.copyWith(
          isLoading: false,
          items: page.items,
        ),
      );
    } catch (e) {
      if (!ref.mounted || generation != _generation) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

class WordCompleteState {
  const WordCompleteState({
    this.q = '',
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final String q;
  final List<WordSummary> items;
  final bool isLoading;
  final String? errorMessage;

  /// Belum cukup karakter untuk mencari - tampilkan petunjuk, bukan kosong.
  bool get isSearching => q.trim().length >= 2;

  WordCompleteState copyWith({
    String? q,
    List<WordSummary>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return WordCompleteState(
      q: q ?? this.q,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
