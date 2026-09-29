// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getMyProfileUseCase)
final getMyProfileUseCaseProvider = GetMyProfileUseCaseProvider._();

final class GetMyProfileUseCaseProvider
    extends
        $FunctionalProvider<
          GetMyProfileUseCase,
          GetMyProfileUseCase,
          GetMyProfileUseCase
        >
    with $Provider<GetMyProfileUseCase> {
  GetMyProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMyProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMyProfileUseCase create(Ref ref) {
    return getMyProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyProfileUseCase>(value),
    );
  }
}

String _$getMyProfileUseCaseHash() =>
    r'5d786fd96c16abca0cf34b775376e4b7aa587e63';

@ProviderFor(updateMyProfileUseCase)
final updateMyProfileUseCaseProvider = UpdateMyProfileUseCaseProvider._();

final class UpdateMyProfileUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateMyProfileUseCase,
          UpdateMyProfileUseCase,
          UpdateMyProfileUseCase
        >
    with $Provider<UpdateMyProfileUseCase> {
  UpdateMyProfileUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateMyProfileUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateMyProfileUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateMyProfileUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateMyProfileUseCase create(Ref ref) {
    return updateMyProfileUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateMyProfileUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateMyProfileUseCase>(value),
    );
  }
}

String _$updateMyProfileUseCaseHash() =>
    r'843a7de0b4892a7effb66a7a84ce0e80d6a99aa8';
