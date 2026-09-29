// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_miss_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(searchMissRemoteDatasource)
final searchMissRemoteDatasourceProvider =
    SearchMissRemoteDatasourceProvider._();

final class SearchMissRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          SearchMissRemoteDatasource,
          SearchMissRemoteDatasource,
          SearchMissRemoteDatasource
        >
    with $Provider<SearchMissRemoteDatasource> {
  SearchMissRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchMissRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchMissRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<SearchMissRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchMissRemoteDatasource create(Ref ref) {
    return searchMissRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchMissRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchMissRemoteDatasource>(value),
    );
  }
}

String _$searchMissRemoteDatasourceHash() =>
    r'9ee225d5a94bba82b5f1337c438c0e4f403a020a';

@ProviderFor(searchMissRepository)
final searchMissRepositoryProvider = SearchMissRepositoryProvider._();

final class SearchMissRepositoryProvider
    extends
        $FunctionalProvider<
          SearchMissRepository,
          SearchMissRepository,
          SearchMissRepository
        >
    with $Provider<SearchMissRepository> {
  SearchMissRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchMissRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchMissRepositoryHash();

  @$internal
  @override
  $ProviderElement<SearchMissRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SearchMissRepository create(Ref ref) {
    return searchMissRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchMissRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchMissRepository>(value),
    );
  }
}

String _$searchMissRepositoryHash() =>
    r'93f5b8b3bec16d56b291fdebd869f8516b35049c';
