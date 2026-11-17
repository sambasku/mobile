// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lemma_dataset_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lemmaDatabaseOpener)
final lemmaDatabaseOpenerProvider = LemmaDatabaseOpenerProvider._();

final class LemmaDatabaseOpenerProvider
    extends
        $FunctionalProvider<
          LemmaDatabaseOpener,
          LemmaDatabaseOpener,
          LemmaDatabaseOpener
        >
    with $Provider<LemmaDatabaseOpener> {
  LemmaDatabaseOpenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lemmaDatabaseOpenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lemmaDatabaseOpenerHash();

  @$internal
  @override
  $ProviderElement<LemmaDatabaseOpener> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LemmaDatabaseOpener create(Ref ref) {
    return lemmaDatabaseOpener(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LemmaDatabaseOpener value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LemmaDatabaseOpener>(value),
    );
  }
}

String _$lemmaDatabaseOpenerHash() =>
    r'6ad56fbe41c55ce4e75f4a21bc8e4848fc9fc6c3';

@ProviderFor(lemmaStickyStore)
final lemmaStickyStoreProvider = LemmaStickyStoreProvider._();

final class LemmaStickyStoreProvider
    extends
        $FunctionalProvider<
          LemmaStickyStore,
          LemmaStickyStore,
          LemmaStickyStore
        >
    with $Provider<LemmaStickyStore> {
  LemmaStickyStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lemmaStickyStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lemmaStickyStoreHash();

  @$internal
  @override
  $ProviderElement<LemmaStickyStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LemmaStickyStore create(Ref ref) {
    return lemmaStickyStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LemmaStickyStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LemmaStickyStore>(value),
    );
  }
}

String _$lemmaStickyStoreHash() => r'0e40defbf129b47cb665ef5c0a8aba82855e0776';

/// Handle DB lokal. Null = belum siap / gagal open.

@ProviderFor(lemmaDatabaseHandle)
final lemmaDatabaseHandleProvider = LemmaDatabaseHandleProvider._();

/// Handle DB lokal. Null = belum siap / gagal open.

final class LemmaDatabaseHandleProvider
    extends
        $FunctionalProvider<
          AsyncValue<LemmaDatabaseHandle?>,
          LemmaDatabaseHandle?,
          FutureOr<LemmaDatabaseHandle?>
        >
    with
        $FutureModifier<LemmaDatabaseHandle?>,
        $FutureProvider<LemmaDatabaseHandle?> {
  /// Handle DB lokal. Null = belum siap / gagal open.
  LemmaDatabaseHandleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lemmaDatabaseHandleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lemmaDatabaseHandleHash();

  @$internal
  @override
  $FutureProviderElement<LemmaDatabaseHandle?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LemmaDatabaseHandle?> create(Ref ref) {
    return lemmaDatabaseHandle(ref);
  }
}

String _$lemmaDatabaseHandleHash() =>
    r'e9113e247217bfd5210737c7b022b368a2a7ff93';

@ProviderFor(dictionaryLocalDatasource)
final dictionaryLocalDatasourceProvider = DictionaryLocalDatasourceProvider._();

final class DictionaryLocalDatasourceProvider
    extends
        $FunctionalProvider<
          AsyncValue<DictionaryLocalDatasource?>,
          DictionaryLocalDatasource?,
          FutureOr<DictionaryLocalDatasource?>
        >
    with
        $FutureModifier<DictionaryLocalDatasource?>,
        $FutureProvider<DictionaryLocalDatasource?> {
  DictionaryLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dictionaryLocalDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dictionaryLocalDatasourceHash();

  @$internal
  @override
  $FutureProviderElement<DictionaryLocalDatasource?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DictionaryLocalDatasource?> create(Ref ref) {
    return dictionaryLocalDatasource(ref);
  }
}

String _$dictionaryLocalDatasourceHash() =>
    r'13f6049bf219cb5e2f88bcdcbce9c2034d7b8347';

@ProviderFor(LemmaDataSourceKindController)
final lemmaDataSourceKindControllerProvider =
    LemmaDataSourceKindControllerProvider._();

final class LemmaDataSourceKindControllerProvider
    extends
        $NotifierProvider<LemmaDataSourceKindController, LemmaDataSourceKind> {
  LemmaDataSourceKindControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lemmaDataSourceKindControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lemmaDataSourceKindControllerHash();

  @$internal
  @override
  LemmaDataSourceKindController create() => LemmaDataSourceKindController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LemmaDataSourceKind value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LemmaDataSourceKind>(value),
    );
  }
}

String _$lemmaDataSourceKindControllerHash() =>
    r'69d70ac850c68717829af85962f0da00a3f4cb80';

abstract class _$LemmaDataSourceKindController
    extends $Notifier<LemmaDataSourceKind> {
  LemmaDataSourceKind build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LemmaDataSourceKind, LemmaDataSourceKind>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LemmaDataSourceKind, LemmaDataSourceKind>,
              LemmaDataSourceKind,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(lemmaInstalledMeta)
final lemmaInstalledMetaProvider = LemmaInstalledMetaProvider._();

final class LemmaInstalledMetaProvider
    extends
        $FunctionalProvider<
          AsyncValue<LemmaReleaseMeta?>,
          LemmaReleaseMeta?,
          FutureOr<LemmaReleaseMeta?>
        >
    with
        $FutureModifier<LemmaReleaseMeta?>,
        $FutureProvider<LemmaReleaseMeta?> {
  LemmaInstalledMetaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lemmaInstalledMetaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lemmaInstalledMetaHash();

  @$internal
  @override
  $FutureProviderElement<LemmaReleaseMeta?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LemmaReleaseMeta?> create(Ref ref) {
    return lemmaInstalledMeta(ref);
  }
}

String _$lemmaInstalledMetaHash() =>
    r'f94df1500302aa365f94f35cc0cd14c108682b03';

@ProviderFor(lemmaDatasetUpdater)
final lemmaDatasetUpdaterProvider = LemmaDatasetUpdaterProvider._();

final class LemmaDatasetUpdaterProvider
    extends
        $FunctionalProvider<
          LemmaDatasetUpdater,
          LemmaDatasetUpdater,
          LemmaDatasetUpdater
        >
    with $Provider<LemmaDatasetUpdater> {
  LemmaDatasetUpdaterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lemmaDatasetUpdaterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lemmaDatasetUpdaterHash();

  @$internal
  @override
  $ProviderElement<LemmaDatasetUpdater> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LemmaDatasetUpdater create(Ref ref) {
    return lemmaDatasetUpdater(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LemmaDatasetUpdater value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LemmaDatasetUpdater>(value),
    );
  }
}

String _$lemmaDatasetUpdaterHash() =>
    r'a3b7bde452b544c560efda88d7b89732c816781c';
