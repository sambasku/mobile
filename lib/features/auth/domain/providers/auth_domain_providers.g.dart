// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_domain_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRegisterUseCase)
final authRegisterUseCaseProvider = AuthRegisterUseCaseProvider._();

final class AuthRegisterUseCaseProvider
    extends
        $FunctionalProvider<RegisterUseCase, RegisterUseCase, RegisterUseCase>
    with $Provider<RegisterUseCase> {
  AuthRegisterUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRegisterUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRegisterUseCaseHash();

  @$internal
  @override
  $ProviderElement<RegisterUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RegisterUseCase create(Ref ref) {
    return authRegisterUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterUseCase>(value),
    );
  }
}

String _$authRegisterUseCaseHash() =>
    r'32cfda8f243636a8989266471fbb8a893bf41f10';

@ProviderFor(authLoginUseCase)
final authLoginUseCaseProvider = AuthLoginUseCaseProvider._();

final class AuthLoginUseCaseProvider
    extends $FunctionalProvider<LoginUseCase, LoginUseCase, LoginUseCase>
    with $Provider<LoginUseCase> {
  AuthLoginUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLoginUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLoginUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoginUseCase create(Ref ref) {
    return authLoginUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginUseCase>(value),
    );
  }
}

String _$authLoginUseCaseHash() => r'faf13acc1baa9a437b7425701739ba6f4e93b514';

@ProviderFor(authLoginWithGoogleUseCase)
final authLoginWithGoogleUseCaseProvider =
    AuthLoginWithGoogleUseCaseProvider._();

final class AuthLoginWithGoogleUseCaseProvider
    extends
        $FunctionalProvider<
          LoginWithGoogleUseCase,
          LoginWithGoogleUseCase,
          LoginWithGoogleUseCase
        >
    with $Provider<LoginWithGoogleUseCase> {
  AuthLoginWithGoogleUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLoginWithGoogleUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLoginWithGoogleUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginWithGoogleUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoginWithGoogleUseCase create(Ref ref) {
    return authLoginWithGoogleUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginWithGoogleUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginWithGoogleUseCase>(value),
    );
  }
}

String _$authLoginWithGoogleUseCaseHash() =>
    r'0a5d583b8a5877c4c01e6674d6fb25a2de95665f';

@ProviderFor(authLoginWithFacebookUseCase)
final authLoginWithFacebookUseCaseProvider =
    AuthLoginWithFacebookUseCaseProvider._();

final class AuthLoginWithFacebookUseCaseProvider
    extends
        $FunctionalProvider<
          LoginWithFacebookUseCase,
          LoginWithFacebookUseCase,
          LoginWithFacebookUseCase
        >
    with $Provider<LoginWithFacebookUseCase> {
  AuthLoginWithFacebookUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLoginWithFacebookUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLoginWithFacebookUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginWithFacebookUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoginWithFacebookUseCase create(Ref ref) {
    return authLoginWithFacebookUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginWithFacebookUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginWithFacebookUseCase>(value),
    );
  }
}

String _$authLoginWithFacebookUseCaseHash() =>
    r'9ca1a4fbb3b3a61aae1d5161a1cd76dca0be2ef3';

@ProviderFor(authLoginWithGithubUseCase)
final authLoginWithGithubUseCaseProvider =
    AuthLoginWithGithubUseCaseProvider._();

final class AuthLoginWithGithubUseCaseProvider
    extends
        $FunctionalProvider<
          LoginWithGithubUseCase,
          LoginWithGithubUseCase,
          LoginWithGithubUseCase
        >
    with $Provider<LoginWithGithubUseCase> {
  AuthLoginWithGithubUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLoginWithGithubUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLoginWithGithubUseCaseHash();

  @$internal
  @override
  $ProviderElement<LoginWithGithubUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LoginWithGithubUseCase create(Ref ref) {
    return authLoginWithGithubUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginWithGithubUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginWithGithubUseCase>(value),
    );
  }
}

