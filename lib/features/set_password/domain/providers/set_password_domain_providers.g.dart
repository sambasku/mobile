// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_password_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(setPasswordUseCase)
final setPasswordUseCaseProvider = SetPasswordUseCaseProvider._();

final class SetPasswordUseCaseProvider
    extends
        $FunctionalProvider<
          SetPasswordUseCase,
          SetPasswordUseCase,
          SetPasswordUseCase
        >
    with $Provider<SetPasswordUseCase> {
  SetPasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setPasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetPasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetPasswordUseCase create(Ref ref) {
    return setPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetPasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetPasswordUseCase>(value),
    );
  }
}

String _$setPasswordUseCaseHash() =>
    r'd4d7390860b5dee3144646e239bf51788b1cc819';
