import '../../domain/entities/username_availability.dart';

class EditProfileState {
  const EditProfileState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.username,
    this.usernameStatus = UsernameAvailabilityStatus.idle,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String? username;
  final UsernameAvailabilityStatus usernameStatus;
  final String? errorMessage;
  final String? successMessage;

  bool get canSubmitUsername =>
      usernameStatus == UsernameAvailabilityStatus.current ||
      usernameStatus == UsernameAvailabilityStatus.available;

  EditProfileState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? username,
    UsernameAvailabilityStatus? usernameStatus,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      username: username ?? this.username,
      usernameStatus: usernameStatus ?? this.usernameStatus,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
