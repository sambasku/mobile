import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/providers/auth_data_providers.dart';
import '../usecases/forgot_password_use_case.dart';
import '../usecases/login_use_case.dart';
import '../usecases/login_with_facebook_use_case.dart';
import '../usecases/login_with_github_use_case.dart';
import '../usecases/login_with_google_use_case.dart';
import '../usecases/logout_use_case.dart';
import '../usecases/register_use_case.dart';
import '../usecases/reset_password_use_case.dart';
import '../usecases/verify_email_use_case.dart';

part 'auth_domain_providers.g.dart';

@riverpod
RegisterUseCase authRegisterUseCase(Ref ref) =>
    RegisterUseCase(ref.watch(authRepositoryProvider));

@riverpod
LoginUseCase authLoginUseCase(Ref ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));

@riverpod
LoginWithGoogleUseCase authLoginWithGoogleUseCase(Ref ref) =>
    LoginWithGoogleUseCase(
      ref.watch(authRepositoryProvider),
      ref.watch(googleSignInPortProvider),
    );

@riverpod
LoginWithFacebookUseCase authLoginWithFacebookUseCase(Ref ref) =>
    LoginWithFacebookUseCase(
      ref.watch(authRepositoryProvider),
      ref.watch(facebookSignInPortProvider),
    );

@riverpod
LoginWithGithubUseCase authLoginWithGithubUseCase(Ref ref) =>
    LoginWithGithubUseCase(
      ref.watch(authRepositoryProvider),
      ref.watch(githubSignInPortProvider),
    );

@riverpod
LogoutUseCase authLogoutUseCase(Ref ref) =>
    LogoutUseCase(ref.watch(authRepositoryProvider));

@riverpod
VerifyEmailUseCase authVerifyEmailUseCase(Ref ref) =>
    VerifyEmailUseCase(ref.watch(authRepositoryProvider));

@riverpod
ResendOtpUseCase authResendOtpUseCase(Ref ref) =>
    ResendOtpUseCase(ref.watch(authRepositoryProvider));

@riverpod
ForgotPasswordUseCase authForgotPasswordUseCase(Ref ref) =>
    ForgotPasswordUseCase(ref.watch(authRepositoryProvider));

@riverpod
ResetPasswordUseCase authResetPasswordUseCase(Ref ref) =>
    ResetPasswordUseCase(ref.watch(authRepositoryProvider));
