/// Failure modul achievement. extends Error supaya Riverpod tidak auto-retry 4xx.
class AchievementFailure extends Error {
  AchievementFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isRateLimited => errorCode == 'RATE_LIMITED';
  bool get isBorderNotOwned => errorCode == 'ACHIEVEMENT_BORDER_NOT_OWNED';
  bool get isUnauthorized => errorCode == 'UNAUTHORIZED';

  @override
  String toString() => 'AchievementFailure($errorCode): $message';
}
