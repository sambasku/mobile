import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/my_votes/data/providers/my_vote_data_providers.dart';
import 'package:sambasku_mobile/features/my_votes/domain/entities/my_vote_item.dart';
import 'package:sambasku_mobile/features/my_votes/domain/entities/my_vote_page.dart';
import 'package:sambasku_mobile/features/my_votes/domain/failures/my_vote_failure.dart';
import 'package:sambasku_mobile/features/my_votes/domain/repositories/my_vote_repository.dart';
import 'package:sambasku_mobile/features/my_votes/presentation/pages/my_votes_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';

class _FakeVotes implements MyVoteRepository {
  _FakeVotes(this._result);

  final Either<MyVoteFailure, MyVotePage> _result;
  int calls = 0;

  @override
  Future<Either<MyVoteFailure, MyVotePage>> listHistory({
    int limit = 20,
    String? cursor,
  }) async {
    calls++;
    return _result;
  }
}

void main() {
  Future<GoRouter> pump(
    WidgetTester tester, {
    required MyVoteRepository repo,
  }) async {
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
      initialLocation: '/votes',
      routes: [
        GoRoute(
          path: '/votes',
          builder: (context, state) => const MyVotesPage(),
        ),
        GoRoute(
          path: '/words/:id',
          builder: (context, state) => Text('kata ${state.pathParameters['id']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          myVoteRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp.router(
          theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: child!,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return router;
  }

  testWidgets('kosong menampilkan Belum ada vote', (tester) async {
    await pump(
      tester,
      repo: _FakeVotes(
        Either.right(const MyVotePage(items: [], nextCursor: null, hasMore: false)),
      ),
    );
    expect(find.text('Belum ada vote'), findsOneWidget);
  });

  testWidgets('error menampilkan pesan dan coba lagi memuat ulang', (tester) async {
    final repo = _FakeVotes(Either.left(MyVoteFailure('jaringan putus')));
    await pump(tester, repo: repo);
    expect(find.text('jaringan putus'), findsOneWidget);

    await tester.tap(find.text('Coba lagi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(repo.calls, greaterThan(1));
  });

  testWidgets('tap lemma membuka detail kata; kata hilang tidak navigasi', (
    tester,
  ) async {
    const live = MyVoteItem(
      id: '01VOTELIVE0000000000000001',
      targetType: 'word',
      targetId: '01WORDLIVE000000000000001',
      value: 1,
      votedAt: '2026-09-21T10:00:00.000Z',
      word: MyVoteWord(
        id: '01WORDLIVE000000000000001',
        lemma: 'makatn',
        wordType: 'lemma',
        isVerified: true,
      ),
    );
    const dead = MyVoteItem(
      id: '01VOTEDEAD0000000000000002',
      targetType: 'word',
      targetId: '01WORDDEAD000000000000002',
      value: -1,
      votedAt: '2026-09-21T09:00:00.000Z',
      word: null,
    );
    final router = await pump(
      tester,
      repo: _FakeVotes(
        Either.right(
          const MyVotePage(items: [live, dead], nextCursor: null, hasMore: false),
        ),
      ),
    );

    expect(find.text('Kata sudah dihapus'), findsOneWidget);
    await tester.tap(find.text('Kata sudah dihapus'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(router.routeInformationProvider.value.uri.path, '/votes');

    await tester.tap(find.text('makatn'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('kata 01WORDLIVE000000000000001'), findsOneWidget);
  });
}
