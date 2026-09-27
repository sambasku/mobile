import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/login_use_case.dart';
import '../models/auth_login_state.dart';
import 'auth_status_providers.dart';

part 'auth_login_providers.g.dart';

@riverpod
bool googleAuthEnabled(Ref ref) => isGoogleAuthConfigured();

/// Sementara dimatikan di semua flavor (staging + production).
/// Nyalakan lagi: `=> isFacebookAuthConfigured();`
@riverpod
bool facebookAuthEnabled(Ref ref) => false;

@riverpod
bool githubAuthEnabled(Ref ref) => isGithubAuthConfigured();

@riverpod
class AuthLoginNotifier extends _$AuthLoginNotifier {
  var _inFlight = false;

  @override
  AuthLoginState build() => const AuthLoginState();

  Future<void> submit({required String email, required String password}) async {
    if (_inFlight) return;
    _inFlight = true;
    state = state.copyWith(
      pendingAction: AuthPendingAction.email,
      clearErrorMessage: true,
      clearErrorCode: true,
      clearSession: true,
      showUnverifiedSheet: false,
    );

    final result = await ref
        .read(authLoginUseCaseProvider)
        .call(LoginParams(email: email, password: password));

    result.match(
      (failure) {
        if (failure.isEmailNotVerified) {
          state = state.copyWith(
            clearPendingAction: true,
            clearErrorMessage: true,
            clearErrorCode: true,
            clearSession: true,
            showUnverifiedSheet: true,
          );
          _inFlight = false;
          return;
        }
        state = state.copyWith(
          clearPendingAction: true,
          errorMessage: failure.message,
          errorCode: failure.errorCode,
          clearSession: true,
          showUnverifiedSheet: false,
        );
        AnalyticsService.instance.log(
          AnalyticsEvents.authLoginFail,
          params: {
            'method': 'email',
            if (failure.errorCode != null) 'error_code': failure.errorCode!,
          },
        );
      },
      (session) {
        ref.read(authStatusProvider.notifier).markLoggedIn(session);
        state = state.copyWith(
          clearPendingAction: true,
          session: session,
          showUnverifiedSheet: false,
        );
        AnalyticsService.instance.logAuthSuccess(
          event: AnalyticsEvents.authLoginSuccess,
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
      clearSession: true,
      showUnverifiedSheet: false,
    );

    final result = await ref.read(authLoginWithGoogleUseCaseProvider).call();
    result.match(
      (failure) => _applyGoogleFailure(failure),
      (session) => _applyGoogleSession(session),
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
      clearSession: true,
      showUnverifiedSheet: false,
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
      clearSession: true,
      showUnverifiedSheet: false,
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
        clearSession: true,
      );
      return;
    }
    final hide = failure.errorCode == 'GOOGLE_AUTH_UNAVAILABLE';
    state = state.copyWith(
      clearPendingAction: true,
      errorMessage: failure.message,
      errorCode: failure.errorCode,
      googleUnavailable: hide || state.googleUnavailable,
      clearSession: true,
    );
    AnalyticsService.instance.log(
      AnalyticsEvents.authLoginFail,
      params: {
        'method': 'google',
        if (failure.errorCode != null) 'error_code': failure.errorCode!,
      },
    );
  }

  void _applyFacebookFailure(AuthFailure failure) {
    if (failure.isSocialSignInCanceled) {
      state = state.copyWith(
        clearPendingAction: true,
        errorCode: failure.errorCode,
        clearErrorMessage: true,
        clearSession: true,
      );
      return;
    }
    final hide = failure.errorCode == 'FACEBOOK_AUTH_UNAVAILABLE';
    state = state.copyWith(
      clearPendingAction: true,
      errorMessage: failure.message,
      errorCode: failure.errorCode,
      facebookUnavailable: hide || state.facebookUnavailable,
      clearSession: true,
    );
    AnalyticsService.instance.log(
      AnalyticsEvents.authLoginFail,
      params: {
        'method': 'facebook',
        if (failure.errorCode != null) 'error_code': failure.errorCode!,
      },
    );
  }

  void _applyGithubFailure(AuthFailure failure) {
    if (failure.isSocialSignInCanceled) {
      state = state.copyWith(
        clearPendingAction: true,
        errorCode: failure.errorCode,
        clearErrorMessage: true,
        clearSession: true,
      );
      return;
    }
    final hide = failure.errorCode == 'GITHUB_AUTH_UNAVAILABLE';
    state = state.copyWith(
      clearPendingAction: true,
      errorMessage: failure.message,
      errorCode: failure.errorCode,
      githubUnavailable: hide || state.githubUnavailable,
      clearSession: true,
    );
    AnalyticsService.instance.log(
      AnalyticsEvents.authLoginFail,
      params: {
        'method': 'github',
        if (failure.errorCode != null) 'error_code': failure.errorCode!,
      },
    );
  }

  void _applyGoogleSession(AuthSession session) {
    _applySocialSession(session, method: 'google');
  }

  void _applySocialSession(AuthSession session, {required String method}) {
    ref.read(authStatusProvider.notifier).markLoggedIn(session);
    state = state.copyWith(clearPendingAction: true, session: session);
    AnalyticsService.instance.logAuthSuccess(
      event: AnalyticsEvents.authLoginSuccess,
      method: method,
    );
  }

  void acknowledgeUnverifiedSheet() {
    state = state.copyWith(showUnverifiedSheet: false);
  }

  /// Setelah toast "Masuk dibatalkan" supaya cancel kedua tetap memicu listen.
  void acknowledgeSocialCancel() {
    state = state.copyWith(clearErrorCode: true, clearErrorMessage: true);
  }
}
