import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'deep_link_params.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'data/github_oauth_callback_bus.dart';
import 'presentation/pages/forgot_password_page.dart';
import 'presentation/pages/legal_webview_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/reset_password_page.dart';
import 'presentation/pages/verify_email_page.dart';

class AuthRouter {
  AuthRouter._();

  static const login = RouteDefiner(path: '/login', name: 'AuthRouter.login');
  static const register = RouteDefiner(
    path: '/register',
    name: 'AuthRouter.register',
  );
  static const verifyEmail = RouteDefiner(
    path: '/verify-email',
    name: 'AuthRouter.verifyEmail',
  );
  static const forgotPassword = RouteDefiner(
    path: '/forgot-password',
    name: 'AuthRouter.forgotPassword',
  );
  static const resetPassword = RouteDefiner(
    path: '/reset-password',
    name: 'AuthRouter.resetPassword',
  );
  /// Deep link OAuth GitHub (`sambasku-staging://app/oauth/github`).
  /// Code ditangani [GithubSignInAdapter]; rute ini hanya mencegah 404.
  static const githubOauthCallback = RouteDefiner(
    path: '/oauth/github',
    name: 'AuthRouter.githubOauthCallback',
  );
  static const termsWebView = RouteDefiner(
    path: '/syarat-ketentuan',
    name: 'AuthRouter.termsWebView',
  );

  /// URL publik Syarat dan Ketentuan (web).
  static const termsDocumentUrl = 'https://sambasku.com/id/syarat-ketentuan';

  static final List<GoRoute> routes = [
    GoRoute(
      path: login.path,
      name: login.name,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: register.path,
      name: register.name,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: termsWebView.path,
      name: termsWebView.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const LegalWebViewPage(
        url: termsDocumentUrl,
        title: 'Syarat dan Ketentuan',
      ),
    ),
    GoRoute(
      path: verifyEmail.path,
      name: verifyEmail.name,
      builder: (context, state) {
        final email = sanitizeEmailParam(
          state.uri.queryParameters['email'] ?? '',
        );
        return VerifyEmailPage(
          key: ValueKey(email),
          email: email,
          startCooldown: state.uri.queryParameters['cooldown'] == '1',
        );
      },
    ),
    GoRoute(
      path: forgotPassword.path,
      name: forgotPassword.name,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: resetPassword.path,
      name: resetPassword.name,
      builder: (context, state) => ResetPasswordPage(
        email: sanitizeEmailParam(state.uri.queryParameters['email'] ?? ''),
        initialToken: sanitizeResetTokenParam(
          state.uri.queryParameters['token'] ?? '',
        ),
        startCooldown: state.uri.queryParameters['cooldown'] == '1',
      ),
    ),
    GoRoute(
      path: githubOauthCallback.path,
      name: githubOauthCallback.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        // Serahkan URI ke adapter (GoRouter sering dapat link lebih dulu
        // daripada app_links), lalu kembali ke login/daftar.
        GithubOauthCallbackBus.emit(state.uri);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(login.path);
          }
        });
        return const SizedBox.shrink();
      },
    ),
  ];
}
