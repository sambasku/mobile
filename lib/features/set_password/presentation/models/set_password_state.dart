class SetPasswordState {
  const SetPasswordState({
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.loginWith,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final String? loginWith;

  SetPasswordState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    String? loginWith,
    bool clearLoginWith = false,
  }) {
    return SetPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
      loginWith: clearLoginWith ? null : loginWith ?? this.loginWith,
    );
  }
}
