import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../../../core/constants/env.dart';
import '../../../flavors.dart';
import '../domain/ports/github_sign_in_port.dart';

class GithubSignInAdapter implements GithubSignInPort {
  GithubSignInAdapter({FlutterAppAuth? appAuth})
    : _appAuth = appAuth ?? const FlutterAppAuth();

  final FlutterAppAuth _appAuth;

  static const _scopes = ['read:user', 'user:email'];

  static const _serviceConfig = AuthorizationServiceConfiguration(
    authorizationEndpoint: 'https://github.com/login/oauth/authorize',
    tokenEndpoint: 'https://github.com/login/oauth/access_token',
  );

  @override
  Future<GithubAuthCode?> authenticate() async {
    final clientId = Env.githubClientId?.trim();
    if (clientId == null || clientId.isEmpty) {
      throw StateError(
        'Masuk dengan GitHub belum siap di perangkat ini. Coba lagi nanti.',
      );
    }

    final redirectUri = githubOAuthRedirectUri();

    try {
      final result = await _appAuth.authorize(
        AuthorizationRequest(
          clientId,
          redirectUri,
          serviceConfiguration: _serviceConfig,
          scopes: _scopes,
        ),
      );

      final code = result.authorizationCode?.trim();
      if (code == null || code.isEmpty) {
        return null;
      }

      return GithubAuthCode(
        code: code,
        redirectUri: redirectUri,
        codeVerifier: result.codeVerifier,
      );
    } on FlutterAppAuthUserCancelledException {
      return null;
    } on FlutterAppAuthPlatformException catch (error, stack) {
      _log('FlutterAppAuthPlatformException code=${error.code}', error, stack);
      throw StateError('Tidak bisa masuk dengan GitHub. Coba lagi.');
    } catch (error, stack) {
      _log('authenticate gagal', error, stack);
      final message = error.toString().toLowerCase();
      if (message.contains('cancel') || message.contains('user_canceled')) {
        return null;
      }
      rethrow;
    }
  }

  void _log(String message, Object error, StackTrace stack) {
    debugPrint('[auth.github] $message: $error');
    developer.log(
      message,
      name: 'auth.github',
      error: error,
      stackTrace: stack,
    );
  }
}

/// Redirect AppAuth / callback OAuth App GitHub.
///
/// GitHub menolak custom scheme (`com.app:/...`) - wajib URL http(s).
/// Pakai origin web publik + path App Link (sama host deeplink).
String githubOAuthRedirectUri() {
  final origin = Env.webAppUrl?.replaceAll(RegExp(r'/+$'), '') ??
      (F.isStaging
          ? 'https://sambasku-web-staging.iamutaki.com'
          : 'https://sambasku.com');
  return '$origin/oauth/github';
}
