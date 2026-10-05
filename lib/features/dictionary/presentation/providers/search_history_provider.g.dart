// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riwayat pencarian kata: maksimal 10 query terakhir, tersimpan lokal di
/// SharedPreferences (tidak dikirim ke server). Dedup case-insensitive,
/// query sama digeser ke atas. [preload] wajib dipanggil di main sebelum
/// runApp supaya frame pertama sudah membawa riwayat tersimpan.

@ProviderFor(SearchHistoryController)
final searchHistoryControllerProvider = SearchHistoryControllerProvider._();

/// Riwayat pencarian kata: maksimal 10 query terakhir, tersimpan lokal di
/// SharedPreferences (tidak dikirim ke server). Dedup case-insensitive,
/// query sama digeser ke atas. [preload] wajib dipanggil di main sebelum
/// runApp supaya frame pertama sudah membawa riwayat tersimpan.
final class SearchHistoryControllerProvider
    extends $NotifierProvider<SearchHistoryController, List<String>> {
  /// Riwayat pencarian kata: maksimal 10 query terakhir, tersimpan lokal di
  /// SharedPreferences (tidak dikirim ke server). Dedup case-insensitive,
  /// query sama digeser ke atas. [preload] wajib dipanggil di main sebelum
  /// runApp supaya frame pertama sudah membawa riwayat tersimpan.
  SearchHistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryControllerHash();

  @$internal
  @override
  SearchHistoryController create() => SearchHistoryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$searchHistoryControllerHash() =>
    r'e4e7207f6d87057a898f043d04c4bc2d09d2b74a';

/// Riwayat pencarian kata: maksimal 10 query terakhir, tersimpan lokal di
/// SharedPreferences (tidak dikirim ke server). Dedup case-insensitive,
/// query sama digeser ke atas. [preload] wajib dipanggil di main sebelum
/// runApp supaya frame pertama sudah membawa riwayat tersimpan.

abstract class _$SearchHistoryController extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
