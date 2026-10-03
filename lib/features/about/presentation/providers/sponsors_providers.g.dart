// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sponsors_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sponsorsRemoteDatasource)
final sponsorsRemoteDatasourceProvider = SponsorsRemoteDatasourceProvider._();

final class SponsorsRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          SponsorsRemoteDatasource,
          SponsorsRemoteDatasource,
          SponsorsRemoteDatasource
        >
    with $Provider<SponsorsRemoteDatasource> {
  SponsorsRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sponsorsRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sponsorsRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<SponsorsRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SponsorsRemoteDatasource create(Ref ref) {
    return sponsorsRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SponsorsRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SponsorsRemoteDatasource>(value),
    );
  }
}

String _$sponsorsRemoteDatasourceHash() =>
    r'ba41fc93cfff52c6c144b0796cb1cf623ab541a3';

/// Data sponsor dari CDN. Null = offline/JSON rusak → sembunyikan section.
/// Data statis jarang berubah; tanpa cache khusus (YAGNI, list kecil).

@ProviderFor(sponsors)
final sponsorsProvider = SponsorsProvider._();

/// Data sponsor dari CDN. Null = offline/JSON rusak → sembunyikan section.
/// Data statis jarang berubah; tanpa cache khusus (YAGNI, list kecil).

final class SponsorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SponsorEntry>?>,
          List<SponsorEntry>?,
          FutureOr<List<SponsorEntry>?>
        >
    with
        $FutureModifier<List<SponsorEntry>?>,
        $FutureProvider<List<SponsorEntry>?> {
  /// Data sponsor dari CDN. Null = offline/JSON rusak → sembunyikan section.
  /// Data statis jarang berubah; tanpa cache khusus (YAGNI, list kecil).
  SponsorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sponsorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sponsorsHash();

  @$internal
  @override
  $FutureProviderElement<List<SponsorEntry>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SponsorEntry>?> create(Ref ref) {
    return sponsors(ref);
  }
}

String _$sponsorsHash() => r'2126af824148cd288f775533bc5d81642cd193c9';
