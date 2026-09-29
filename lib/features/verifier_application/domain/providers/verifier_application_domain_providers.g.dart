// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verifier_application_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getMyVerifierApplicationUseCase)
final getMyVerifierApplicationUseCaseProvider =
    GetMyVerifierApplicationUseCaseProvider._();

final class GetMyVerifierApplicationUseCaseProvider
    extends
        $FunctionalProvider<
          GetMyVerifierApplicationUseCase,
          GetMyVerifierApplicationUseCase,
          GetMyVerifierApplicationUseCase
        >
    with $Provider<GetMyVerifierApplicationUseCase> {
  GetMyVerifierApplicationUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyVerifierApplicationUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyVerifierApplicationUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMyVerifierApplicationUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMyVerifierApplicationUseCase create(Ref ref) {
    return getMyVerifierApplicationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyVerifierApplicationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyVerifierApplicationUseCase>(
        value,
      ),
    );
  }
}

String _$getMyVerifierApplicationUseCaseHash() =>
    r'4be5737c4cb6771ef6313b14cd2643c2d129e70e';

@ProviderFor(submitVerifierApplicationUseCase)
final submitVerifierApplicationUseCaseProvider =
    SubmitVerifierApplicationUseCaseProvider._();

final class SubmitVerifierApplicationUseCaseProvider
    extends
        $FunctionalProvider<
          SubmitVerifierApplicationUseCase,
          SubmitVerifierApplicationUseCase,
          SubmitVerifierApplicationUseCase
        >
    with $Provider<SubmitVerifierApplicationUseCase> {
  SubmitVerifierApplicationUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'submitVerifierApplicationUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$submitVerifierApplicationUseCaseHash();

  @$internal
  @override
  $ProviderElement<SubmitVerifierApplicationUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubmitVerifierApplicationUseCase create(Ref ref) {
    return submitVerifierApplicationUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubmitVerifierApplicationUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubmitVerifierApplicationUseCase>(
        value,
      ),
    );
  }
}

String _$submitVerifierApplicationUseCaseHash() =>
    r'f272c241fe4c3135491b159d5909b9be58d1f137';
