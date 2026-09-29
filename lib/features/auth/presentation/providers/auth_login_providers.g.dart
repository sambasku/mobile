// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(googleAuthEnabled)
final googleAuthEnabledProvider = GoogleAuthEnabledProvider._();

final class GoogleAuthEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  GoogleAuthEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleAuthEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleAuthEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return googleAuthEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$googleAuthEnabledHash() => r'09bb77939c4ab51794a94ac34ecfb26479bb80b4';

/// Sementara dimatikan di semua flavor (staging + production).
/// Nyalakan lagi: `=> isFacebookAuthConfigured();`

@ProviderFor(facebookAuthEnabled)
final facebookAuthEnabledProvider = FacebookAuthEnabledProvider._();

/// Sementara dimatikan di semua flavor (staging + production).
/// Nyalakan lagi: `=> isFacebookAuthConfigured();`

final class FacebookAuthEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Sementara dimatikan di semua flavor (staging + production).
  /// Nyalakan lagi: `=> isFacebookAuthConfigured();`
  FacebookAuthEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facebookAuthEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facebookAuthEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return facebookAuthEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$facebookAuthEnabledHash() =>
    r'424948d76984687d69736c98a75d6c8af3fad0bb';

/// Sementara dimatikan di semua flavor (staging + production).
/// Nyalakan lagi: `=> isGithubAuthConfigured();`

@ProviderFor(githubAuthEnabled)
final githubAuthEnabledProvider = GithubAuthEnabledProvider._();

/// Sementara dimatikan di semua flavor (staging + production).
/// Nyalakan lagi: `=> isGithubAuthConfigured();`

final class GithubAuthEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Sementara dimatikan di semua flavor (staging + production).
  /// Nyalakan lagi: `=> isGithubAuthConfigured();`
  GithubAuthEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'githubAuthEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$githubAuthEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return githubAuthEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$githubAuthEnabledHash() => r'3da003f7c8332fcb55c79120ca0d9da8bbe3466b';

@ProviderFor(AuthLoginNotifier)
final authLoginProvider = AuthLoginNotifierProvider._();

final class AuthLoginNotifierProvider
    extends $NotifierProvider<AuthLoginNotifier, AuthLoginState> {
  AuthLoginNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLoginProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLoginNotifierHash();

  @$internal
  @override
  AuthLoginNotifier create() => AuthLoginNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthLoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthLoginState>(value),
    );
  }
}

String _$authLoginNotifierHash() => r'dd0cff97ce58f598be4fcdd17ed6481b67f92db8';

abstract class _$AuthLoginNotifier extends $Notifier<AuthLoginState> {
  AuthLoginState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthLoginState, AuthLoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthLoginState, AuthLoginState>,
              AuthLoginState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
