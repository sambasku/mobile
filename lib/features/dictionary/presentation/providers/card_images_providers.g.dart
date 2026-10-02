// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_images_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Config card dari CDN. Null = fetch gagal / JSON rusak → pakai asset.
/// CacheClass.referenceStatic: fresh 24 jam + SWR — perubahan config
/// terlihat paling lambat ±24 jam, tanpa traffic worker.

@ProviderFor(cardImages)
final cardImagesProvider = CardImagesProvider._();

/// Config card dari CDN. Null = fetch gagal / JSON rusak → pakai asset.
/// CacheClass.referenceStatic: fresh 24 jam + SWR — perubahan config
/// terlihat paling lambat ±24 jam, tanpa traffic worker.

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
  /// Config card dari CDN. Null = fetch gagal / JSON rusak → pakai asset.
  /// CacheClass.referenceStatic: fresh 24 jam + SWR — perubahan config
  /// terlihat paling lambat ±24 jam, tanpa traffic worker.
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

String _$cardImagesHash() => r'c93b5ab6dd8e05814716849c0db17e734ae0b3e2';
