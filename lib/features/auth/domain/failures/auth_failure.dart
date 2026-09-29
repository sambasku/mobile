/// Failure auth - pesan siap tampil (sudah generik dari backend,
/// anti-enumeration). `errorCode` opsional untuk penanganan spesifik
/// (mis. RATE_LIMITED -> toast hitung mundur).
class AuthFailure {
  const AuthFailure(this.message, {this.errorCode});

  static const googleSignInCanceled = 'GOOGLE_SIGN_IN_CANCELED';
  static const facebookSignInCanceled = 'FACEBOOK_SIGN_IN_CANCELED';
  static const githubSignInCanceled = 'GITHUB_SIGN_IN_CANCELED';

  final String message;
  final String? errorCode;

  bool get isEmailNotVerified => errorCode == 'EMAIL_NOT_VERIFIED';

  /// User dismiss sheet Google/Facebook/GitHub → toast singkat, bukan alert form.
  bool get isSocialSignInCanceled =>
      errorCode == googleSignInCanceled ||
      errorCode == facebookSignInCanceled ||
      errorCode == githubSignInCanceled;
}
