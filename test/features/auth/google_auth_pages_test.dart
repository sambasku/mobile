import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/ports/google_sign_in_port.dart';
import 'package:sambasku_mobile/features/auth/domain/providers/auth_domain_providers.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/auth/domain/usecases/login_with_google_use_case.dart';
import 'package:sambasku_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:sambasku_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_login_providers.dart';
import 'package:sambasku_mobile/flavors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

/// Dio stub: register page mem-fetch /legal/current untuk gembok checkbox.
Dio _stubDio() => Dio(BaseOptions())
  ..httpClientAdapter = _LegalCurrentAdapter();

/// Adapter minimal: GET /legal/current -> versi aktif; endpoint lain 404.
class _LegalCurrentAdapter implements HttpClientAdapter {
  static const _body =
      '{"data":{"terms":{"version":"2026-01-01"},"privacy":{"version":"2026-01-01"}}}';

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.uri.path.endsWith('/legal/current')) {
      return ResponseBody.fromString(_body, 200, headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      });
    }
    return ResponseBody.fromString('{"message":"stub"}', 404);
  }
}

class _StubSignIn implements GoogleSignInPort {
  @override
  Future<String?> authenticate() async => 'id-token';
}

class _StubRepo implements AuthRepository {
  _StubRepo(this.googleResult);
  final Either<AuthFailure, AuthSession> googleResult;

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
      List<({String documentType, String documentVersion})>? consents,
}) async => googleResult;

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
      List<({String documentType, String documentVersion})>? consents,
}) async => Either.left(const AuthFailure('tidak dipakai'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGithub({
    required String code,
    required String redirectUri,
    String? codeVerifier,
      List<({String documentType, String documentVersion})>? consents,
}) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));


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
      overrides: [
        dioProvider.overrideWithValue(_stubDio()),
        ...overrides.cast(),
      ],
    child: MaterialApp.router(
      theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, routed) => FTheme(
        data: foruiPalettes['zinc']!.light.touch,
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

  testWidgets('GOOGLE_WEB_CLIENT_ID kosong → tombol Google tidak ada', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        child: const LoginPage(),
        overrides: [googleAuthEnabledProvider.overrideWithValue(false)],
      ),
    );
    await _pumpUi(tester);
    expect(find.bySemanticsLabel('Masuk dengan Google'), findsNothing);
  });

  testWidgets('client ID terisi → tombol Masuk dengan Google ada', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        child: const LoginPage(),
        overrides: [googleAuthEnabledProvider.overrideWithValue(true)],
      ),
    );
    await _pumpUi(tester);
    // Icon-only: label ada di Semantics, bukan Text terlihat.
    expect(find.bySemanticsLabel('Masuk dengan Google'), findsOneWidget);
  });

  testWidgets('register: tombol Daftar dengan Google ada', (tester) async {
    await tester.pumpWidget(
      _harness(
        child: const RegisterPage(),
        overrides: [googleAuthEnabledProvider.overrideWithValue(true)],
      ),
    );
    await _pumpUi(tester);
    expect(find.bySemanticsLabel('Daftar dengan Google'), findsOneWidget);
  });

  testWidgets('409 → FAlert berisi Email sudah terdaftar (login)', (
    tester,
  ) async {
    final usecase = LoginWithGoogleUseCase(
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
          googleAuthEnabledProvider.overrideWithValue(true),
          authLoginWithGoogleUseCaseProvider.overrideWithValue(usecase),
        ],
      ),
    );
    await _pumpUi(tester);
    final google = find.bySemanticsLabel('Masuk dengan Google');
    await tester.ensureVisible(google);
    await tester.tap(google);
    await _pumpUi(tester);
    expect(find.textContaining('Email sudah terdaftar'), findsOneWidget);
  });

  testWidgets('409 → FAlert berisi Email sudah terdaftar (register)', (
    tester,
  ) async {
    final usecase = LoginWithGoogleUseCase(
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
          googleAuthEnabledProvider.overrideWithValue(true),
          authLoginWithGoogleUseCaseProvider.overrideWithValue(usecase),
        ],
      ),
    );
    await _pumpUi(tester);
    // Register mengunci tombol sosial sampai checkbox legal dicentang.
    // Checkbox di bawah viewport - scroll dulu.
    await tester.ensureVisible(find.byType(FCheckbox));
    await _pumpUi(tester);
    await tester.tap(find.byType(FCheckbox));
    await _pumpUi(tester);
    final google = find.bySemanticsLabel('Daftar dengan Google');
    await tester.ensureVisible(google);
    await tester.tap(google);
    await _pumpUi(tester);
    expect(find.textContaining('Email sudah terdaftar'), findsOneWidget);
  });
}
