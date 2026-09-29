// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(registerDeviceUseCase)
final registerDeviceUseCaseProvider = RegisterDeviceUseCaseProvider._();

final class RegisterDeviceUseCaseProvider
    extends
        $FunctionalProvider<
          RegisterDeviceUseCase,
          RegisterDeviceUseCase,
          RegisterDeviceUseCase
        >
    with $Provider<RegisterDeviceUseCase> {
  RegisterDeviceUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerDeviceUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerDeviceUseCaseHash();

  @$internal
  @override
  $ProviderElement<RegisterDeviceUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RegisterDeviceUseCase create(Ref ref) {
    return registerDeviceUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterDeviceUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterDeviceUseCase>(value),
    );
  }
}

String _$registerDeviceUseCaseHash() =>
    r'159fd79a4359cabc9addb145e1abfc7d2555dd6e';

@ProviderFor(revokeDeviceUseCase)
final revokeDeviceUseCaseProvider = RevokeDeviceUseCaseProvider._();

final class RevokeDeviceUseCaseProvider
    extends
        $FunctionalProvider<
          RevokeDeviceUseCase,
          RevokeDeviceUseCase,
          RevokeDeviceUseCase
        >
    with $Provider<RevokeDeviceUseCase> {
  RevokeDeviceUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'revokeDeviceUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$revokeDeviceUseCaseHash();

  @$internal
  @override
  $ProviderElement<RevokeDeviceUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RevokeDeviceUseCase create(Ref ref) {
    return revokeDeviceUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RevokeDeviceUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RevokeDeviceUseCase>(value),
    );
  }
}

String _$revokeDeviceUseCaseHash() =>
    r'5147837bcd3181f0438237bff3a7c3872dfcf244';
