// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_data_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRemoteDatasource)
final authRemoteDatasourceProvider = AuthRemoteDatasourceProvider._();

final class AuthRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          AuthRemoteDatasource,
          AuthRemoteDatasource,
          AuthRemoteDatasource
        >
    with $Provider<AuthRemoteDatasource> {
  AuthRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<AuthRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthRemoteDatasource create(Ref ref) {
    return authRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRemoteDatasource>(value),
    );
  }
}

String _$authRemoteDatasourceHash() =>
    r'e80921f39c874ab92eaaf9d0cd60ba9b05766e88';

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'2d9a92cf8fc43906536da28a7af0347a09eb97af';

@ProviderFor(googleSignInPort)
final googleSignInPortProvider = GoogleSignInPortProvider._();

final class GoogleSignInPortProvider
    extends
        $FunctionalProvider<
          GoogleSignInPort,
          GoogleSignInPort,
          GoogleSignInPort
        >
    with $Provider<GoogleSignInPort> {
  GoogleSignInPortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleSignInPortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleSignInPortHash();

  @$internal
  @override
  $ProviderElement<GoogleSignInPort> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoogleSignInPort create(Ref ref) {
    return googleSignInPort(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleSignInPort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleSignInPort>(value),
    );
  }
}

String _$googleSignInPortHash() => r'7b5425b027be288b5752dae18083430321dc370b';

@ProviderFor(facebookSignInPort)
final facebookSignInPortProvider = FacebookSignInPortProvider._();

final class FacebookSignInPortProvider
    extends
        $FunctionalProvider<
          FacebookSignInPort,
          FacebookSignInPort,
          FacebookSignInPort
        >
    with $Provider<FacebookSignInPort> {
  FacebookSignInPortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facebookSignInPortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facebookSignInPortHash();

  @$internal
  @override
  $ProviderElement<FacebookSignInPort> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FacebookSignInPort create(Ref ref) {
    return facebookSignInPort(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FacebookSignInPort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FacebookSignInPort>(value),
    );
  }
}

String _$facebookSignInPortHash() =>
    r'd3bffc4af7c66e3b6dd0c06d288f66c1cb76bb68';

@ProviderFor(githubSignInPort)
final githubSignInPortProvider = GithubSignInPortProvider._();

final class GithubSignInPortProvider
    extends
        $FunctionalProvider<
          GithubSignInPort,
          GithubSignInPort,
          GithubSignInPort
        >
    with $Provider<GithubSignInPort> {
  GithubSignInPortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'githubSignInPortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$githubSignInPortHash();

  @$internal
  @override
  $ProviderElement<GithubSignInPort> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GithubSignInPort create(Ref ref) {
    return githubSignInPort(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GithubSignInPort value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GithubSignInPort>(value),
    );
  }
}

String _$githubSignInPortHash() => r'509497a6bf073386b702f482b994104ffe086db0';
