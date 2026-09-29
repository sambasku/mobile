// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_list_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(WordListNotifier)
final wordListProvider = WordListNotifierProvider._();

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
final class WordListNotifierProvider
    extends $NotifierProvider<WordListNotifier, WordListState> {
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
  WordListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wordListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wordListNotifierHash();

  @$internal
  @override
  WordListNotifier create() => WordListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WordListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WordListState>(value),
    );
  }
}

String _$wordListNotifierHash() => r'12acfcf93f475372cf4855c5206b83ad25d3e0b1';

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

abstract class _$WordListNotifier extends $Notifier<WordListState> {
  WordListState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WordListState, WordListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WordListState, WordListState>,
              WordListState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
