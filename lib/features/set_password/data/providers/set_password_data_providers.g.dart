// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_password_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(setPasswordRemoteDatasource)
final setPasswordRemoteDatasourceProvider =
    SetPasswordRemoteDatasourceProvider._();

final class SetPasswordRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          SetPasswordRemoteDatasource,
          SetPasswordRemoteDatasource,
          SetPasswordRemoteDatasource
        >
    with $Provider<SetPasswordRemoteDatasource> {
  SetPasswordRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setPasswordRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setPasswordRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<SetPasswordRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetPasswordRemoteDatasource create(Ref ref) {
    return setPasswordRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetPasswordRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetPasswordRemoteDatasource>(value),
    );
  }
}

String _$setPasswordRemoteDatasourceHash() =>
    r'ecec29cd012043e88f276de9c2f74cc7c0d0e393';

@ProviderFor(setPasswordRepository)
final setPasswordRepositoryProvider = SetPasswordRepositoryProvider._();

final class SetPasswordRepositoryProvider
    extends
        $FunctionalProvider<
          SetPasswordRepository,
          SetPasswordRepository,
          SetPasswordRepository
        >
    with $Provider<SetPasswordRepository> {
  SetPasswordRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setPasswordRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setPasswordRepositoryHash();

  @$internal
  @override
  $ProviderElement<SetPasswordRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetPasswordRepository create(Ref ref) {
    return setPasswordRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetPasswordRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetPasswordRepository>(value),
    );
  }
}

String _$setPasswordRepositoryHash() =>
    r'd04b33ebd10e37352da13fde1735a3b18ba0469f';
