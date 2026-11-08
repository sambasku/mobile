import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/about/data/datasources/about_api_datasource.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/about_page.dart';
import 'package:sambasku_mobile/features/about/presentation/providers/about_api_providers.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

const _team = AboutTeamMember(
  username: 'ibnulmutaki',
  displayName: 'Ibnul Mutaki',
  teamAs: 'maintainer',
  teamNote: 'Penggagas',
);

const _contributor = AboutContributorName(username: 'ali', displayName: 'Ali');

const _verifier = AboutVerifier(username: 'fatimah', displayName: 'Fatimah');

const _sponsorWithUrl = AboutSponsorship(
  id: '1',
  name: 'JNN',
  since: '2026-10-12',
  note: 'Domain',
  url: 'https://example.org',
);

void main() {
  Future<void> pumpSponsorshipPage(
    WidgetTester tester, {
    required GoRouter router,
    List<AboutTeamMember> team = const [],
    List<AboutContributorName> contributors = const [],
    List<AboutVerifier> verifiers = const [],
    List<AboutSponsorship> sponsorships = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aboutTeamProvider.overrideWith((ref) async => team),
          aboutVerifiersProvider.overrideWith((ref) async => verifiers),
          aboutSponsorshipsProvider.overrideWith((ref) async => sponsorships),
          aboutContributorsProvider.overrideWith(
            () => _FakeContributors(contributors),
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
  }

  GoRouter router() => GoRouter(
    initialLocation: '/about/sponsorship',
    routes: [
      GoRoute(
        path: '/about/sponsorship',
        builder: (_, _) => const SponsorshipTeamPage(),
      ),
      GoRoute(
        path: '/about/contributors',
        builder: (_, _) => const ContributorsListPage(),
      ),
      GoRoute(
        path: '/users/:username',
        name: 'UserProfileRouter.profile',
        builder: (context, state) =>
            Text('PROFILE:${state.pathParameters['username']}'),
      ),
    ],
  );

  testWidgets('tap inti tim -> profil', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSponsorshipPage(tester, router: router(), team: const [_team]);
    await tester.tap(find.text('Tim Kami').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Tim Inti'), findsOneWidget);
    expect(find.text('Ibnul Mutaki'), findsOneWidget);
    await tester.tap(find.text('Ibnul Mutaki'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE:ibnulmutaki'), findsOneWidget);
  });

  testWidgets('tap nama kontributor flat -> profil', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSponsorshipPage(
      tester,
      router: router(),
      contributors: const [_contributor],
    );
    await tester.tap(find.text('Tim Kami').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Ali'), findsNothing);
    expect(find.text('Kontributor'), findsOneWidget);
    await tester.tap(find.text('Kontributor'));
    await tester.pumpAndSettle();

    expect(find.text('Ali'), findsOneWidget);
    await tester.tap(find.text('Ali'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE:ali'), findsOneWidget);
  });

  testWidgets('tap verifikator -> profil', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpSponsorshipPage(
      tester,
      router: router(),
      verifiers: const [_verifier],
    );
    await tester.tap(find.text('Tim Kami').last);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('Fatimah'), findsOneWidget);
    await tester.tap(find.text('Fatimah'));
    await tester.pumpAndSettle();
    expect(find.text('PROFILE:fatimah'), findsOneWidget);
  });

  group('sponsor website', () {
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

    testWidgets('tap globe sponsor buka browser', (tester) async {
      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpSponsorshipPage(
        tester,
        router: router(),
        sponsorships: const [_sponsorWithUrl],
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byIcon(FLucideIcons.globe), findsOneWidget);
      await tester.tap(find.byIcon(FLucideIcons.globe));
      await tester.pumpAndSettle();
      expect(launched, [
        'https://example.org?utm_source=sambasku.com&utm_medium=referral',
      ]);
    });
  });
}

class _FakeContributors extends AboutContributors {
  _FakeContributors(this.items);

  final List<AboutContributorName> items;

  @override
  Future<AboutContributorsState?> build() async {
    return AboutContributorsState(
      items: items,
      total: items.length,
      hasMore: false,
    );
  }
}
