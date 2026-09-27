// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_register_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthRegisterNotifier)
final authRegisterProvider = AuthRegisterNotifierProvider._();

final class AuthRegisterNotifierProvider
    extends $NotifierProvider<AuthRegisterNotifier, AuthRegisterState> {
  AuthRegisterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRegisterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRegisterNotifierHash();

  @$internal
  @override
  AuthRegisterNotifier create() => AuthRegisterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRegisterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRegisterState>(value),
    );
  }
}

String _$authRegisterNotifierHash() =>
    r'8680130cbe74c4bdf449a8228b09d62d566fd72f';

abstract class _$AuthRegisterNotifier extends $Notifier<AuthRegisterState> {
  AuthRegisterState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthRegisterState, AuthRegisterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthRegisterState, AuthRegisterState>,
              AuthRegisterState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
