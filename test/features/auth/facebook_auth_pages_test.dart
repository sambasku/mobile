import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/ports/facebook_sign_in_port.dart';
import 'package:sambasku_mobile/features/auth/domain/providers/auth_domain_providers.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/auth/domain/usecases/login_with_facebook_use_case.dart';
import 'package:sambasku_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:sambasku_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_login_providers.dart';
import 'package:sambasku_mobile/flavors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubSignIn implements FacebookSignInPort {
  @override
  Future<String?> authenticate() async => 'fb-token';
}

class _StubRepo implements AuthRepository {
  _StubRepo(this.facebookResult);
  final Either<AuthFailure, AuthSession> facebookResult;

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
  }) async => facebookResult;

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
  }) async => Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async => Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  }) async => Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, void>> logout() async => Either.right(null);

  @override
  Future<Either<AuthFailure, AuthSession>> verifyEmail({
    required String email,
    required String code,
  }) async => Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, void>> resendOtp({required String email}) async =>
      Either.right(null);

  @override
  Future<Either<AuthFailure, String>> forgotPassword({
    required String email,
  }) async => Either.right('ok');

  @override
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async => Either.right('ok');
}

Widget _harness({
  required Widget child,
  required List<dynamic> overrides,
}) {
  // LoginPage membaca GoRouterState (query relogin); harus di bawah RouteBase.
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
    ],
  );
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp.router(
      theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, routed) => FTheme(
        data: FThemes.zinc.light.touch,
        child: FToaster(child: routed ?? const SizedBox.shrink()),
      ),
    ),
  );
}

/// LoginPage Skeletonizer tidak idle; FTappable tap menyimpan timer 100 ms.
Future<void> _pumpUi(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 200));
}

void main() {
  setUp(() {
    F.appFlavor = Flavor.staging;
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('FACEBOOK_APP_ID kosong → tombol Facebook tidak ada', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        child: const LoginPage(),
        overrides: [facebookAuthEnabledProvider.overrideWithValue(false)],
      ),
    );
    await _pumpUi(tester);
    expect(find.text('Masuk dengan Facebook'), findsNothing);
  });

  testWidgets('App ID terisi → tombol Masuk dengan Facebook ada', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        child: const LoginPage(),
        overrides: [facebookAuthEnabledProvider.overrideWithValue(true)],
      ),
    );
    await _pumpUi(tester);
    expect(find.text('Masuk dengan Facebook'), findsOneWidget);
  });

  testWidgets('register: tombol Daftar dengan Facebook ada', (tester) async {
    await tester.pumpWidget(
      _harness(
        child: const RegisterPage(),
        overrides: [facebookAuthEnabledProvider.overrideWithValue(true)],
      ),
    );
    await _pumpUi(tester);
    expect(find.text('Daftar dengan Facebook'), findsOneWidget);
  });

  testWidgets('409 → FAlert berisi Email sudah terdaftar (login)', (
    tester,
  ) async {
    final usecase = LoginWithFacebookUseCase(
      _StubRepo(
        Either.left(
          const AuthFailure(
            'Email sudah terdaftar. Masuk dengan password atau gunakan lupa password.',
            errorCode: 'EMAIL_ALREADY_EXISTS',
          ),
        ),
      ),
      _StubSignIn(),
    );
    await tester.pumpWidget(
      _harness(
        child: const LoginPage(),
        overrides: [
          facebookAuthEnabledProvider.overrideWithValue(true),
          authLoginWithFacebookUseCaseProvider.overrideWithValue(usecase),
        ],
      ),
    );
    await _pumpUi(tester);
    await tester.tap(find.text('Masuk dengan Facebook'));
    await _pumpUi(tester);
    expect(find.textContaining('Email sudah terdaftar'), findsOneWidget);
  });

  testWidgets('409 → FAlert berisi Email sudah terdaftar (register)', (
    tester,
  ) async {
    final usecase = LoginWithFacebookUseCase(
      _StubRepo(
        Either.left(
          const AuthFailure(
            'Email sudah terdaftar. Masuk dengan password atau gunakan lupa password.',
            errorCode: 'EMAIL_ALREADY_EXISTS',
          ),
        ),
      ),
      _StubSignIn(),
    );
    await tester.pumpWidget(
      _harness(
        child: const RegisterPage(),
        overrides: [
          facebookAuthEnabledProvider.overrideWithValue(true),
          authLoginWithFacebookUseCaseProvider.overrideWithValue(usecase),
        ],
      ),
    );
    await _pumpUi(tester);
    await tester.ensureVisible(find.text('Daftar dengan Facebook'));
    await tester.tap(find.text('Daftar dengan Facebook'));
    await _pumpUi(tester);
    expect(find.textContaining('Email sudah terdaftar'), findsOneWidget);
  });
}
