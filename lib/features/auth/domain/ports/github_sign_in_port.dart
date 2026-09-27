/// Hasil authorize GitHub (AppAuth) sebelum code ditukar di API.
class GithubAuthCode {
  const GithubAuthCode({
    required this.code,
    required this.redirectUri,
    this.codeVerifier,
  });

  final String code;
  final String redirectUri;
  final String? codeVerifier;
}

/// Port OAuth GitHub di perangkat (AppAuth). Secret tidak pernah di app.
abstract interface class GithubSignInPort {
  /// Null = user batal / dismiss browser.
  Future<GithubAuthCode?> authenticate();
}
