import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/auth_domain_providers.dart';
import '../models/auth_forgot_state.dart';

part 'auth_forgot_providers.g.dart';

@riverpod
class AuthForgotNotifier extends _$AuthForgotNotifier {
  @override
  AuthForgotState build() => const AuthForgotState();

  Future<void> submit({required String email}) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final result = await ref
        .read(authForgotPasswordUseCaseProvider)
        .call(email);

    result.match(
      (failure) => state = state.copyWith(
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
