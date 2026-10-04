// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuisine_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cuisineRemoteDatasource)
final cuisineRemoteDatasourceProvider = CuisineRemoteDatasourceProvider._();

final class CuisineRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          CuisineRemoteDatasource,
          CuisineRemoteDatasource,
          CuisineRemoteDatasource
        >
    with $Provider<CuisineRemoteDatasource> {
  CuisineRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cuisineRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cuisineRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<CuisineRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CuisineRemoteDatasource create(Ref ref) {
    return cuisineRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CuisineRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CuisineRemoteDatasource>(value),
    );
  }
}

String _$cuisineRemoteDatasourceHash() =>
    r'e182132d301f31f5bdf66915b9910c702f7f0044';

@ProviderFor(cuisineRepository)
final cuisineRepositoryProvider = CuisineRepositoryProvider._();

final class CuisineRepositoryProvider
    extends
        $FunctionalProvider<
          CuisineRepositoryImpl,
          CuisineRepositoryImpl,
          CuisineRepositoryImpl
        >
    with $Provider<CuisineRepositoryImpl> {
  CuisineRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cuisineRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cuisineRepositoryHash();

  @$internal
  @override
  $ProviderElement<CuisineRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CuisineRepositoryImpl create(Ref ref) {
    return cuisineRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CuisineRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CuisineRepositoryImpl>(value),
    );
  }
}

String _$cuisineRepositoryHash() => r'643b05dc9e5e8e9ba15f8abeb52e828e9b4b6212';

/// Katalog cuisine dari CDN. Null = offline/JSON rusak (soft-fail).
/// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.

@ProviderFor(cuisine)
final cuisineProvider = CuisineProvider._();

/// Katalog cuisine dari CDN. Null = offline/JSON rusak (soft-fail).
/// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.

final class CuisineProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Cuisine>?>,
          List<Cuisine>?,
          FutureOr<List<Cuisine>?>
        >
    with $FutureModifier<List<Cuisine>?>, $FutureProvider<List<Cuisine>?> {
  /// Katalog cuisine dari CDN. Null = offline/JSON rusak (soft-fail).
  /// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.
  CuisineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cuisineProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cuisineHash();

  @$internal
  @override
  $FutureProviderElement<List<Cuisine>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Cuisine>?> create(Ref ref) {
    return cuisine(ref);
  }
}

String _$cuisineHash() => r'b308e36c3158198cf38911ac8b0f81cc5530e749';

/// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.

@ProviderFor(cuisineRefresh)
final cuisineRefreshProvider = CuisineRefreshProvider._();

/// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.

final class CuisineRefreshProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Cuisine>?>,
          List<Cuisine>?,
          FutureOr<List<Cuisine>?>
        >
    with $FutureModifier<List<Cuisine>?>, $FutureProvider<List<Cuisine>?> {
  /// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.
  CuisineRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cuisineRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cuisineRefreshHash();

  @$internal
  @override
  $FutureProviderElement<List<Cuisine>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Cuisine>?> create(Ref ref) {
    return cuisineRefresh(ref);
  }
}

String _$cuisineRefreshHash() => r'92cbd3ba421f6409bd31199d63bc7c4e92e8982a';
