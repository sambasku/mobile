// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_verify_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthVerifyNotifier)
final authVerifyProvider = AuthVerifyNotifierProvider._();

final class AuthVerifyNotifierProvider
    extends $NotifierProvider<AuthVerifyNotifier, AuthVerifyState> {
  AuthVerifyNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authVerifyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authVerifyNotifierHash();

  @$internal
  @override
  AuthVerifyNotifier create() => AuthVerifyNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthVerifyState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthVerifyState>(value),
    );
  }
}

String _$authVerifyNotifierHash() =>
    r'2c2380c63c45b127a24225d8befcde2e1f08e9ad';

abstract class _$AuthVerifyNotifier extends $Notifier<AuthVerifyState> {
  AuthVerifyState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthVerifyState, AuthVerifyState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthVerifyState, AuthVerifyState>,
              AuthVerifyState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
