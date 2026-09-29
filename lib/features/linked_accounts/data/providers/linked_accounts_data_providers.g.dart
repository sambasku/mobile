// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linked_accounts_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkedAccountsRemoteDatasource)
final linkedAccountsRemoteDatasourceProvider =
    LinkedAccountsRemoteDatasourceProvider._();

final class LinkedAccountsRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          LinkedAccountsRemoteDatasource,
          LinkedAccountsRemoteDatasource,
          LinkedAccountsRemoteDatasource
        >
    with $Provider<LinkedAccountsRemoteDatasource> {
  LinkedAccountsRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkedAccountsRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkedAccountsRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<LinkedAccountsRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LinkedAccountsRemoteDatasource create(Ref ref) {
    return linkedAccountsRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkedAccountsRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkedAccountsRemoteDatasource>(
        value,
      ),
    );
  }
}

String _$linkedAccountsRemoteDatasourceHash() =>
    r'454f2a66e6fb8c209c508e8bd10ce2ffabbbf424';

@ProviderFor(linkedAccountsRepository)
final linkedAccountsRepositoryProvider = LinkedAccountsRepositoryProvider._();

final class LinkedAccountsRepositoryProvider
    extends
        $FunctionalProvider<
          LinkedAccountsRepository,
          LinkedAccountsRepository,
          LinkedAccountsRepository
        >
    with $Provider<LinkedAccountsRepository> {
  LinkedAccountsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkedAccountsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkedAccountsRepositoryHash();

  @$internal
  @override
  $ProviderElement<LinkedAccountsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LinkedAccountsRepository create(Ref ref) {
    return linkedAccountsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkedAccountsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkedAccountsRepository>(value),
    );
  }
}

String _$linkedAccountsRepositoryHash() =>
    r'64d8d6c6d898be5a5ad70be21fed0ab27a36ef82';
