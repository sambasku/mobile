import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
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
        final email = state.uri.queryParameters['email'] ?? '';
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
        email: state.uri.queryParameters['email'] ?? '',
        initialToken: state.uri.queryParameters['token'] ?? '',
        startCooldown: state.uri.queryParameters['cooldown'] == '1',
      ),
    ),
  ];
}
