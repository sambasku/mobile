// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_images_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cardImagesRemoteDatasource)
final cardImagesRemoteDatasourceProvider =
    CardImagesRemoteDatasourceProvider._();

final class CardImagesRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          CardImagesRemoteDatasource,
          CardImagesRemoteDatasource,
          CardImagesRemoteDatasource
        >
    with $Provider<CardImagesRemoteDatasource> {
  CardImagesRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardImagesRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardImagesRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<CardImagesRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CardImagesRemoteDatasource create(Ref ref) {
    return cardImagesRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardImagesRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardImagesRemoteDatasource>(value),
    );
  }
}

String _$cardImagesRemoteDatasourceHash() =>
    r'310e796592ce87fb5d98093cdf11adad115917d1';

@ProviderFor(cardImagesRepository)
final cardImagesRepositoryProvider = CardImagesRepositoryProvider._();

final class CardImagesRepositoryProvider
    extends
        $FunctionalProvider<
          CardImagesRepository,
          CardImagesRepository,
          CardImagesRepository
        >
    with $Provider<CardImagesRepository> {
  CardImagesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardImagesRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardImagesRepositoryHash();

  @$internal
  @override
  $ProviderElement<CardImagesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CardImagesRepository create(Ref ref) {
    return cardImagesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CardImagesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CardImagesRepository>(value),
    );
  }
}

String _$cardImagesRepositoryHash() =>
    r'aa3188701f9aa6994efbdece1bd738d9df0c0c40';

/// Config card dari CDN. Null = offline/JSON rusak → pakai asset bundled.
/// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.

@ProviderFor(cardImages)
final cardImagesProvider = CardImagesProvider._();

/// Config card dari CDN. Null = offline/JSON rusak → pakai asset bundled.
/// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.

final class CardImagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<CardImagesConfig?>,
          CardImagesConfig?,
          FutureOr<CardImagesConfig?>
        >
    with
        $FutureModifier<CardImagesConfig?>,
        $FutureProvider<CardImagesConfig?> {
  /// Config card dari CDN. Null = offline/JSON rusak → pakai asset bundled.
  /// referenceStatic: fresh 24 jam + SWR, update terlihat ≤24 jam.
  CardImagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cardImagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cardImagesHash();

  @$internal
  @override
  $FutureProviderElement<CardImagesConfig?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CardImagesConfig?> create(Ref ref) {
    return cardImages(ref);
  }
}

String _$cardImagesHash() => r'92c0fceefe30039c1b3e7146c684d7996432d9d5';
