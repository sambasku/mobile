import '../../domain/entities/auth_session.dart';
import 'auth_pending_action.dart';

export 'auth_pending_action.dart';

/// State halaman register. Sukses = akun dibuat, lanjut OTP (bukan auto-login).
/// Google: session terisi, langsung home.
class AuthRegisterState {
  const AuthRegisterState({
    this.pendingAction,
    this.errorMessage,
    this.errorCode,
    this.success = false,
    this.pendingEmail,
    this.session,
    this.googleUnavailable = false,
    this.facebookUnavailable = false,
    this.githubUnavailable = false,
  });

  /// Null = idle. Non-null = request jalan; spinner hanya di aksi ini.
  final AuthPendingAction? pendingAction;
  final String? errorMessage;
  final String? errorCode;

  /// Register sukses, belum login. UI arahkan ke /verify-email.
  final bool success;
  final String? pendingEmail;
  final AuthSession? session;
  final bool googleUnavailable;
  final bool facebookUnavailable;
  final bool githubUnavailable;

  bool get isSubmitting => pendingAction != null;

  AuthRegisterState copyWith({
    AuthPendingAction? pendingAction,
    bool clearPendingAction = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? errorCode,
    bool clearErrorCode = false,
    bool? success,
    String? pendingEmail,
    bool clearPendingEmail = false,
    AuthSession? session,
    bool clearSession = false,
    bool? googleUnavailable,
    bool? facebookUnavailable,
    bool? githubUnavailable,
  }) {
    return AuthRegisterState(
      pendingAction:
          clearPendingAction ? null : pendingAction ?? this.pendingAction,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      errorCode: clearErrorCode ? null : errorCode ?? this.errorCode,
      success: success ?? this.success,
      pendingEmail: clearPendingEmail
          ? null
          : pendingEmail ?? this.pendingEmail,
      session: clearSession ? null : session ?? this.session,
      googleUnavailable: googleUnavailable ?? this.googleUnavailable,
      facebookUnavailable: facebookUnavailable ?? this.facebookUnavailable,
      githubUnavailable: githubUnavailable ?? this.githubUnavailable,
    );
  }
}
