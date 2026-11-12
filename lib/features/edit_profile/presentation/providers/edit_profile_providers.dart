import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../../domain/entities/username_availability.dart';
import '../../domain/providers/edit_profile_domain_providers.dart';
import '../models/edit_profile_state.dart';
import '../../../../core/i18n/l10n.dart';

part 'edit_profile_providers.g.dart';

@riverpod
class EditProfileNotifier extends _$EditProfileNotifier {
  Timer? _usernameDebounce;
  int _usernameCheckSeq = 0;

  @override
  EditProfileState build() {
    ref.onDispose(() {
      _usernameDebounce?.cancel();
    });
    return const EditProfileState(isLoading: true);
  }

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
    if (!ref.mounted) return null;
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
          usernameStatus: UsernameAvailabilityStatus.current,
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

  /// Debounce cek format lokal + availability server.
  void onUsernameChanged(String raw) {
    final trimmed = raw.trim();
    final initial = state.username?.trim() ?? '';

    _usernameDebounce?.cancel();

    if (trimmed.isEmpty) {
      state = state.copyWith(
        usernameStatus: UsernameAvailabilityStatus.invalid,
      );
      return;
    }

    if (!_isValidUsernameFormat(trimmed)) {
      state = state.copyWith(
        usernameStatus: UsernameAvailabilityStatus.invalid,
      );
      return;
    }

    if (trimmed.toLowerCase() == initial.toLowerCase()) {
      state = state.copyWith(
        usernameStatus: UsernameAvailabilityStatus.current,
      );
      return;
    }

    state = state.copyWith(
      usernameStatus: UsernameAvailabilityStatus.checking,
    );

    final seq = ++_usernameCheckSeq;
    _usernameDebounce = Timer(const Duration(milliseconds: 400), () {
      unawaited(_checkUsername(trimmed, seq));
    });
  }

  Future<void> _checkUsername(String username, int seq) async {
    final result =
        await ref.read(checkUsernameAvailabilityUseCaseProvider).call(username);
    if (!ref.mounted || seq != _usernameCheckSeq) return;

    result.match(
      (_) {
        // Jaringan gagal: jangan kunci submit selamanya; biarkan PATCH
        // yang jadi sumber kebenaran, tapi status tetap invalid supaya
        // user sadar cek belum selesai bersih. Ponytail: treat as invalid.
        state = state.copyWith(
          usernameStatus: UsernameAvailabilityStatus.invalid,
        );
      },
      (availability) {
        state = state.copyWith(usernameStatus: availability.status);
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
    if (!state.canSubmitUsername) return;

    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    final previousUsername = state.username;
    final result = await ref.read(updateMyProfileUseCaseProvider).call(
          username: username.trim(),
          displayName: displayName.trim(),
          bio: bio.trim().isEmpty ? null : bio.trim(),
          regionId: regionId,
          villageId: villageId,
        );
    if (!ref.mounted) return;

    final outcome = result.match(
      (failure) => (failure: failure, profile: null),
      (profile) => (failure: null, profile: profile),
    );
    if (outcome.failure != null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: outcome.failure!.message,
      );
      return;
    }

    final profile = outcome.profile!;
    await ref.read(authStatusProvider.notifier).applySessionIdentity(
          username: profile.username,
          displayName: profile.displayName,
          avatarUrl: profile.avatarUrl,
        );
    if (!ref.mounted) return;

    if (previousUsername != null && previousUsername.isNotEmpty) {
      ref.invalidate(publicProfileProvider(previousUsername));
      ref.invalidate(publicActivityProvider(previousUsername));
    }
    if (profile.username.isNotEmpty &&
        profile.username.toLowerCase() != previousUsername?.toLowerCase()) {
      ref.invalidate(publicProfileProvider(profile.username));
      ref.invalidate(publicActivityProvider(profile.username));
    }

    state = state.copyWith(
      isSubmitting: false,
      username: profile.username,
      usernameStatus: UsernameAvailabilityStatus.current,
      successMessage: l10n.editProfileSaveSuccess,
      clearErrorMessage: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }
}

bool _isValidUsernameFormat(String value) {
  return RegExp(r'^[a-z0-9._]{6,30}$').hasMatch(value);
}
