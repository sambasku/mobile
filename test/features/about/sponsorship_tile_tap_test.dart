import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/about/data/datasources/contributors_remote_datasource.dart';
import 'package:sambasku_mobile/features/about/data/datasources/sponsors_remote_datasource.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/about_page.dart';
import 'package:sambasku_mobile/features/about/presentation/providers/contributors_providers.dart';
import 'package:sambasku_mobile/features/about/presentation/providers/sponsors_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

const _linked = ContributorEntry(
  id: 'iamutaki',
  username: 'ibnulmutaki',
  name: 'Ibnul Mutaki',
  roles: ['developer', 'maintainer'],
  note: 'Penggagas dan pengelola repositori',
  avatarUrl: null,
  since: '2019-03-01',
);

const _withUrl = ContributorEntry(
  id: 'iamutaki',
  username: 'ibnulmutaki',
  name: 'Ibnul Mutaki',
  roles: ['developer'],
  note: 'Penggagas',
  avatarUrl: null,
  url: 'https://iamutaki.com',
  since: '2019-03-01',
);

const _urlOnly = ContributorEntry(
  id: 'hanapi',
  name: 'Hana Pertiwi',
  roles: ['peneliti'],
  note: 'Riset kosakata',
  avatarUrl: null,
  url: 'https://example.org',
  since: '2020-01-01',
);

const _plain = ContributorEntry(
  id: 'hanapi',
  name: 'Hana Pertiwi',
  roles: ['peneliti'],
  note: 'Riset kosakata',
  avatarUrl: null,
  since: '2020-01-01',
);

/// #100: tile dengan username tap -> profil publik SambasKu;
/// tanpa username -> tile polos (tidak interaktif).
void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    required List<ContributorEntry> contributors,
    required GoRouter router,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contributorsProvider.overrideWith(
            (ref) => Future.value(contributors),
          ),
          sponsorsProvider.overrideWith(
            (ref) => Future.value(<SponsorEntry>[]),
          ),
        ],
        child: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              ...FLocalizations.localizationsDelegates,
            ],
            supportedLocales: const [Locale('id')],
            locale: const Locale('id'),
          ),
        ),
      ),
    );
    // Buka tab Tim Kami (FTabs lazy-build). Pump beberapa frame: provider
    // Future.value + build konten tab.
    await tester.tap(find.text('Tim Kami').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  GoRouter router() => GoRouter(
    initialLocation: '/about/sponsorship',
    routes: [
      GoRoute(
        path: '/about/sponsorship',
        builder: (_, _) => const SponsorshipTeamPage(),
      ),
      // Halaman profil palsu: cukup tandai bahwa route tercapai.
      GoRoute(
        path: '/users/:username',
        name: 'UserProfileRouter.profile',
        builder: (context, state) =>
            Text('PROFILE:${state.pathParameters['username']}'),
      ),
    ],
  );

  testWidgets('tap contributor dengan username -> /users/ibnulmutaki', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpPage(
      tester,
      contributors: const [_linked, _plain],
      router: router(),
    );

    expect(find.text('Ibnul Mutaki'), findsOneWidget);
    await tester.tap(find.text('Ibnul Mutaki'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE:ibnulmutaki'), findsOneWidget);
  });

  testWidgets('tanpa username -> tidak ada InkWell', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpPage(tester, contributors: const [_plain], router: router());

    expect(find.text('Hana Pertiwi'), findsOneWidget);
    // InkWell internal halaman (tab dsb.) boleh ada; tile polos berarti
    // TIDAK ada chevron affordance profil.
    expect(find.byIcon(FLucideIcons.chevronRight), findsNothing);
  });

  // #147: ikon globe buka website via url_launcher (channel dimock).
  group('#147 action website', () {
    final launched = <String>[];

    setUp(() {
      launched.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/url_launcher'),
            (call) async {
              if (call.method == 'launch') {
                launched.add((call.arguments as Map)['url'] as String);
                return true;
              }
              return true;
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/url_launcher'),
            null,
          );
    });

    testWidgets('url terisi -> globe; tap buka browser, bukan profil', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpPage(
        tester,
        contributors: const [_withUrl, _plain],
        router: router(),
      );

      // Hanya tile ber-url yang punya globe.
      expect(find.byIcon(FLucideIcons.globe), findsOneWidget);
      await tester.tap(find.byIcon(FLucideIcons.globe));
      await tester.pumpAndSettle();

      // Link eksternal otomatis ber-UTM (rule external-link-utm).
      expect(launched, [
        'https://iamutaki.com?utm_source=sambasku.com&utm_medium=referral',
      ]);
      expect(find.text('PROFILE:ibnulmutaki'), findsNothing);
    });

    testWidgets('url tanpa username -> globe ada, chevron tidak', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpPage(tester, contributors: const [_urlOnly], router: router());

      expect(find.byIcon(FLucideIcons.globe), findsOneWidget);
      expect(find.byIcon(FLucideIcons.chevronRight), findsNothing);
    });

    testWidgets('tanpa url -> tidak ada globe', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpPage(tester, contributors: const [_plain], router: router());

      expect(find.byIcon(FLucideIcons.globe), findsNothing);
    });
  });
}
