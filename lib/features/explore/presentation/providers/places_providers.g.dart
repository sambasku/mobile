// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'places_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(placesRemoteDatasource)
final placesRemoteDatasourceProvider = PlacesRemoteDatasourceProvider._();

final class PlacesRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          PlacesRemoteDatasource,
          PlacesRemoteDatasource,
          PlacesRemoteDatasource
        >
    with $Provider<PlacesRemoteDatasource> {
  PlacesRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placesRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placesRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<PlacesRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlacesRemoteDatasource create(Ref ref) {
    return placesRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlacesRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlacesRemoteDatasource>(value),
    );
  }
}

String _$placesRemoteDatasourceHash() =>
    r'734fa7a41bd21a9b5d208b9efa90632a861bf961';

@ProviderFor(placesRepository)
final placesRepositoryProvider = PlacesRepositoryProvider._();

final class PlacesRepositoryProvider
    extends
        $FunctionalProvider<
          PlacesRepositoryImpl,
          PlacesRepositoryImpl,
          PlacesRepositoryImpl
        >
    with $Provider<PlacesRepositoryImpl> {
  PlacesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placesRepositoryHash();

  @$internal
  @override
  $ProviderElement<PlacesRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PlacesRepositoryImpl create(Ref ref) {
    return placesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PlacesRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PlacesRepositoryImpl>(value),
    );
  }
}

String _$placesRepositoryHash() => r'468b5b979d330e87c5691e457fa08d22197d0909';

/// Katalog Place dari CDN. Null = offline/JSON rusak (soft-fail).
/// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.

@ProviderFor(places)
final placesProvider = PlacesProvider._();

/// Katalog Place dari CDN. Null = offline/JSON rusak (soft-fail).
/// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.

final class PlacesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Place>?>,
          List<Place>?,
          FutureOr<List<Place>?>
        >
    with $FutureModifier<List<Place>?>, $FutureProvider<List<Place>?> {
  /// Katalog Place dari CDN. Null = offline/JSON rusak (soft-fail).
  /// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.
  PlacesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placesHash();

  @$internal
  @override
  $FutureProviderElement<List<Place>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Place>?> create(Ref ref) {
    return places(ref);
  }
}

String _$placesHash() => r'8ff83332e29d223e02b3083ddb1bda5c08db34e2';

/// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.

@ProviderFor(placesRefresh)
final placesRefreshProvider = PlacesRefreshProvider._();

/// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.

final class PlacesRefreshProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Place>?>,
          List<Place>?,
          FutureOr<List<Place>?>
        >
    with $FutureModifier<List<Place>?>, $FutureProvider<List<Place>?> {
  /// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.
  PlacesRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placesRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placesRefreshHash();

  @$internal
  @override
  $FutureProviderElement<List<Place>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Place>?> create(Ref ref) {
    return placesRefresh(ref);
  }
}

String _$placesRefreshHash() => r'40869561f9485afa51d403e5b090bb6c5be558d7';
