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

String _$cuisineRepositoryHash() => r'9b14634a1c9892f6853059b8f2eec1ab011f87b9';

/// Katalog kuliner dari API. Null = offline/error (soft-fail) supaya UI
/// menampilkan tombol coba lagi, bukan crash.

@ProviderFor(cuisine)
final cuisineProvider = CuisineProvider._();

/// Katalog kuliner dari API. Null = offline/error (soft-fail) supaya UI
/// menampilkan tombol coba lagi, bukan crash.

final class CuisineProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Cuisine>?>,
          List<Cuisine>?,
          FutureOr<List<Cuisine>?>
        >
    with $FutureModifier<List<Cuisine>?>, $FutureProvider<List<Cuisine>?> {
  /// Katalog kuliner dari API. Null = offline/error (soft-fail) supaya UI
  /// menampilkan tombol coba lagi, bukan crash.
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

String _$cuisineHash() => r'673178f44b72f647de6ce6ef0794b6ce46bd1034';

/// Pull-to-refresh / tombol muat ulang: fetch ulang penuh dari API.

@ProviderFor(cuisineRefresh)
final cuisineRefreshProvider = CuisineRefreshProvider._();

/// Pull-to-refresh / tombol muat ulang: fetch ulang penuh dari API.

final class CuisineRefreshProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Cuisine>?>,
          List<Cuisine>?,
          FutureOr<List<Cuisine>?>
        >
    with $FutureModifier<List<Cuisine>?>, $FutureProvider<List<Cuisine>?> {
  /// Pull-to-refresh / tombol muat ulang: fetch ulang penuh dari API.
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

String _$cuisineRefreshHash() => r'411cb4584aac5052ce2035aee830a8efc712a16b';

/// Detail satu kuliner by slug + daftar tempat penyedia.

@ProviderFor(cuisineBySlug)
final cuisineBySlugProvider = CuisineBySlugFamily._();

/// Detail satu kuliner by slug + daftar tempat penyedia.

final class CuisineBySlugProvider
    extends
        $FunctionalProvider<
          AsyncValue<CuisineDtoItem?>,
          CuisineDtoItem?,
          FutureOr<CuisineDtoItem?>
        >
    with $FutureModifier<CuisineDtoItem?>, $FutureProvider<CuisineDtoItem?> {
  /// Detail satu kuliner by slug + daftar tempat penyedia.
  CuisineBySlugProvider._({
    required CuisineBySlugFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'cuisineBySlugProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cuisineBySlugHash();

  @override
  String toString() {
    return r'cuisineBySlugProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CuisineDtoItem?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CuisineDtoItem?> create(Ref ref) {
    final argument = this.argument as String;
    return cuisineBySlug(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CuisineBySlugProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cuisineBySlugHash() => r'266614f06119b54b69b02318616d6aa06ba1bd36';

/// Detail satu kuliner by slug + daftar tempat penyedia.

final class CuisineBySlugFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CuisineDtoItem?>, String> {
  CuisineBySlugFamily._()
    : super(
        retry: null,
        name: r'cuisineBySlugProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Detail satu kuliner by slug + daftar tempat penyedia.

  CuisineBySlugProvider call(String slug) =>
      CuisineBySlugProvider._(argument: slug, from: this);

  @override
  String toString() => r'cuisineBySlugProvider';
}

@ProviderFor(culinaryContributionApi)
final culinaryContributionApiProvider = CulinaryContributionApiProvider._();

final class CulinaryContributionApiProvider
    extends
        $FunctionalProvider<
          CulinaryContributionApi,
          CulinaryContributionApi,
          CulinaryContributionApi
        >
    with $Provider<CulinaryContributionApi> {
  CulinaryContributionApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'culinaryContributionApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$culinaryContributionApiHash();

  @$internal
  @override
  $ProviderElement<CulinaryContributionApi> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CulinaryContributionApi create(Ref ref) {
    return culinaryContributionApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CulinaryContributionApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CulinaryContributionApi>(value),
    );
  }
}

String _$culinaryContributionApiHash() =>
    r'16d4c964917d533ab4764d3acb5b9fbb8dc864dd';

/// Daftar tempat/penjual kuliner (halaman pertama). Null = gagal (soft-fail).

@ProviderFor(culinaryPlaces)
final culinaryPlacesProvider = CulinaryPlacesFamily._();

/// Daftar tempat/penjual kuliner (halaman pertama). Null = gagal (soft-fail).

final class CulinaryPlacesProvider
    extends
        $FunctionalProvider<
          AsyncValue<CulinaryPlacePage?>,
          CulinaryPlacePage?,
          FutureOr<CulinaryPlacePage?>
        >
    with
        $FutureModifier<CulinaryPlacePage?>,
        $FutureProvider<CulinaryPlacePage?> {
  /// Daftar tempat/penjual kuliner (halaman pertama). Null = gagal (soft-fail).
  CulinaryPlacesProvider._({
    required CulinaryPlacesFamily super.from,
    required ({String? q, String? type}) super.argument,
  }) : super(
         retry: null,
         name: r'culinaryPlacesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$culinaryPlacesHash();

  @override
  String toString() {
    return r'culinaryPlacesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CulinaryPlacePage?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CulinaryPlacePage?> create(Ref ref) {
    final argument = this.argument as ({String? q, String? type});
    return culinaryPlaces(ref, q: argument.q, type: argument.type);
  }

  @override
  bool operator ==(Object other) {
    return other is CulinaryPlacesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$culinaryPlacesHash() => r'5cd7397862bee7c2a0a73a73f61fa1c386383aff';

/// Daftar tempat/penjual kuliner (halaman pertama). Null = gagal (soft-fail).

final class CulinaryPlacesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CulinaryPlacePage?>,
          ({String? q, String? type})
        > {
  CulinaryPlacesFamily._()
    : super(
        retry: null,
        name: r'culinaryPlacesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Daftar tempat/penjual kuliner (halaman pertama). Null = gagal (soft-fail).

  CulinaryPlacesProvider call({String? q, String? type}) =>
      CulinaryPlacesProvider._(argument: (q: q, type: type), from: this);

  @override
  String toString() => r'culinaryPlacesProvider';
}
