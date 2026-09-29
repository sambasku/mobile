// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verifier_application_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(verifierApplicationRemoteDatasource)
final verifierApplicationRemoteDatasourceProvider =
    VerifierApplicationRemoteDatasourceProvider._();

final class VerifierApplicationRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          VerifierApplicationRemoteDatasource,
          VerifierApplicationRemoteDatasource,
          VerifierApplicationRemoteDatasource
        >
    with $Provider<VerifierApplicationRemoteDatasource> {
  VerifierApplicationRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifierApplicationRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$verifierApplicationRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<VerifierApplicationRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerifierApplicationRemoteDatasource create(Ref ref) {
    return verifierApplicationRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifierApplicationRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifierApplicationRemoteDatasource>(
        value,
      ),
    );
  }
}

String _$verifierApplicationRemoteDatasourceHash() =>
    r'23e2ef9275578c772cc4c34e796cdbdbfff1d1af';

@ProviderFor(verifierApplicationRepository)
final verifierApplicationRepositoryProvider =
    VerifierApplicationRepositoryProvider._();

final class VerifierApplicationRepositoryProvider
    extends
        $FunctionalProvider<
          VerifierApplicationRepository,
          VerifierApplicationRepository,
          VerifierApplicationRepository
        >
    with $Provider<VerifierApplicationRepository> {
  VerifierApplicationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifierApplicationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifierApplicationRepositoryHash();

  @$internal
  @override
  $ProviderElement<VerifierApplicationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerifierApplicationRepository create(Ref ref) {
    return verifierApplicationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifierApplicationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifierApplicationRepository>(
        value,
      ),
    );
  }
}

String _$verifierApplicationRepositoryHash() =>
    r'5398fce4387982863a6c1175cd33a0d3ae2eaa5c';
