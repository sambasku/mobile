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
import 'package:sambasku_mobile/shared/widgets/cached_network_image_with_fallback.dart';

class _FakeAuth extends AuthStatusNotifier {
  @override
  Future<AuthStatusState> build() async => const AuthStatusState();
}

Future<void> _pump(WidgetTester tester, FeedActivityItem item) async {
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
        path: '/words/:id',
        builder: (_, _) => const Scaffold(body: Text('kata')),
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
  await tester.pump();
}

void main() {
  testWidgets('menampilkan thumbnail bila previewImageUrl ada', (tester) async {
    const item = FeedActivityItem(
      id: 'word_image:01',
      kind: FeedActivityKind.wordImage,
      createdAt: '2020-01-01T00:00:00.000Z',
      body: 'Menambah foto · "lawang"',
      actor: FeedActivityActor(username: 'budi', displayName: 'Budi'),
      target: FeedActivityTarget(type: 'word', id: 'w1'),
      previewImageUrl: 'https://cdn.example/img.jpg',
    );

    await _pump(tester, item);

    expect(find.byType(CachedNetworkImageWithFallback), findsOneWidget);
  });

  testWidgets('tanpa preview tidak memuat CachedNetworkImageWithFallback', (
    tester,
  ) async {
    const item = FeedActivityItem(
      id: 'word:01',
      kind: FeedActivityKind.word,
      createdAt: '2020-01-01T00:00:00.000Z',
      body: '"lawang"',
      actor: FeedActivityActor(username: 'budi', displayName: 'Budi'),
      target: FeedActivityTarget(type: 'word', id: 'w1'),
    );

    await _pump(tester, item);

    expect(find.byType(CachedNetworkImageWithFallback), findsNothing);
  });
}