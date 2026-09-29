import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/delete_account_domain_providers.dart';
import '../models/delete_account_state.dart';

part 'delete_account_providers.g.dart';

@riverpod
class DeleteAccountNotifier extends _$DeleteAccountNotifier {
  @override
  DeleteAccountState build() => const DeleteAccountState();

  Future<void> submit({
    String? password,
    required String confirmation,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final result = await ref.read(deleteAccountUseCaseProvider).call(
          password: password,
          confirmation: confirmation,
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
