import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/dictionary/data/providers/dictionary_data_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/word_detail_page.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

const _wordId = '01CCCCCCCCCCCCCCCCCCCCCCCC';

WordDetail _detailWithMeanings(List<WordMeaning> meanings) => WordDetail(
  id: _wordId,
  lemma: 'apam',
  languageId: 'lang-1',
  wordType: 'word',
  status: 'published',
  isVerified: true,
  isCorrected: false,
  meanings: meanings,
);

class _StubRepo implements DictionaryRepository {
  _StubRepo(this.meanings);

  final List<WordMeaning> meanings;

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
    String? focusMeaningId,
    bool includeUnverified = false,
  }) async => Either.right(_detailWithMeanings(meanings));

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
    String? focusMeaningId,
    bool includeUnverified = false,
  }) async => Either.right(_detailWithMeanings(meanings));

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async => Either.right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeAuthStatus extends AuthStatusNotifier {
  _FakeAuthStatus(this._isAuth);

  final bool _isAuth;

  @override
  Future<AuthStatusState> build() async => AuthStatusState(
    isAuth: _isAuth,
    username: _isAuth ? 'budi' : null,
    role: _isAuth ? 'user' : null,
    userId: _isAuth ? 'u1' : null,
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required List<WordMeaning> meanings,
  required bool isAuth,
  required List<String> pushedRoutes,
}) async {
  tester.view.physicalSize = const Size(400, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/words/$_wordId',
    routes: [
      GoRoute(
        path: '/words/:id',
        builder: (context, state) =>
            WordDetailPage(wordId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/suggest-edit/:wordId',
        builder: (context, state) {
          pushedRoutes.add(state.uri.toString());
          return const Scaffold(body: Text('SUGGEST_EDIT_PAGE'));
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          pushedRoutes.add(state.uri.toString());
          return const Scaffold(body: Text('LOGIN_PAGE'));
        },
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dictionaryRepositoryProvider.overrideWithValue(_StubRepo(meanings)),
        authStatusProvider.overrideWith(() => _FakeAuthStatus(isAuth)),
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
        builder: (context, child) => FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: FToaster(child: child!),
        ),
      ),
    ),
  );

  await tester.runAsync(() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  const m1 = WordMeaning(
    id: 'm1',
    orderIndex: 1,
    wordClassCode: 'n',
    definition: 'Kue tradisional dari tepung beras.',
    translations: [WordTranslation(text: 'apam', type: 'direct')],
    examples: [
      WordExample(
        id: 'e1',
        sourceSentence: 'Makan apam pagi hari.',
        targetSentence: 'Makan apam di pagi hari.',
      ),
    ],
    isVerified: true,
  );
  const m2 = WordMeaning(
    id: 'm2',
    orderIndex: 2,
    wordClassCode: 'n',
    definition: 'Sebutan kue kukus manis.',
    translations: [WordTranslation(text: 'kue kukus', type: 'direct')],
    isVerified: true,
  );

  testWidgets('satu makna: label MAKNA + CTA Usulkan makna baru menuju add_meaning', (
    tester,
  ) async {
    final pushed = <String>[];
    await _pump(tester, meanings: const [m1], isAuth: true, pushedRoutes: pushed);

    expect(tester.takeException(), isNull);
    expect(find.text('MAKNA'), findsOneWidget);
    expect(find.text('→ apam'), findsOneWidget);
    expect(find.text('Makan apam pagi hari.'), findsOneWidget);
    expect(find.text('Usulkan makna baru'), findsOneWidget);

    await tester.tap(find.text('Usulkan makna baru'));
    await tester.pumpAndSettle();

    expect(pushed, ['/suggest-edit/$_wordId?category=add_meaning']);
  });

  testWidgets('multi makna: label MAKNA (2) + FDivider pemisah antar makna', (
    tester,
  ) async {
    final pushed = <String>[];
    await _pump(
      tester,
      meanings: const [m1, m2],
      isAuth: true,
      pushedRoutes: pushed,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('MAKNA (2)'), findsOneWidget);
    expect(find.byType(FDivider), findsAtLeastNWidgets(1));
  });

  testWidgets('guest tap CTA Usulkan makna baru diarahkan ke login', (
    tester,
  ) async {
    final pushed = <String>[];
    await _pump(tester, meanings: const [m1], isAuth: false, pushedRoutes: pushed);

    await tester.tap(find.text('Usulkan makna baru'));
    await tester.pumpAndSettle();

    expect(pushed, ['/login']);
  });
}
