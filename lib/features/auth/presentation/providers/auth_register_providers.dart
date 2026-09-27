import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/register_use_case.dart';
import '../models/auth_register_state.dart';
import 'auth_status_providers.dart';

part 'auth_register_providers.g.dart';

@riverpod
class AuthRegisterNotifier extends _$AuthRegisterNotifier {
  var _inFlight = false;

  @override
  AuthRegisterState build() => const AuthRegisterState();

  Future<void> submit({
    required String name,
    required String email,
    String? phoneNationalDigits,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  }) async {
    if (_inFlight) return;
    _inFlight = true;
    state = state.copyWith(
      pendingAction: AuthPendingAction.email,
      clearErrorMessage: true,
      clearErrorCode: true,
      success: false,
      clearPendingEmail: true,
      clearSession: true,
    );

    final registerResult = await ref
        .read(authRegisterUseCaseProvider)
        .call(
          RegisterParams(
            name: name,
            email: email,
            phoneNationalDigits: phoneNationalDigits,
            password: password,
            confirmPassword: confirmPassword,
            consents: consents,
          ),
        );

    registerResult.match(
      (failure) {
        state = state.copyWith(
          clearPendingAction: true,
          errorMessage: failure.message,
          errorCode: failure.errorCode,
          success: false,
        );
      },
      (_) {
        state = state.copyWith(
          clearPendingAction: true,
          success: true,
          pendingEmail: email.trim(),
        );
        AnalyticsService.instance.logAuthSuccess(
          event: AnalyticsEvents.authRegisterSuccess,
          method: 'email',
        );
      },
    );
    _inFlight = false;
  }

  Future<void> submitGoogle() async {
    if (_inFlight) return;
    _inFlight = true;
    state = state.copyWith(
      pendingAction: AuthPendingAction.google,
      clearErrorMessage: true,
      clearErrorCode: true,
      success: false,
      clearSession: true,
    );

    final result = await ref.read(authLoginWithGoogleUseCaseProvider).call();
    result.match(
      (failure) => _applyGoogleFailure(failure),
      (session) => _applySocialSession(session, method: 'google'),
    );
    _inFlight = false;
  }

  Future<void> submitFacebook() async {
    if (_inFlight) return;
    _inFlight = true;
    state = state.copyWith(
      pendingAction: AuthPendingAction.facebook,
      clearErrorMessage: true,
      clearErrorCode: true,
      success: false,
      clearSession: true,
    );

    final result = await ref.read(authLoginWithFacebookUseCaseProvider).call();
    result.match(
      (failure) => _applyFacebookFailure(failure),
      (session) => _applySocialSession(session, method: 'facebook'),
    );
    _inFlight = false;
  }

  Future<void> submitGithub() async {
    if (_inFlight) return;
    _inFlight = true;
    state = state.copyWith(
      pendingAction: AuthPendingAction.github,
      clearErrorMessage: true,
      clearErrorCode: true,
      success: false,
      clearSession: true,
    );

    final result = await ref.read(authLoginWithGithubUseCaseProvider).call();
    result.match(
      (failure) => _applyGithubFailure(failure),
      (session) => _applySocialSession(session, method: 'github'),
    );
    _inFlight = false;
  }

  void _applyGoogleFailure(AuthFailure failure) {
    if (failure.isSocialSignInCanceled) {
      state = state.copyWith(
        clearPendingAction: true,
        errorCode: failure.errorCode,
        clearErrorMessage: true,
        success: false,
      );
      return;
    }
    final hide = failure.errorCode == 'GOOGLE_AUTH_UNAVAILABLE';
    state = state.copyWith(
      clearPendingAction: true,
      errorMessage: failure.message,
      errorCode: failure.errorCode,
      googleUnavailable: hide || state.googleUnavailable,
      success: false,
    );
  }

  void _applyFacebookFailure(AuthFailure failure) {
    if (failure.isSocialSignInCanceled) {
      state = state.copyWith(
        clearPendingAction: true,
        errorCode: failure.errorCode,
        clearErrorMessage: true,
        success: false,
      );
      return;
    }
    final hide = failure.errorCode == 'FACEBOOK_AUTH_UNAVAILABLE';
    state = state.copyWith(
      clearPendingAction: true,
      errorMessage: hide ? null : failure.message,
      errorCode: failure.errorCode,
      facebookUnavailable: hide || state.facebookUnavailable,
      success: false,
    );
  }

  void _applyGithubFailure(AuthFailure failure) {
    if (failure.isSocialSignInCanceled) {
      state = state.copyWith(
        clearPendingAction: true,
        errorCode: failure.errorCode,
        clearErrorMessage: true,
        success: false,
      );
      return;
    }
    final hide = failure.errorCode == 'GITHUB_AUTH_UNAVAILABLE';
    state = state.copyWith(
      clearPendingAction: true,
      errorMessage: hide ? null : failure.message,
      errorCode: failure.errorCode,
      githubUnavailable: hide || state.githubUnavailable,
      success: false,
    );
  }

  void _applySocialSession(AuthSession session, {required String method}) {
    ref.read(authStatusProvider.notifier).markLoggedIn(session);
    state = state.copyWith(clearPendingAction: true, session: session);
    AnalyticsService.instance.logAuthSuccess(
      event: AnalyticsEvents.authRegisterSuccess,
      method: method,
    );
  }

  /// Dipakai UI setelah navigasi ke OTP supaya daftar berikutnya
  /// tidak memicu pendingEmail / success lama.
  void acknowledgeSuccess() {
    state = state.copyWith(success: false);
  }

  void acknowledgeSocialCancel() {
    state = state.copyWith(clearErrorCode: true, clearErrorMessage: true);
  }
}
