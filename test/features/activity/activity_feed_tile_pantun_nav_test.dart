import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/widgets/activity_feed_tile.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

class _FakeAuth extends AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async => const AuthStatusState();
}

FeedActivityItem _pantunItem({
  required FeedActivityKind kind,
  required String targetType,
  required String body,
  required String pantunId,
}) {
  return FeedActivityItem(
    id: 'pantun:01EVENT',
    kind: kind,
    createdAt: DateTime.now().toIso8601String(),
    body: body,
    subtitle: null,
    actor: const FeedActivityActor(username: 'budi', displayName: 'Budi'),
    target: FeedActivityTarget(type: targetType, id: pantunId),
  );
}

Future<GoRouter> _pump(
  WidgetTester tester,
  FeedActivityItem item,
) async {
  final container = ProviderContainer(
    overrides: [authStatusProvider.overrideWith(_FakeAuth.new)],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: ActivityFeedTile(item: item)),
      ),
      GoRoute(
        path: '/entertainment/pantun/:id',
        builder: (_, s) =>
            Scaffold(body: Text('pantun detail ${s.pathParameters['id']}')),
      ),
      GoRoute(
        path: '/discussions/:id',
        builder: (_, s) =>
            Scaffold(body: Text('diskusi ${s.pathParameters['id']}')),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        routerConfig: router,
        builder: (context, child) => FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: FToaster(child: child!),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

String? _currentLocation(GoRouter router) => router
    .routerDelegate
    .currentConfiguration
    .matches
    .map((m) => m.matchedLocation)
    .last;

void main() {
  const pantunId = '01PANTUN000000000000000';

  testWidgets('wire pantun + target.pantun → detail pantun', (tester) async {
    final router = await _pump(
      tester,
      _pantunItem(
        kind: FeedActivityKind.pantun,
        targetType: 'pantun',
        body: 'Membalas pantun',
        pantunId: pantunId,
      ),
    );

    expect(find.text('Lihat pantun'), findsOneWidget);
    await tester.tap(find.text('Lihat pantun'));
    await tester.pumpAndSettle();

    expect(_currentLocation(router), '/entertainment/pantun/$pantunId');
    expect(find.text('pantun detail $pantunId'), findsOneWidget);
    expect(find.textContaining('diskusi'), findsNothing);
  });

  testWidgets(
    'wire lama discussion + body Membalas pantun → detail pantun (fallback)',
    (tester) async {
      final router = await _pump(
        tester,
        _pantunItem(
          kind: FeedActivityKind.discussion,
          targetType: 'discussion',
          body: 'Membalas pantun',
          pantunId: pantunId,
        ),
      );

      await tester.tap(find.text('Ikut diskusi'));
      await tester.pumpAndSettle();

      expect(_currentLocation(router), '/entertainment/pantun/$pantunId');
      expect(find.text('pantun detail $pantunId'), findsOneWidget);
    },
  );
}
