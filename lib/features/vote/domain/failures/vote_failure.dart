/// Failure operasi vote. `errorCode` membawa kode backend untuk
/// penanganan spesifik (mis. VOTE_TARGET_NOT_FOUND -> 404 / empty state).
class VoteFailure {
  const VoteFailure(this.message, {this.errorCode});

  final String message;
  final String? errorCode;

  bool get isNotFound => errorCode == 'VOTE_TARGET_NOT_FOUND';
  bool get isRateLimited => errorCode == 'RATE_LIMITED';

  /// #109: tanpa override ini `error.toString()` = "Instance of 'X'" yang
  /// jadi "Instance of 'tTb'" di release (obfuscation) - pesan backend
  /// tak pernah sampai ke layar.
  @override
  String toString() =>
      errorCode != null ? '$message ($errorCode)' : message;
}