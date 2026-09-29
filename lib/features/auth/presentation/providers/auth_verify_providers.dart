import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/providers/auth_domain_providers.dart';
import '../../domain/usecases/verify_email_use_case.dart';
import '../models/auth_verify_state.dart';
import 'auth_status_providers.dart';

part 'auth_verify_providers.g.dart';

@riverpod
class AuthVerifyNotifier extends _$AuthVerifyNotifier {
  @override
  AuthVerifyState build() => const AuthVerifyState();

  Future<void> submit({required String email, required String code}) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearErrorCode: true,
      clearResendMessage: true,
      clearSession: true,
    );

    final result = await ref
        .read(authVerifyEmailUseCaseProvider)
        .call(VerifyEmailParams(email: email, code: code));

    result.match(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          errorCode: failure.errorCode,
          clearSession: true,
        );
      },
      (session) {
        ref.read(authStatusProvider.notifier).markLoggedIn(session);
        state = state.copyWith(isSubmitting: false, session: session);
      },
    );
  }

  Future<void> resend({required String email}) async {
    state = state.copyWith(
      isResending: true,
      clearErrorMessage: true,
      clearErrorCode: true,
      clearResendMessage: true,
    );

    final result = await ref.read(authResendOtpUseCaseProvider).call(email);

    result.match(
      (failure) {
        state = state.copyWith(
          isResending: false,
          errorMessage: failure.message,
          errorCode: failure.errorCode,
        );
      },
      (_) {
        state = state.copyWith(
          isResending: false,
          resendMessage: 'Kalau email terdaftar, kode baru sudah dikirim.',
        );
      },
    );
  }

  /// Setelah sheet error ditutup supaya error yang sama bisa memicu listen lagi.
  void clearError() {
    state = state.copyWith(clearErrorMessage: true, clearErrorCode: true);
  }
}
