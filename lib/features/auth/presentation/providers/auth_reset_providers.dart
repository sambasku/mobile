import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/failures/auth_failure.dart';
import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/reset_password_use_case.dart';
import '../models/auth_reset_state.dart';

part 'auth_reset_providers.g.dart';

@riverpod
class AuthResetNotifier extends _$AuthResetNotifier {
  @override
  AuthResetState build() => const AuthResetState();

  Future<void> submit({
    String? token,
    String? email,
    String? code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Konfirmasi password tidak sama',
        clearSuccessMessage: true,
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final result = await ref
        .read(authResetPasswordUseCaseProvider)
        .call(
          ResetPasswordParams(
            token: token,
            email: email,
            code: code,
            newPassword: newPassword,
          ),
        );

    result.match(
      (AuthFailure failure) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
        clearSuccessMessage: true,
      ),
      (message) => state = state.copyWith(
        isSubmitting: false,
        successMessage: message,
        clearErrorMessage: true,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }
}
