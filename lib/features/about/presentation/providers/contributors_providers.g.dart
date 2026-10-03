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

String _$contributorsHash() => r'4e00f3bf11d371a89ff60ce2bd6e6939a796116d';
