import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/env.dart';
import '../../../auth/data/providers/auth_data_providers.dart';
import '../../domain/providers/set_password_domain_providers.dart';
import '../../domain/usecases/set_password_use_case.dart';
import '../models/set_password_state.dart';

part 'set_password_providers.g.dart';

@riverpod
class SetPasswordNotifier extends _$SetPasswordNotifier {
  @override
  SetPasswordState build() => const SetPasswordState();

  Future<void> submit({
    required String provider,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
      clearLoginWith: true,
    );

    final SetPasswordParams? params;
    try {
      params = await _prove(
        provider: provider,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: _clean(error));
      return;
    }
    if (params == null) {
      state = state.copyWith(isSubmitting: false);
      return;
    }

    final result = await ref.read(setPasswordUseCaseProvider).call(params);
    result.match(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        isSubmitting: false,
        successMessage: success.message,
        loginWith: success.loginWith,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  Future<SetPasswordParams?> _prove({
    required String provider,
    required String newPassword,
    required String confirmPassword,
  }) async {
    switch (provider) {
      case 'google':
        final idToken = await ref.read(googleSignInPortProvider).authenticate();
        if (idToken == null || idToken.trim().isEmpty) return null;
        return SetPasswordParams(
          provider: provider,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
          idToken: idToken,
        );
      case 'facebook':
        final appId = Env.facebookAppId?.trim();
        if (appId == null || appId.isEmpty) {
          throw StateError(
            'Masuk dengan Facebook belum siap di perangkat ini.',
          );
        }
        final accessToken = await ref
            .read(facebookSignInPortProvider)
            .authenticate();
        if (accessToken == null || accessToken.trim().isEmpty) return null;
        return SetPasswordParams(
          provider: provider,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
          accessToken: accessToken,
        );
      case 'github':
        final auth = await ref.read(githubSignInPortProvider).authenticate();
        if (auth == null) return null;
        return SetPasswordParams(
          provider: provider,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
          code: auth.code,
          redirectUri: auth.redirectUri,
          codeVerifier: auth.codeVerifier,
        );
      default:
        throw StateError('Provider tidak dikenal.');
    }
  }

  String _clean(Object error) {
    return error.toString().replaceFirst('Bad state: ', '');
  }
}
