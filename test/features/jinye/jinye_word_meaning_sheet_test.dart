import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/dictionary/data/providers/dictionary_data_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_summary.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/jinye/domain/jinye_models.dart';
import 'package:sambasku_mobile/features/jinye/presentation/widgets/jinye_link_lemma_sheet.dart';
import 'package:sambasku_mobile/features/jinye/presentation/widgets/jinye_word_meaning_sheet.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

const _wordId = '01BBBBBBBBBBBBBBBBBBBBBBBB';

WordDetail _wordDetail() => const WordDetail(
  id: _wordId,
  lemma: 'apam',
  languageId: 'lang-1',
  wordType: 'word',
  status: 'published',
  isVerified: true,
  isCorrected: false,
  meanings: [
    WordMeaning(
      id: 'm1',
      orderIndex: 1,
      definition: 'Kue tradisional dari tepung beras.',
      translations: [WordTranslation(text: 'apam', type: 'direct')],
      isVerified: true,
    ),
  ],
);

class _StubDictionaryRepo implements DictionaryRepository {
  _StubDictionaryRepo({required this.found});

  final bool found;

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
    String? focusMeaningId,
    bool includeUnverified = false,
  }) async => found
      ? Either.right(_wordDetail())
      : Either.left(const DictionaryFailure('Not found'));

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
    String? focusMeaningId,
    bool includeUnverified = false,
  }) async => found
      ? Either.right(_wordDetail())
      : Either.left(const DictionaryFailure('Not found'));

  @override
  Future<Either<DictionaryFailure, WordSearchPage>> searchWords({
    required String query,
    required int limit,
    String? cursor,
    String searchIn = 'lemma',
    bool recordMiss = true,
    CancelToken? cancelToken,
  }) async => Either.right(
    const WordSearchPage(
      items: [],
      hasMore: false,
    ),
  );

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async => Either.right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _pumpAndOpenSheet(
  WidgetTester tester, {
  required bool found,
  required bool isAuth,
  JinyeLemmaLink? link,
  required List<String> pushedRoutes,
}) async {
  // Viewport sempit 360px untuk memastikan tombol 2-kolom tidak overflow.
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: Center(
            child: FButton(
              onPress: () async {
                final result = await showJinyeWordMeaningSheet(
                  context,
                  jinyeId: 'jinye-1',
                  span: const JinyeSpanSelection(
                    start: 0,
                    end: 4,
                    text: 'apam',
                  ),
                  link: link,
                  isAuth: isAuth,
                );
                if (!context.mounted) return;
                handleJinyeWordMeaningSheetResult(context, result);
              },
              child: const Text('OPEN_SHEET'),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          pushedRoutes.add(state.uri.toString());
          return const Scaffold(body: Text('LOGIN_PAGE'));
        },
      ),
      GoRoute(
        path: '/suggest-edit/:wordId',
        builder: (context, state) {
          pushedRoutes.add(state.uri.toString());
          return const Scaffold(body: Text('SUGGEST_EDIT_PAGE'));
        },
      ),
      GoRoute(
        path: '/words/:id',
        builder: (context, state) {
          pushedRoutes.add(state.uri.toString());
          return const Scaffold(body: Text('WORD_DETAIL_PAGE'));
        },
      ),
      GoRoute(
        path: '/contribute',
        builder: (context, state) {
          pushedRoutes.add(state.uri.toString());
          return const Scaffold(body: Text('CONTRIBUTE_PAGE'));
        },
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dictionaryRepositoryProvider.overrideWithValue(
          _StubDictionaryRepo(found: found),
        ),
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
  await tester.pumpAndSettle();
  await tester.tap(find.text('OPEN_SHEET'));
  await tester.pumpAndSettle();
}

void _expectAllSheetButtonsSmall(WidgetTester tester) {
  final sheetButtons = tester
      .widgetList<FButton>(find.byType(FButton))
      .where((b) => b.size == FButtonSizeVariant.sm)
      .toList();
  // Semua FButton kecuali tombol trigger OPEN_SHEET di belakang sheet.
  final totalButtons = tester.widgetList<FButton>(find.byType(FButton)).length;
  expect(sheetButtons.length, totalButtons - 1);
}

void main() {
  const sampleLink = JinyeLemmaLink(
    id: 'link-1',
    start: 0,
    end: 4,
    wordId: _wordId,
    lemma: 'apam',
    status: 'active',
  );

  testWidgets('linked + auth: tombol kecil + tap Tambah makna buka suggest-edit', (
    tester,
  ) async {
    final pushed = <String>[];
    await _pumpAndOpenSheet(
      tester,
      found: true,
      isAuth: true,
      link: sampleLink,
      pushedRoutes: pushed,
    );

    expect(tester.takeException(), isNull);
    _expectAllSheetButtonsSmall(tester);
    expect(find.text('Buka lemma'), findsOneWidget);
    expect(find.text('Tambah makna'), findsOneWidget);

    await tester.tap(find.text('Tambah makna'));
    await tester.pumpAndSettle();

    expect(pushed, ['/suggest-edit/$_wordId?category=add_meaning']);
  });

  testWidgets('linked + guest: tap Tambah makna arahkan ke login', (
    tester,
  ) async {
    final pushed = <String>[];
    await _pumpAndOpenSheet(
      tester,
      found: true,
      isAuth: false,
      link: sampleLink,
      pushedRoutes: pushed,
    );

    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Tambah makna'));
    await tester.pumpAndSettle();

    expect(pushed, ['/login']);
  });

  testWidgets('unlinked + ditemukan: tampil Buka lemma, Tambah makna, Hubungkan', (
    tester,
  ) async {
    final pushed = <String>[];
    await _pumpAndOpenSheet(
      tester,
      found: true,
      isAuth: true,
      link: null,
      pushedRoutes: pushed,
    );

    expect(tester.takeException(), isNull);
    _expectAllSheetButtonsSmall(tester);
    expect(find.text('Buka lemma'), findsOneWidget);
    expect(find.text('Tambah makna'), findsOneWidget);
    expect(find.text('Hubungkan ke lemma'), findsOneWidget);

    await tester.tap(find.text('Buka lemma'));
    await tester.pumpAndSettle();

    expect(pushed, ['/words/$_wordId']);
  });

  testWidgets('unlinked + ditemukan: tap Tambah makna buka suggest-edit', (
    tester,
  ) async {
    final pushed = <String>[];
    await _pumpAndOpenSheet(
      tester,
      found: true,
      isAuth: true,
      link: null,
      pushedRoutes: pushed,
    );

    await tester.tap(find.text('Tambah makna'));
    await tester.pumpAndSettle();

    expect(pushed, ['/suggest-edit/$_wordId?category=add_meaning']);
  });

  testWidgets('unlinked + tidak ditemukan: Usul kata ini + Hubungkan tanpa overflow', (
    tester,
  ) async {
    final pushed = <String>[];
    await _pumpAndOpenSheet(
      tester,
      found: false,
      isAuth: true,
      link: null,
      pushedRoutes: pushed,
    );

    expect(tester.takeException(), isNull);
    _expectAllSheetButtonsSmall(tester);
    expect(find.text('Usul kata ini'), findsOneWidget);
    expect(find.text('Hubungkan ke lemma'), findsOneWidget);
    expect(find.text('Buka lemma'), findsNothing);
    expect(find.text('Tambah makna'), findsNothing);
  });
}
