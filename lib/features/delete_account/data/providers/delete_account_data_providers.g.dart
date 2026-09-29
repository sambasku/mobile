// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deleteAccountRemoteDatasource)
final deleteAccountRemoteDatasourceProvider =
    DeleteAccountRemoteDatasourceProvider._();

final class DeleteAccountRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          DeleteAccountRemoteDatasource,
          DeleteAccountRemoteDatasource,
          DeleteAccountRemoteDatasource
        >
    with $Provider<DeleteAccountRemoteDatasource> {
  DeleteAccountRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<DeleteAccountRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteAccountRemoteDatasource create(Ref ref) {
    return deleteAccountRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteAccountRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteAccountRemoteDatasource>(
        value,
      ),
    );
  }
}

String _$deleteAccountRemoteDatasourceHash() =>
    r'4b77de0a4c4ceec8024c03723c5f28466fe1035d';

@ProviderFor(deleteAccountRepository)
final deleteAccountRepositoryProvider = DeleteAccountRepositoryProvider._();

final class DeleteAccountRepositoryProvider
    extends
        $FunctionalProvider<
          DeleteAccountRepository,
          DeleteAccountRepository,
          DeleteAccountRepository
        >
    with $Provider<DeleteAccountRepository> {
  DeleteAccountRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeleteAccountRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteAccountRepository create(Ref ref) {
    return deleteAccountRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteAccountRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteAccountRepository>(value),
    );
  }
}

String _$deleteAccountRepositoryHash() =>
    r'f450067e912b35e96f3f419598042d319b7381fb';
