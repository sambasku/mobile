// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'regions_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(regionsRemoteDatasource)
final regionsRemoteDatasourceProvider = RegionsRemoteDatasourceProvider._();

final class RegionsRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          RegionsRemoteDatasource,
          RegionsRemoteDatasource,
          RegionsRemoteDatasource
        >
    with $Provider<RegionsRemoteDatasource> {
  RegionsRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'regionsRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$regionsRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<RegionsRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RegionsRemoteDatasource create(Ref ref) {
    return regionsRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegionsRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegionsRemoteDatasource>(value),
    );
  }
}

String _$regionsRemoteDatasourceHash() =>
    r'f239822779e928788e80f5aa9efa3ca4b8e7719e';

@ProviderFor(regionsRepository)
final regionsRepositoryProvider = RegionsRepositoryProvider._();

final class RegionsRepositoryProvider
    extends
        $FunctionalProvider<
          RegionsRepositoryImpl,
          RegionsRepositoryImpl,
          RegionsRepositoryImpl
        >
    with $Provider<RegionsRepositoryImpl> {
  RegionsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'regionsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$regionsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RegionsRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RegionsRepositoryImpl create(Ref ref) {
    return regionsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegionsRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegionsRepositoryImpl>(value),
    );
  }
}

String _$regionsRepositoryHash() => r'22522c43011b403cfe975760204dd2a7b8d5dd1b';

/// Katalog wilayah (19 kecamatan + desa) dari CDN.
/// Null = offline/JSON rusak (soft-fail). referenceStatic: fresh 24 jam + SWR.

@ProviderFor(regions)
final regionsProvider = RegionsProvider._();

/// Katalog wilayah (19 kecamatan + desa) dari CDN.
/// Null = offline/JSON rusak (soft-fail). referenceStatic: fresh 24 jam + SWR.

final class RegionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Region>?>,
          List<Region>?,
          FutureOr<List<Region>?>
        >
    with $FutureModifier<List<Region>?>, $FutureProvider<List<Region>?> {
  /// Katalog wilayah (19 kecamatan + desa) dari CDN.
  /// Null = offline/JSON rusak (soft-fail). referenceStatic: fresh 24 jam + SWR.
  RegionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'regionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$regionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Region>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Region>?> create(Ref ref) {
    return regions(ref);
  }
}

String _$regionsHash() => r'5b54b4e8810113ae1be5d74aa2f7858560bd599c';

/// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.

@ProviderFor(regionsRefresh)
final regionsRefreshProvider = RegionsRefreshProvider._();

/// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.

final class RegionsRefreshProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Region>?>,
          List<Region>?,
          FutureOr<List<Region>?>
        >
    with $FutureModifier<List<Region>?>, $FutureProvider<List<Region>?> {
  /// Pull-to-refresh / tombol muat ulang: hard miss L1 lalu tunggu fetch.
  RegionsRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'regionsRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$regionsRefreshHash();

  @$internal
  @override
  $FutureProviderElement<List<Region>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Region>?> create(Ref ref) {
    return regionsRefresh(ref);
  }
}

String _$regionsRefreshHash() => r'4422eaee61e9b45a65cd501917adf31fa3163978';

/// Hanya kecamatan (19) - untuk peta & panel.

@ProviderFor(regionsKecamatan)
final regionsKecamatanProvider = RegionsKecamatanProvider._();

/// Hanya kecamatan (19) - untuk peta & panel.

final class RegionsKecamatanProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Region>>,
          List<Region>,
          FutureOr<List<Region>>
        >
    with $FutureModifier<List<Region>>, $FutureProvider<List<Region>> {
  /// Hanya kecamatan (19) - untuk peta & panel.
  RegionsKecamatanProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'regionsKecamatanProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$regionsKecamatanHash();

  @$internal
  @override
  $FutureProviderElement<List<Region>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Region>> create(Ref ref) {
    return regionsKecamatan(ref);
  }
}

String _$regionsKecamatanHash() => r'd58d78dceaba0f197efcf093988c83949dedb93f';