String _$authLoginWithGithubUseCaseHash() =>
    r'd0c9befb8ab2aabac51cfc90e481942bdf5ceac0';

@ProviderFor(authLogoutUseCase)
final authLogoutUseCaseProvider = AuthLogoutUseCaseProvider._();

final class AuthLogoutUseCaseProvider
    extends $FunctionalProvider<LogoutUseCase, LogoutUseCase, LogoutUseCase>
    with $Provider<LogoutUseCase> {
  AuthLogoutUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authLogoutUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authLogoutUseCaseHash();

  @$internal
  @override
  $ProviderElement<LogoutUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LogoutUseCase create(Ref ref) {
    return authLogoutUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogoutUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogoutUseCase>(value),
    );
  }
}

String _$authLogoutUseCaseHash() => r'326bc6a4663aa077a2921607faf1102847348208';

@ProviderFor(authVerifyEmailUseCase)
final authVerifyEmailUseCaseProvider = AuthVerifyEmailUseCaseProvider._();

final class AuthVerifyEmailUseCaseProvider
    extends
        $FunctionalProvider<
          VerifyEmailUseCase,
          VerifyEmailUseCase,
          VerifyEmailUseCase
        >
    with $Provider<VerifyEmailUseCase> {
  AuthVerifyEmailUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authVerifyEmailUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authVerifyEmailUseCaseHash();

  @$internal
  @override
  $ProviderElement<VerifyEmailUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerifyEmailUseCase create(Ref ref) {
    return authVerifyEmailUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyEmailUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyEmailUseCase>(value),
    );
  }
}

String _$authVerifyEmailUseCaseHash() =>
    r'40bb3478ea2e38ae1990697e9cf0a8c6fc360580';

@ProviderFor(authResendOtpUseCase)
final authResendOtpUseCaseProvider = AuthResendOtpUseCaseProvider._();

final class AuthResendOtpUseCaseProvider
    extends
        $FunctionalProvider<
          ResendOtpUseCase,
          ResendOtpUseCase,
          ResendOtpUseCase
        >
    with $Provider<ResendOtpUseCase> {
  AuthResendOtpUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authResendOtpUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authResendOtpUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResendOtpUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ResendOtpUseCase create(Ref ref) {
    return authResendOtpUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResendOtpUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResendOtpUseCase>(value),
    );
  }
}

String _$authResendOtpUseCaseHash() =>
    r'025313802944f12d35bc454d788cf4b4d934b501';

@ProviderFor(authForgotPasswordUseCase)
final authForgotPasswordUseCaseProvider = AuthForgotPasswordUseCaseProvider._();

final class AuthForgotPasswordUseCaseProvider
    extends
        $FunctionalProvider<
          ForgotPasswordUseCase,
          ForgotPasswordUseCase,
          ForgotPasswordUseCase
        >
    with $Provider<ForgotPasswordUseCase> {
  AuthForgotPasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authForgotPasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authForgotPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ForgotPasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ForgotPasswordUseCase create(Ref ref) {
    return authForgotPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForgotPasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForgotPasswordUseCase>(value),
    );
  }
}

String _$authForgotPasswordUseCaseHash() =>
    r'836aacc177d88692ed0908b22c4942f3d25b4d25';

@ProviderFor(authResetPasswordUseCase)
final authResetPasswordUseCaseProvider = AuthResetPasswordUseCaseProvider._();

final class AuthResetPasswordUseCaseProvider
    extends
        $FunctionalProvider<
          ResetPasswordUseCase,
          ResetPasswordUseCase,
          ResetPasswordUseCase
        >
    with $Provider<ResetPasswordUseCase> {
  AuthResetPasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authResetPasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authResetPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResetPasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResetPasswordUseCase create(Ref ref) {
    return authResetPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetPasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetPasswordUseCase>(value),
    );
  }
}

String _$authResetPasswordUseCaseHash() =>
    r'a8d7195d60f1b7126b5d9a186fefc2bc16d4ee02';
