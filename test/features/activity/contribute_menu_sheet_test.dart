import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/pages/activity_page.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/activity_feed_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/contribution_guide_providers.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/home_search_page.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/providers/word_of_day_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

/// Hub Kontribusi: chip baris Home-style (Dicari warga, Periksa kata) push route.
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
          contributionGuideUnreadProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp.router(
          theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            ...FLocalizations.localizationsDelegates,
          ],
          supportedLocales: const [Locale('id')],
          locale: const Locale('id'),
          routerConfig: router,
          builder: (context, child) =>
              FTheme(data: foruiPalettes['zinc']!.light.touch, child: child!),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    return pushed;
  }

  testWidgets('grid menampilkan Dicari warga dan Periksa kata', (tester) async {
    await pump(tester);

    expect(find.text('Menu kontribusi'), findsNothing);
    expect(find.text('Dicari warga'), findsOneWidget);
    expect(find.text('Periksa kata'), findsOneWidget);
  });

  testWidgets('tap Dicari warga mendorong /search-misses', (tester) async {
    final pushed = await pump(tester);

    await tester.tap(find.text('Dicari warga'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(pushed, ['/search-misses']);
    expect(find.text('target /search-misses'), findsOneWidget);
  });

  testWidgets('tap Periksa kata mendorong /periksa-kata', (tester) async {
    final pushed = await pump(tester);

    await tester.tap(find.text('Periksa kata'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(pushed, ['/periksa-kata']);
    expect(find.text('target /periksa-kata'), findsOneWidget);
  });

  testWidgets(
    'posisi ActionChipsRow di Kontribusi identik dengan Home (tanpa lompat)',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      Widget wrap(Widget child) => ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          contributionGuideUnreadProvider.overrideWith((ref) async => false),
          activityFeedProvider.overrideWith2(
            (category) => _EmptyFeedNotifier(category),
          ),
          wordOfDayProvider.overrideWith((ref) async => null),
        ],
        child: MaterialApp(
          theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            ...FLocalizations.localizationsDelegates,
          ],
          supportedLocales: const [Locale('id')],
          locale: const Locale('id'),
          builder: (context, c) =>
              FTheme(data: foruiPalettes['zinc']!.light.touch, child: c!),
          home: FScaffold(childPad: false, child: child),
        ),
      );

      await tester.pumpWidget(wrap(const HomeSearchPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final homeRowRect = tester.getRect(
        find.byKey(const ValueKey('action_chips_row')),
      );
      final homeFirstChip = tester.getTopLeft(find.text('Dicari warga'));

      await tester.pumpWidget(wrap(const ActivityPage()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final activityRowRect = tester.getRect(
        find.byKey(const ValueKey('action_chips_row')),
      );
      final activityFirstChip = tester.getTopLeft(find.text('Dicari warga'));

      expect(activityRowRect, homeRowRect);
      expect(activityFirstChip, homeFirstChip);
    },
  );
}

class _EmptyFeedNotifier extends ActivityFeedNotifier {
  _EmptyFeedNotifier(super.category);

  @override
  ActivityFeedState build() => const ActivityFeedState(hasLoaded: true);
}
