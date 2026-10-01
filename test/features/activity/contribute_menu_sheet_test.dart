import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/pages/activity_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Menu kontribusi (bottom sheet di navigator root) tidak boleh balapan
/// pop+push: tepat satu push per pilihan, tap kedua saat animasi pop
/// diabaikan, dismiss barrier tidak mendorong apa pun.
void main() {
  Future<List<String>> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    final pushed = <String>[];
    final router = GoRouter(
      initialLocation: '/action',
      routes: [
        GoRoute(
          path: '/action',
          builder: (context, state) => const ActivityPage(),
        ),
        GoRoute(
          path: '/:p(.*)',
          builder: (context, state) {
            pushed.add(state.matchedLocation);
            return Text('target ${state.matchedLocation}');
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
        ],
        child: MaterialApp.router(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) =>
              FTheme(data: FThemes.zinc.light.touch, child: child!),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return pushed;
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('Menu kontribusi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Usul kata baru'), findsOneWidget);
  }

  testWidgets('pilih tile mendorong tepat satu route', (tester) async {
    final pushed = await pump(tester);
    await openSheet(tester);

    await tester.tap(find.text('Usul kata baru'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(pushed, ['/contribute']);
    expect(find.text('target /contribute'), findsOneWidget);
  });

  testWidgets('double-tap tile saat animasi pop tetap satu push', (
    tester,
  ) async {
    final pushed = await pump(tester);
    await openSheet(tester);

    await tester.tap(find.text('Usul kata baru'));
    // Tile masih hidup sesaat selama animasi exit sheet.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Usul kata baru'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(pushed, ['/contribute']);
    expect(find.text('target /contribute'), findsOneWidget);
  });

  testWidgets('dismiss barrier tidak mendorong route', (tester) async {
    final pushed = await pump(tester);
    await openSheet(tester);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    // Jangan pumpAndSettle: skeleton guest deck berdenyut terus saat
    // ActivityPage kembali jadi halaman current.
    await tester.pump(const Duration(milliseconds: 300));

    expect(pushed, isEmpty);
    expect(find.text('Menu kontribusi'), findsOneWidget);
  });
}
