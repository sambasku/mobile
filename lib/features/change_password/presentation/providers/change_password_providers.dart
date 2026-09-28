import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/change_password_domain_providers.dart';
import '../../domain/usecases/change_password_use_case.dart';
import '../models/change_password_state.dart';

part 'change_password_providers.g.dart';

@riverpod
class ChangePasswordNotifier extends _$ChangePasswordNotifier {
  @override
  ChangePasswordState build() => const ChangePasswordState();

  Future<void> submit({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final result = await ref.read(changePasswordUseCaseProvider).call(
          ChangePasswordParams(
            oldPassword: oldPassword,
            newPassword: newPassword,
            confirmPassword: confirmPassword,
          ),
        );

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
