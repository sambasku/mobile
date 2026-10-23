/// State halaman lupa password.
class AuthForgotState {
  const AuthForgotState({
    this.isSubmitting = false,
    this.errorMessage,
    this.errorCode,
    this.successMessage,
  });

  final bool isSubmitting;
  final String? errorMessage;
  /// Kode error backend (mis. OAUTH_ACCOUNT) - menentukan cara tampil.
  final String? errorCode;
  /// Non-null = email terkirim (pesan anti-enumeration dari API).
  final String? successMessage;

  AuthForgotState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? errorCode,
    bool clearErrorCode = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return AuthForgotState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      errorCode: clearErrorCode
          ? null
          : errorCode ?? this.errorCode,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
