// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getPublicProfileUseCase)
final getPublicProfileUseCaseProvider = GetPublicProfileUseCaseProvider._();

final class GetPublicProfileUseCaseProvider
    extends
        $FunctionalProvider<
          GetPublicProfileUseCase,
          GetPublicProfileUseCase,
          GetPublicProfileUseCase
        >
    with $Provider<GetPublicProfileUseCase> {
  GetPublicProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPublicProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPublicProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPublicProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPublicProfileUseCase create(Ref ref) {
    return getPublicProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPublicProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPublicProfileUseCase>(value),
    );
  }
}

String _$getPublicProfileUseCaseHash() =>
    r'8d1e04cd81ef77795681dc2c7018aee76ad9dcf7';

@ProviderFor(getPublicActivityUseCase)
final getPublicActivityUseCaseProvider = GetPublicActivityUseCaseProvider._();

final class GetPublicActivityUseCaseProvider
    extends
        $FunctionalProvider<
          GetPublicActivityUseCase,
          GetPublicActivityUseCase,
          GetPublicActivityUseCase
        >
    with $Provider<GetPublicActivityUseCase> {
  GetPublicActivityUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPublicActivityUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPublicActivityUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPublicActivityUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPublicActivityUseCase create(Ref ref) {
    return getPublicActivityUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPublicActivityUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPublicActivityUseCase>(value),
    );
  }
}

String _$getPublicActivityUseCaseHash() =>
    r'6cbc5534238c40c21090a36382c39415c98c59c1';
