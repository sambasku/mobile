// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latest_words_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Feed beranda. Halaman pertama dimuat sejak build. keepAlive supaya
/// pindah tab tidak mengulang unduhan dari nol.
///
/// early-return (stale / !mounted) tidak boleh meninggalkan isLoading
/// tanpa request yang masih jalan.

@ProviderFor(LatestWordsNotifier)
final latestWordsProvider = LatestWordsNotifierProvider._();

/// Feed beranda. Halaman pertama dimuat sejak build. keepAlive supaya
/// pindah tab tidak mengulang unduhan dari nol.
///
/// early-return (stale / !mounted) tidak boleh meninggalkan isLoading
/// tanpa request yang masih jalan.
final class LatestWordsNotifierProvider
    extends $NotifierProvider<LatestWordsNotifier, LatestWordsState> {
  /// Feed beranda. Halaman pertama dimuat sejak build. keepAlive supaya
  /// pindah tab tidak mengulang unduhan dari nol.
  ///
  /// early-return (stale / !mounted) tidak boleh meninggalkan isLoading
  /// tanpa request yang masih jalan.
  LatestWordsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestWordsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestWordsNotifierHash();

  @$internal
  @override
  LatestWordsNotifier create() => LatestWordsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LatestWordsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LatestWordsState>(value),
    );
  }
}

String _$latestWordsNotifierHash() =>
    r'f348df56ce675329ca18913028850920397d3ab2';

/// Feed beranda. Halaman pertama dimuat sejak build. keepAlive supaya
/// pindah tab tidak mengulang unduhan dari nol.
///
/// early-return (stale / !mounted) tidak boleh meninggalkan isLoading
/// tanpa request yang masih jalan.

abstract class _$LatestWordsNotifier extends $Notifier<LatestWordsState> {
  LatestWordsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LatestWordsState, LatestWordsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LatestWordsState, LatestWordsState>,
              LatestWordsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
