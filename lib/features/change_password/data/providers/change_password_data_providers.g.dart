// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(changePasswordRemoteDatasource)
final changePasswordRemoteDatasourceProvider =
    ChangePasswordRemoteDatasourceProvider._();

final class ChangePasswordRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          ChangePasswordRemoteDatasource,
          ChangePasswordRemoteDatasource,
          ChangePasswordRemoteDatasource
        >
    with $Provider<ChangePasswordRemoteDatasource> {
  ChangePasswordRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<ChangePasswordRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangePasswordRemoteDatasource create(Ref ref) {
    return changePasswordRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePasswordRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePasswordRemoteDatasource>(
        value,
      ),
    );
  }
}

String _$changePasswordRemoteDatasourceHash() =>
    r'5e7bcda6ec5127151db317587b99c19d047c881d';

@ProviderFor(changePasswordRepository)
final changePasswordRepositoryProvider = ChangePasswordRepositoryProvider._();

final class ChangePasswordRepositoryProvider
    extends
        $FunctionalProvider<
          ChangePasswordRepository,
          ChangePasswordRepository,
          ChangePasswordRepository
        >
    with $Provider<ChangePasswordRepository> {
  ChangePasswordRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'changePasswordRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$changePasswordRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChangePasswordRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChangePasswordRepository create(Ref ref) {
    return changePasswordRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChangePasswordRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChangePasswordRepository>(value),
    );
  }
}

String _$changePasswordRepositoryHash() =>
    r'a67850238514245f82cd4908a3aa306fdc66adf8';
