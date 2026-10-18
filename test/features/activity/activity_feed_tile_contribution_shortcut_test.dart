import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/widgets/activity_feed_tile.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';

class _FakeAuth extends AuthStatusNotifier {
  _FakeAuth(this.authState);

  final AuthStatusState authState;

  @override
  Future<AuthStatusState> build() async => authState;
}

/// Baris feed usulan kata baru (kind wire `contribution`).
FeedActivityItem _usulanItem({String? status}) {
  // #166: tile feed usulan kata baru (kind wire 'contribution').
  // Untuk tested published, gunakan kind 'word' biasa.
  return FeedActivityItem(
    id: 'contribution:01USUL',
    kind: FeedActivityKind.contribution,
    createdAt: DateTime.now().toIso8601String(),
    body: 'Mengusulkan kata baru · "usul166"',
    subtitle: 'Usulan kata baru',
    target: FeedActivityTarget(
      type: 'word',
      id: '01USULWORD000000000000',
      status: status,
    ),
  );
}

Future<GoRouter> _pump(
  WidgetTester tester,
  ProviderContainer container,
  FeedActivityItem item,
) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: ActivityFeedTile(item: item)),
      ),
      GoRoute(
        path: '/words/:id',
        builder: (_, s) => Scaffold(
          body: Text('detail kata ${s.pathParameters['id']}'),
        ),
      ),
      GoRoute(
        path: '/review/queue',
        builder: (_, s) => Scaffold(
          body: Text('antrean review ${s.uri.queryParameters['wordId']}'),
        ),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => FTheme(
          data: FThemes.zinc.light.touch,
          child: FToaster(child: child!),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

String? _currentLocation(GoRouter router) =>
    router.routerDelegate.currentConfiguration.matches
        .map((m) => m.matchedLocation)
        .last;

void main() {
  testWidgets(
    '#166 usulan pending + verifikator: CTA Tinjau usulan → /review/queue?wordId',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authStatusProvider.overrideWith(
            () => _FakeAuth(
              const AuthStatusState(isAuth: true, role: 'admin'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = await _pump(
        tester,
        container,
        _usulanItem(status: 'pending_review'),
      );

      expect(find.text('Tinjau usulan'), findsOneWidget);

      await tester.tap(find.text('Tinjau usulan'));
      await tester.pumpAndSettle();

      expect(_currentLocation(router), '/review/queue');
      expect(find.text('antrean review 01USULWORD000000000000'), findsOneWidget);
    },
  );

  testWidgets(
    '#166 usulan pending + tamu: toast menunggu tinjauan, tanpa navigasi',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authStatusProvider.overrideWith(
            () => _FakeAuth(const AuthStatusState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = await _pump(
        tester,
        container,
        _usulanItem(status: 'pending_review'),
      );

      // Tanpa CTA (bukan verifikator), tapi baris tetap bisa ditap.
      expect(find.text('Tinjau usulan'), findsNothing);
      expect(find.text('Lihat kata'), findsNothing);

      // Body = Text.rich multi-span (lemma bold); tap baris tile-nya.
      await tester.tap(find.byType(ActivityFeedTile));
      await tester.pumpAndSettle();

      expect(
        find.text('Kata ini masih menunggu tinjauan verifikator'),
        findsOneWidget,
      );
      expect(_currentLocation(router), '/');
    },
  );

  testWidgets(
    '#166 usulan published: tetap ke detail kata publik',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authStatusProvider.overrideWith(
            () => _FakeAuth(const AuthStatusState()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = await _pump(
        tester,
        container,
        _usulanItem(status: null),
      );

      expect(find.text('Lihat kata'), findsOneWidget);

      await tester.tap(find.text('Lihat kata'));
      await tester.pumpAndSettle();

      expect(_currentLocation(router!), '/words/01USULWORD000000000000');
    },
  );
}
