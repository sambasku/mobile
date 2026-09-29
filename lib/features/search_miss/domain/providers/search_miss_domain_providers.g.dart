// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_miss_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listSearchMissesUseCase)
final listSearchMissesUseCaseProvider = ListSearchMissesUseCaseProvider._();

final class ListSearchMissesUseCaseProvider
    extends
        $FunctionalProvider<
          ListSearchMissesUseCase,
          ListSearchMissesUseCase,
          ListSearchMissesUseCase
        >
    with $Provider<ListSearchMissesUseCase> {
  ListSearchMissesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listSearchMissesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listSearchMissesUseCaseHash();

  @$internal
  @override
  $ProviderElement<ListSearchMissesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ListSearchMissesUseCase create(Ref ref) {
    return listSearchMissesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListSearchMissesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListSearchMissesUseCase>(value),
    );
  }
}

String _$listSearchMissesUseCaseHash() =>
    r'88aca6419df3221df3f4bf3f9750a52b08e3923a';
