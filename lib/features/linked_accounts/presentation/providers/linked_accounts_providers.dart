import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/data/providers/auth_data_providers.dart';
import '../../../auth/domain/ports/github_sign_in_port.dart';
import '../../../auth/domain/ports/google_sign_in_port.dart';
import '../../../auth/presentation/models/auth_login_state.dart';
import '../../domain/providers/linked_accounts_domain_providers.dart';
import '../models/linked_accounts_state.dart';

part 'linked_accounts_providers.g.dart';

@riverpod
class LinkedAccountsNotifier extends _$LinkedAccountsNotifier {
  @override
  LinkedAccountsState build() {
    Future.microtask(refresh);
    return const LinkedAccountsState();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true, clearInfo: true);
    final result = await ref.read(getLinkedAccountsStatusUseCaseProvider).call();
    result.match(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (status) => state = state.copyWith(
        isLoading: false,
        googleLinked: status.googleLinked,
        githubLinked: status.githubLinked,
        clearError: true,
      ),
    );
  }

  Future<void> linkGoogle() async {
    state = state.copyWith(isBusy: true, clearError: true, clearInfo: true);
    final GoogleSignInPort google = ref.read(googleSignInPortProvider);
    try {
      final idToken = await google.authenticate();
      if (idToken == null) {
        state = state.copyWith(isBusy: false);
        return;
      }
      final result =
          await ref.read(linkGoogleAccountUseCaseProvider).call(idToken);
      result.match(
        (failure) => state = state.copyWith(
          isBusy: false,
          errorMessage: failure.message,
        ),
        (_) => state = state.copyWith(
          isBusy: false,
          googleLinked: true,
          infoMessage: 'Berhasil ditambahkan ke akun terhubung.',
          clearError: true,
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: error.toString().replaceFirst('Bad state: ', ''),
      );
    }
  }

  Future<void> unlinkGoogle() async {
    state = state.copyWith(isBusy: true, clearError: true, clearInfo: true);
    final result = await ref.read(unlinkGoogleAccountUseCaseProvider).call();
    result.match(
      (failure) => state = state.copyWith(
        isBusy: false,
        errorMessage: failure.message,
      ),
      (message) => state = state.copyWith(
        isBusy: false,
        googleLinked: false,
        infoMessage: message,
        clearError: true,
      ),
    );
  }

  Future<void> linkGithub() async {
    if (!isGithubAuthConfigured()) {
      state = state.copyWith(
        errorMessage: 'Masuk dengan GitHub belum siap di perangkat ini.',
      );
      return;
    }
    state = state.copyWith(isBusy: true, clearError: true, clearInfo: true);
    final GithubSignInPort github = ref.read(githubSignInPortProvider);
    try {
      final auth = await github.authenticate();
      if (auth == null) {
        state = state.copyWith(isBusy: false);
        return;
      }
      final result = await ref.read(linkGithubAccountUseCaseProvider).call(
            code: auth.code,
            redirectUri: auth.redirectUri,
            codeVerifier: auth.codeVerifier,
          );
      result.match(
        (failure) => state = state.copyWith(
          isBusy: false,
          errorMessage: failure.message,
        ),
        (_) => state = state.copyWith(
          isBusy: false,
          githubLinked: true,
          infoMessage: 'Berhasil ditambahkan ke akun terhubung.',
          clearError: true,
        ),
      );
    } catch (error) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: error.toString().replaceFirst('Bad state: ', ''),
      );
    }
  }

  Future<void> unlinkGithub() async {
    state = state.copyWith(isBusy: true, clearError: true, clearInfo: true);
    final result = await ref.read(unlinkGithubAccountUseCaseProvider).call();
    result.match(
      (failure) => state = state.copyWith(
        isBusy: false,
        errorMessage: failure.message,
      ),
      (message) => state = state.copyWith(
        isBusy: false,
        githubLinked: false,
        infoMessage: message,
        clearError: true,
      ),
    );
  }
}
