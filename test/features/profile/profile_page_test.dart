import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/core/services/analytics_service.dart';
import 'package:sambasku_mobile/features/auth/data/providers/auth_data_providers.dart';
import 'package:sambasku_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:sambasku_mobile/features/auth/domain/failures/auth_failure.dart';
import 'package:sambasku_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:sambasku_mobile/features/notification/data/providers/notification_data_providers.dart';
import 'package:sambasku_mobile/features/notification/domain/entities/inbox_notification_page.dart';
import 'package:sambasku_mobile/features/notification/domain/failures/notification_failure.dart';
import 'package:sambasku_mobile/features/notification/domain/repositories/notification_repository.dart';
import 'package:sambasku_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<AuthFailure, AuthSession>> login({
    required String email,
    required String password,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGoogle({
    required String idToken,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithFacebook({
    required String accessToken,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, AuthSession>> loginWithGithub({
    required String code,
    required String redirectUri,
    String? codeVerifier,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));


  @override
  Future<Either<AuthFailure, void>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
    required List<({String documentType, String documentVersion})> consents,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, void>> logout() async => Either.right(null);

  @override
  Future<Either<AuthFailure, AuthSession>> verifyEmail({
    required String email,
    required String code,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, void>> resendOtp({required String email}) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, String>> forgotPassword({
    required String email,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));

  @override
  Future<Either<AuthFailure, String>> resetPassword({
    String? token,
    String? email,
    String? code,
    required String newPassword,
  }) async =>
      Either.left(const AuthFailure('tidak dipakai pada test ini'));
}

class _FakeNotificationRepository implements NotificationRepository {
  @override
  Future<Either<NotificationFailure, InboxNotificationPage>> listMine({
    int limit = 20,
    String? cursor,
  }) async =>
      Either.right(const InboxNotificationPage(items: []));

  @override
  Future<Either<NotificationFailure, int>> unreadCount() async =>
      Either.right(0);

  @override
  Future<Either<NotificationFailure, bool>> markRead(String id) async =>
      Either.right(false);

  @override
  Future<Either<NotificationFailure, int>> markAllRead() async =>
      Either.right(0);
}

/// Jangan biarkan Dio menjadwalkan connectTimeout (pending Timer di tes).
class _ThrowingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'mock offline',
      );

  @override
  void close({bool force = false}) {}
}

/// Widget test Profile (mobile-base-stack Section 10): status login vs
/// tamu menentukan tombol "Keluar" / "Masuk / Login", dan logout berfungsi.
void main() {
  setUp(AnalyticsService.debugReset);
  tearDown(AnalyticsService.debugReset);

  Future<void> pumpProfile(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
    Map<String, String> secure = const {},
  }) async {
    // Viewport default 800x600: tile Notifikasi + menu tema mendorong
    // Keluar ke luar cacheExtent. Scrollable.first lalu kena nested
    // FSelectMenuTile, bukan ListView halaman.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(prefs);
    FlutterSecureStorage.setMockInitialValues(secure);
    final throwingDio = Dio()..httpClientAdapter = _ThrowingAdapter();
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Text('halaman login'),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(throwingDio),
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          notificationRepositoryProvider.overrideWithValue(
            _FakeNotificationRepository(),
          ),
        ],
        child: MaterialApp.router(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => FTheme(
            data: FThemes.zinc.light.touch,
            child: FToaster(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('tamu - menampilkan ajakan masuk dan daftar tanpa tombol Keluar', (
    tester,
  ) async {
    await pumpProfile(tester);

    expect(find.text('Belum masuk'), findsOneWidget);
    expect(find.text('Masuk / Login'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
    expect(find.text('Laporkan Masalah'), findsOneWidget);
    expect(find.text('Keluar'), findsNothing);
  });

  testWidgets('sudah login - tombol Keluar tampil dan logout ke /login', (
    tester,
  ) async {
    // getIsAuth() = prefs isAuth + access token di secure storage.
    await pumpProfile(
      tester,
      prefs: {
        'isAuth': true,
        'sessionUsername': 'budi',
        'sessionRole': 'contributor',
      },
      secure: {
        'accessToken': 'test-access',
        'refreshToken': 'test-refresh',
      },
    );

    expect(find.text('budi'), findsOneWidget);
    expect(find.text('Tinjau usulan'), findsNothing);
    expect(find.text('Masuk / Login'), findsNothing);
    expect(find.text('Daftar'), findsNothing);
    expect(find.text('Keluar'), findsOneWidget);

    await tester.tap(find.text('Keluar'));
    await tester.pump();
    // Forui FTappable: pressedEnter/Exit = Future.delayed 100ms.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('halaman login'), findsOneWidget);
    expect(find.text('Keluar'), findsNothing);
  });

  testWidgets('sudah login - tile Vote dan Komentar membuka route', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({
      'isAuth': true,
      'sessionUsername': 'budi',
      'sessionRole': 'contributor',
    });
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'test-access',
      'refreshToken': 'test-refresh',
    });

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const ProfilePage()),
        GoRoute(path: '/votes', builder: (context, state) => const Text('halaman vote')),
        GoRoute(
          path: '/comments',
          builder: (context, state) => const Text('halaman komentar'),
        ),
        GoRoute(path: '/login', builder: (context, state) => const SizedBox()),
        GoRoute(path: '/contributions', builder: (context, state) => const SizedBox()),
        GoRoute(path: '/bookmarks', builder: (context, state) => const SizedBox()),
        GoRoute(path: '/report-bug', builder: (context, state) => const SizedBox()),
        GoRoute(path: '/notifications', builder: (context, state) => const SizedBox()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dioProvider.overrideWithValue(Dio()..httpClientAdapter = _ThrowingAdapter()),
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          notificationRepositoryProvider.overrideWithValue(
            _FakeNotificationRepository(),
          ),
        ],
        child: MaterialApp.router(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => FTheme(
            data: FThemes.zinc.light.touch,
            child: child!,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Vote'), findsOneWidget);
    await tester.tap(find.text('Vote'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('halaman vote'), findsOneWidget);
    expect(find.textContaining('segera hadir'), findsNothing);

    router.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Komentar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('halaman komentar'), findsOneWidget);
  });
}
