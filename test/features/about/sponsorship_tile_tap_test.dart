import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/about/data/datasources/contributors_remote_datasource.dart';
import 'package:sambasku_mobile/features/about/data/datasources/sponsors_remote_datasource.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/about_page.dart';
import 'package:sambasku_mobile/features/about/presentation/providers/contributors_providers.dart';
import 'package:sambasku_mobile/features/about/presentation/providers/sponsors_providers.dart';

const _linked = ContributorEntry(
  id: 'iamutaki',
  sambaskuUsername: 'ibnulmutaki',
  name: 'Ibnul Mutaki',
  roles: ['developer', 'maintainer'],
  note: 'Penggagas dan pengelola repositori',
  avatarUrl: null,
  since: '2019-03-01',
);

const _plain = ContributorEntry(
  id: 'hanapi',
  name: 'Hana Pertiwi',
  roles: ['peneliti'],
  note: 'Riset kosakata',
  avatarUrl: null,
  since: '2020-01-01',
);

/// #100: tile dengan sambaskuUsername tap -> profil publik SambasKu;
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
          data: FThemes.zinc.light.touch,
          child: MaterialApp.router(routerConfig: router),
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

  testWidgets('tap contributor dengan sambaskuUsername -> /users/ibnulmutaki', (
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

  testWidgets('tanpa sambaskuUsername -> tidak ada InkWell', (tester) async {
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
}
