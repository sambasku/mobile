import '../../domain/entities/username_availability.dart';
import '../../domain/entities/username_history_item.dart';

class EditProfileState {
  const EditProfileState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.username,
    this.usernameStatus = UsernameAvailabilityStatus.idle,
    this.usernameChangeAllowedAt,
    this.usernameHistory = const [],
    this.isHistoryLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final bool isSubmitting;
  final String? username;
  final UsernameAvailabilityStatus usernameStatus;
  final DateTime? usernameChangeAllowedAt;
  final List<UsernameHistoryItem> usernameHistory;
  final bool isHistoryLoading;
  final String? errorMessage;
  final String? successMessage;

  bool get isUsernameLocked {
    final at = usernameChangeAllowedAt;
    if (at == null) return false;
    return at.isAfter(DateTime.now());
  }

  bool get canSubmitUsername =>
      usernameStatus == UsernameAvailabilityStatus.current ||
      usernameStatus == UsernameAvailabilityStatus.available ||
      usernameStatus == UsernameAvailabilityStatus.reclaimable;

  EditProfileState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? username,
    UsernameAvailabilityStatus? usernameStatus,
    DateTime? usernameChangeAllowedAt,
    List<UsernameHistoryItem>? usernameHistory,
    bool? isHistoryLoading,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool clearUsernameChangeAllowedAt = false,
  }) {
    return EditProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      username: username ?? this.username,
      usernameStatus: usernameStatus ?? this.usernameStatus,
      usernameChangeAllowedAt: clearUsernameChangeAllowedAt
          ? null
          : (usernameChangeAllowedAt ?? this.usernameChangeAllowedAt),
      usernameHistory: usernameHistory ?? this.usernameHistory,
      isHistoryLoading: isHistoryLoading ?? this.isHistoryLoading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
