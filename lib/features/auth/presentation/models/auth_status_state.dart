/// State status login app (pola jnn_mobile): dipakai Profile untuk
/// membedakan tampilan user sudah login vs tamu.
class AuthStatusState {
  const AuthStatusState({
    this.isAuth = false,
    this.username,
    this.displayName,
    this.role,
    this.userId,
    this.avatarUrl,
    this.isLoggingOut = false,
    this.requiresLegalConsent = false,
  });

  final bool isAuth;
  final String? username;
  final String? displayName;
  final String? role;
  final String? userId;
  final String? avatarUrl;
  final bool isLoggingOut;

  /// Server bilang user belum menyetujui terms/privacy versi aktif.
  /// Sumber kebenaran: `requires_consent` di GET /users/me (bukan flag
  /// sekali-pakai dari response login) - jadi force close tetap muncul lagi.
  final bool requiresLegalConsent;

  AuthStatusState copyWith({
    bool? isAuth,
    String? username,
    String? displayName,
    bool clearDisplayName = false,
    String? role,
    String? userId,
    String? avatarUrl,
    bool? isLoggingOut,
    bool clearAvatarUrl = false,
    bool? requiresLegalConsent,
  }) {
    return AuthStatusState(
      isAuth: isAuth ?? this.isAuth,
      username: username ?? this.username,
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      role: role ?? this.role,
      userId: userId ?? this.userId,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      requiresLegalConsent: requiresLegalConsent ?? this.requiresLegalConsent,
    );
  }
}
