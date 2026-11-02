class SetPasswordFailure {
  const SetPasswordFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;
}

class SetPasswordSuccess {
  const SetPasswordSuccess({required this.message, required this.loginWith});

  final String message;
  final String loginWith;
}
