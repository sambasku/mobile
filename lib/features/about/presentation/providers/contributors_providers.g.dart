// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contributors_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contributorsRemoteDatasource)
final contributorsRemoteDatasourceProvider =
    ContributorsRemoteDatasourceProvider._();

final class ContributorsRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          ContributorsRemoteDatasource,
          ContributorsRemoteDatasource,
          ContributorsRemoteDatasource
        >
    with $Provider<ContributorsRemoteDatasource> {
  ContributorsRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributorsRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributorsRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<ContributorsRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContributorsRemoteDatasource create(Ref ref) {
    return contributorsRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContributorsRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContributorsRemoteDatasource>(value),
    );
  }
}

String _$contributorsRemoteDatasourceHash() =>
    r'bba34b3b0d41243cc5de674ce0de9699784870a5';

/// Data kontributor dari CDN. Null = offline/JSON rusak → sembunyikan
/// section. Data statis jarang berubah; tanpa cache khusus (YAGNI, list
/// kecil).

@ProviderFor(contributors)
final contributorsProvider = ContributorsProvider._();

/// Data kontributor dari CDN. Null = offline/JSON rusak → sembunyikan
/// section. Data statis jarang berubah; tanpa cache khusus (YAGNI, list
/// kecil).

final class ContributorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ContributorEntry>?>,
          List<ContributorEntry>?,
          FutureOr<List<ContributorEntry>?>
        >
    with
        $FutureModifier<List<ContributorEntry>?>,
        $FutureProvider<List<ContributorEntry>?> {
  /// Data kontributor dari CDN. Null = offline/JSON rusak → sembunyikan
  /// section. Data statis jarang berubah; tanpa cache khusus (YAGNI, list
  /// kecil).
  ContributorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributorsHash();

  @$internal
  @override
  $FutureProviderElement<List<ContributorEntry>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ContributorEntry>?> create(Ref ref) {
    return contributors(ref);
  }
}

String _$contributorsHash() => r'6c64a87c6ac3ada5e6c1764cf0c3ee93f86f2b29';

/// Map id → username untuk lookup kredit internal (penulis artikel/foto).
/// Null = offline/JSON rusak. Lookup lokal, tanpa fetch tambahan.

@ProviderFor(contributorsIdToUsername)
final contributorsIdToUsernameProvider = ContributorsIdToUsernameProvider._();

/// Map id → username untuk lookup kredit internal (penulis artikel/foto).
/// Null = offline/JSON rusak. Lookup lokal, tanpa fetch tambahan.

final class ContributorsIdToUsernameProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>?>,
          Map<String, String>?,
          FutureOr<Map<String, String>?>
        >
    with
        $FutureModifier<Map<String, String>?>,
        $FutureProvider<Map<String, String>?> {
  /// Map id → username untuk lookup kredit internal (penulis artikel/foto).
  /// Null = offline/JSON rusak. Lookup lokal, tanpa fetch tambahan.
  ContributorsIdToUsernameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contributorsIdToUsernameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contributorsIdToUsernameHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, String>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, String>?> create(Ref ref) {
    return contributorsIdToUsername(ref);
  }
}

String _$contributorsIdToUsernameHash() =>
    r'9004f427d1ec53df6be47c2cd34073b7e05fcda7';
