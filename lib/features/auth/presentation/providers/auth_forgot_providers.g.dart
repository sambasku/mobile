// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_forgot_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthForgotNotifier)
final authForgotProvider = AuthForgotNotifierProvider._();

final class AuthForgotNotifierProvider
    extends $NotifierProvider<AuthForgotNotifier, AuthForgotState> {
  AuthForgotNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authForgotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authForgotNotifierHash();

  @$internal
  @override
  AuthForgotNotifier create() => AuthForgotNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthForgotState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthForgotState>(value),
    );
  }
}

String _$authForgotNotifierHash() =>
    r'97ee302968564fcd38bc22fc9193dce086f271ae';

abstract class _$AuthForgotNotifier extends $Notifier<AuthForgotState> {
  AuthForgotState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthForgotState, AuthForgotState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthForgotState, AuthForgotState>,
              AuthForgotState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
