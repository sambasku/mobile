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
  });

  final bool isAuth;
  final String? username;
  final String? displayName;
  final String? role;
  final String? userId;
  final String? avatarUrl;
  final bool isLoggingOut;

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
  }) {
    return AuthStatusState(
      isAuth: isAuth ?? this.isAuth,
      username: username ?? this.username,
      displayName: clearDisplayName
          ? null
          : (displayName ?? this.displayName),
      role: role ?? this.role,
      userId: userId ?? this.userId,
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}