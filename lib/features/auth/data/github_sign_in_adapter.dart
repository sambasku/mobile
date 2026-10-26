import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/env.dart';
import '../../../flavors.dart';
import '../domain/ports/github_sign_in_port.dart';
import 'github_oauth_callback_bus.dart';

/// GitHub OAuth tanpa AppAuth.
///
/// Alur: PKCE → in-app browser → HTTPS callback (GitHub) → halaman web
/// redirect ke scheme per flavor → app_links:
///   staging `sambasku-staging://app/oauth/github`
///   production `sambasku://app/oauth/github`
class GithubSignInAdapter implements GithubSignInPort {
  GithubSignInAdapter({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;

  static const _scopes = 'read:user user:email';

  @override
  Future<GithubAuthCode?> authenticate() async {
    final clientId = Env.githubClientId?.trim();
    if (clientId == null || clientId.isEmpty) {
      throw StateError(
        'Masuk dengan GitHub belum siap di perangkat ini. Coba lagi dalam beberapa saat.',
      );
    }

    final redirectUri = githubOAuthRedirectUri();
    final codeVerifier = _randomUrlSafe(64);
    final state = _randomUrlSafe(24);
    final challenge = _s256Challenge(codeVerifier);

    final authorizeUri = Uri.https('github.com', '/login/oauth/authorize', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': _scopes,
      'state': state,
      'response_type': 'code',
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
    });

    debugPrint(
      '[auth.github] authorize clientId=$clientId redirectUri=$redirectUri',
    );

    final completer = Completer<GithubAuthCode?>();
    var gotCallback = false;
    Timer? resumeCancelTimer;

    void completeOnce(GithubAuthCode? value) {
      resumeCancelTimer?.cancel();
      if (!completer.isCompleted) completer.complete(value);
    }

    void onUri(Uri uri) {
      debugPrint('[auth.github] callback uri=$uri');
      if (!_isGithubOauthCallback(uri)) return;
      final code = uri.queryParameters['code']?.trim();
      final returnedState = uri.queryParameters['state']?.trim();
      if (returnedState != null &&
          returnedState.isNotEmpty &&
          returnedState != state) {
        debugPrint('[auth.github] state mismatch, ignore');
        return;
      }
      gotCallback = true;
      if (code == null || code.isEmpty) {
        completeOnce(null);
        return;
      }
      debugPrint(
        '[auth.github] code ok len=${code.length} redirectUri=$redirectUri '
        'verifier=${codeVerifier.length}',
      );
      completeOnce(
        GithubAuthCode(
          code: code,
          redirectUri: redirectUri,
          codeVerifier: codeVerifier,
        ),
      );
    }

    final subAppLinks = _appLinks.uriLinkStream.listen(
      onUri,
      onError: (Object e, StackTrace st) => _log('uriLinkStream', e, st),
    );
    final subBus = GithubOauthCallbackBus.stream.listen(onUri);

    final lifecycle = _ResumeCancelObserver(() {
      // Deep link biasanya datang sedikit setelah resume; jangan race.
      resumeCancelTimer?.cancel();
      resumeCancelTimer = Timer(const Duration(milliseconds: 2000), () {
        if (!gotCallback) completeOnce(null);
      });
    });
    WidgetsBinding.instance.addObserver(lifecycle);

    try {
      var ok = await launchUrl(
        authorizeUri,
        // inAppBrowserView ≈ Custom Tabs; custom scheme menutupnya & kembali.
        mode: LaunchMode.inAppBrowserView,
      );
      if (!ok) {
        ok = await launchUrl(
          authorizeUri,
          mode: LaunchMode.externalApplication,
        );
      }
      if (!ok) {
        throw StateError('Tidak bisa buka GitHub. Coba lagi.');
      }
      return await completer.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () => null,
      );
    } catch (error, stack) {
      _log('authenticate gagal', error, stack);
      final message = error.toString().toLowerCase();
      if (message.contains('cancel') || message.contains('user_canceled')) {
        return null;
      }
      if (error is StateError) rethrow;
      throw StateError('Tidak bisa masuk dengan GitHub. Coba lagi.');
    } finally {
      resumeCancelTimer?.cancel();
      WidgetsBinding.instance.removeObserver(lifecycle);
      await subAppLinks.cancel();
      await subBus.cancel();
    }
  }

  static bool _isGithubOauthCallback(Uri uri) {
    final path = uri.path;
    final pathOk =
        path == '/oauth/github' || path.startsWith('/oauth/github/');
    if (!pathOk) return false;
    final scheme = uri.scheme.toLowerCase();
    // GoRouter kadang kirim path-only / scheme terpotong; cukup path+code.
    if (scheme.isEmpty || scheme == 'https' || scheme == 'http') {
      return uri.queryParameters.containsKey('code');
    }
    if (scheme != githubOauthAppDeepLinkScheme()) return false;
    final host = uri.host.toLowerCase();
    return host.isEmpty || host == 'app';
  }

  static String _randomUrlSafe(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rnd = Random.secure();
    return List.generate(
      length,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
  }

  static String _s256Challenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
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

class _ResumeCancelObserver with WidgetsBindingObserver {
  _ResumeCancelObserver(this.onResumed);

  final void Function() onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onResumed();
  }
}

/// Custom scheme app setelah HTTPS callback (staging ≠ production).
String githubOauthAppDeepLinkScheme() =>
    F.isStaging ? 'sambasku-staging' : 'sambasku';

/// Redirect HTTPS yang didaftarkan di GitHub OAuth App.
String githubOAuthRedirectUri() {
  final origin =
      Env.webAppUrl?.replaceAll(RegExp(r'/+$'), '') ??
      (F.isStaging
          ? 'https://sambasku-web-staging.ibnuul.workers.dev'
          : 'https://sambasku.com');
  return '$origin/oauth/github';
}
