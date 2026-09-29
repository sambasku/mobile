// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cache_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(responseCacheStore)
final responseCacheStoreProvider = ResponseCacheStoreProvider._();

final class ResponseCacheStoreProvider
    extends
        $FunctionalProvider<
          ResponseCacheStore,
          ResponseCacheStore,
          ResponseCacheStore
        >
    with $Provider<ResponseCacheStore> {
  ResponseCacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'responseCacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$responseCacheStoreHash();

  @$internal
  @override
  $ProviderElement<ResponseCacheStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResponseCacheStore create(Ref ref) {
    return responseCacheStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResponseCacheStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResponseCacheStore>(value),
    );
  }
}

String _$responseCacheStoreHash() =>
    r'0c560dff72abc8dfd2ba385f652060134a7cf574';

@ProviderFor(cachedJsonClient)
final cachedJsonClientProvider = CachedJsonClientProvider._();

final class CachedJsonClientProvider
    extends
        $FunctionalProvider<
          CachedJsonClient,
          CachedJsonClient,
          CachedJsonClient
        >
    with $Provider<CachedJsonClient> {
  CachedJsonClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cachedJsonClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cachedJsonClientHash();

  @$internal
  @override
  $ProviderElement<CachedJsonClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CachedJsonClient create(Ref ref) {
    return cachedJsonClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CachedJsonClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CachedJsonClient>(value),
    );
  }
}

String _$cachedJsonClientHash() => r'553b2e15e383233325445656d0b2758c0d0ff048';
