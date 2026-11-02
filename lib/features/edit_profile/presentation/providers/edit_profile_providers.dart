import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../../domain/providers/edit_profile_domain_providers.dart';
import '../models/edit_profile_state.dart';
import '../../../../core/i18n/l10n.dart';

part 'edit_profile_providers.g.dart';

@riverpod
class EditProfileNotifier extends _$EditProfileNotifier {
  @override
  EditProfileState build() => const EditProfileState(isLoading: true);

  Future<
      ({
        String username,
        String displayName,
        String bio,
        String? regionId,
        String? villageId,
      })?> load() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    final result = await ref.read(getMyProfileUseCaseProvider).call();
    return result.match(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (profile) {
        state = state.copyWith(
          isLoading: false,
          username: profile.username,
          clearErrorMessage: true,
        );
        // Sync handle ke sesi lokal (bisa stale setelah migrate slug).
        unawaited(
          ref.read(authStatusProvider.notifier).applySessionIdentity(
                username: profile.username,
                displayName: profile.displayName,
                avatarUrl: profile.avatarUrl,
              ),
        );
        return (
          username: profile.username,
          displayName: profile.displayName,
          bio: profile.bio ?? '',
          regionId: profile.regionId,
          villageId: profile.villageId,
        );
      },
    );
  }

  Future<void> submit({
    required String username,
    required String displayName,
    required String bio,
    String? regionId,
    String? villageId,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final result = await ref.read(updateMyProfileUseCaseProvider).call(
          username: username.trim(),
          displayName: displayName.trim(),
          bio: bio.trim().isEmpty ? null : bio.trim(),
          regionId: regionId,
          villageId: villageId,
        );

    final outcome = result.match(
      (failure) => failure,
      (_) => null,
    );
    if (outcome != null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: outcome.message,
      );
      return;
    }

    await ref
        .read(authStatusProvider.notifier)
        .setDisplayName(displayName.trim());

    final storedUsername = state.username;
    if (storedUsername != null && storedUsername.isNotEmpty) {
      ref.invalidate(publicProfileProvider(storedUsername));
      ref.invalidate(publicActivityProvider(storedUsername));
    }

    state = state.copyWith(
      isSubmitting: false,
      successMessage: l10n.editProfileSaveSuccess,
      clearErrorMessage: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }
}
