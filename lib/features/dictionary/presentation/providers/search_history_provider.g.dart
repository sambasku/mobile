// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riwayat pencarian kata: maksimal 10 query terakhir, **hanya di memori
/// sesi** (issue mobile#296 - jangan simpan SharedPreferences / cache
/// disk). Dedup case-insensitive; query sama digeser ke atas.
///
/// [preload] membersihkan sisa key lama dari versi sebelumnya supaya
/// field/riwayat tidak "nyangkut" setelah update.

@ProviderFor(SearchHistoryController)
final searchHistoryControllerProvider = SearchHistoryControllerProvider._();

/// Riwayat pencarian kata: maksimal 10 query terakhir, **hanya di memori
/// sesi** (issue mobile#296 - jangan simpan SharedPreferences / cache
/// disk). Dedup case-insensitive; query sama digeser ke atas.
///
/// [preload] membersihkan sisa key lama dari versi sebelumnya supaya
/// field/riwayat tidak "nyangkut" setelah update.
final class SearchHistoryControllerProvider
    extends $NotifierProvider<SearchHistoryController, List<String>> {
  /// Riwayat pencarian kata: maksimal 10 query terakhir, **hanya di memori
  /// sesi** (issue mobile#296 - jangan simpan SharedPreferences / cache
  /// disk). Dedup case-insensitive; query sama digeser ke atas.
  ///
  /// [preload] membersihkan sisa key lama dari versi sebelumnya supaya
  /// field/riwayat tidak "nyangkut" setelah update.
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
    r'a6fd99a67f5922bf31898e6c73c1e14d8afcd464';

/// Riwayat pencarian kata: maksimal 10 query terakhir, **hanya di memori
/// sesi** (issue mobile#296 - jangan simpan SharedPreferences / cache
/// disk). Dedup case-insensitive; query sama digeser ke atas.
///
/// [preload] membersihkan sisa key lama dari versi sebelumnya supaya
/// field/riwayat tidak "nyangkut" setelah update.

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
