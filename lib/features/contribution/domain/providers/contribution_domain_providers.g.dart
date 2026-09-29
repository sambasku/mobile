// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(submitAnonWordUseCase)
final submitAnonWordUseCaseProvider = SubmitAnonWordUseCaseProvider._();

final class SubmitAnonWordUseCaseProvider
    extends
        $FunctionalProvider<
          SubmitAnonWordUseCase,
          SubmitAnonWordUseCase,
          SubmitAnonWordUseCase
        >
    with $Provider<SubmitAnonWordUseCase> {
  SubmitAnonWordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'submitAnonWordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$submitAnonWordUseCaseHash();

  @$internal
  @override
  $ProviderElement<SubmitAnonWordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubmitAnonWordUseCase create(Ref ref) {
    return submitAnonWordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubmitAnonWordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubmitAnonWordUseCase>(value),
    );
  }
}

String _$submitAnonWordUseCaseHash() =>
    r'7d1bce70756c3a008985ada2c439c160e85115ff';
