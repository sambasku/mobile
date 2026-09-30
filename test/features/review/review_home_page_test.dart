import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/dictionary/dictionary_router.dart';
import 'package:sambasku_mobile/features/review/presentation/pages/review_home_page.dart';
import 'package:sambasku_mobile/features/review/presentation/providers/discussion_review_providers.dart';
import 'package:sambasku_mobile/features/review/presentation/providers/review_providers.dart';
import 'package:sambasku_mobile/features/review/presentation/providers/review_suggestions_providers.dart';

void main() {
  // Gate tile mengikuti canReviewQueue, sama seperti tile antrean lain:
  // editor punya wewenang verifikasi tapi tidak memegang antrean, jadi
  // "Lengkapi kata" juga tidak ditunjukkan ke sana lewat hub ini.
  for (final role in ['admin', 'reviewer', 'root']) {
    testWidgets('$role melihat tile "Lengkapi kata"', (tester) async {
      await pumpHome(tester, role);
      expect(find.widgetWithText(FTile, 'Lengkapi kata'), findsOneWidget);
    });
  }

  for (final role in ['contributor', 'editor']) {
    testWidgets('$role tidak melihat tile "Lengkapi kata"', (tester) async {
      await pumpHome(tester, role);
      expect(find.widgetWithText(FTile, 'Lengkapi kata'), findsNothing);
    });
  }

  testWidgets('tanpa role (tamu) tidak melihat tile', (tester) async {
    await pumpHome(tester, null);
    expect(find.widgetWithText(FTile, 'Lengkapi kata'), findsNothing);
  });

  testWidgets('tile menampilkan kapabilitas yang bisa ditambah', (
    tester,
  ) async {
    await pumpHome(tester, 'reviewer');
    expect(find.textContaining('makna'), findsOneWidget);
    expect(find.textContaining('pelafalan'), findsOneWidget);
  });

  testWidgets('tap tile membuka pemilih kata', (tester) async {
    final router = await pumpHome(tester, 'reviewer');

    await tester.tap(find.widgetWithText(FTile, 'Lengkapi kata'));
    await tester.pumpAndSettle();

    // routeInformationProvider tidak mencerminkan push imperatif, jadi
    // Asersi lewat konfigurasi router yang benar-benar dipakai.
    expect(find.text('pemilih kata'), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.matches.map(
        (m) => m.matchedLocation,
      ),
      contains(DictionaryRouter.complete.path),
    );
  });
}

Future<GoRouter> pumpHome(WidgetTester tester, String? role) async {
  final router = GoRouter(
    initialLocation: '/review',
    routes: [
      GoRoute(path: '/review', builder: (_, _) => const ReviewHomePage()),
      GoRoute(
        path: DictionaryRouter.complete.path,
        builder: (_, _) => const Scaffold(body: Text('pemilih kata')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStatusProvider.overrideWith(() => _FakeAuthStatus(role)),
        // Hilangkan panggilan jaringan: hub hanya butuh badge "ada antrean".
        reviewQueueHasPendingProvider.overrideWith((ref) async => false),
        reviewSuggestionsHasPendingProvider.overrideWith((ref) async => false),
        discussionReviewHasPendingProvider.overrideWith((ref) async => false),
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
  return router;
}

class _FakeAuthStatus extends AuthStatusNotifier {
  _FakeAuthStatus(this.role);

  final String? role;

  @override
  Future<AuthStatusState> build() async =>
      AuthStatusState(isAuth: role != null, username: 'tester', role: role);
}
