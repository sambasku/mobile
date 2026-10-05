import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/models/image_attribution.dart';
import 'package:sambasku_mobile/features/dictionary/data/providers/dictionary_data_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/word_detail_page.dart';

const _wordId = '01AAAAAAAAAAAAAAAAAAAAAAAA';

List<WordImage> _images = const [];

WordImage _img(
  String id, {
  bool primary = false,
  ImageAttribution? attribution,
}) => WordImage(
  id: id,
  url: 'https://images.unsplash.com/photo-$id?w=800',
  isPrimary: primary,
  attribution: attribution,
);

WordDetail _detail() => WordDetail(
  id: _wordId,
  lemma: 'apam',
  languageId: 'lang-1',
  wordType: 'word',
  status: 'published',
  isVerified: true,
  isCorrected: false,
  createdBy: const WordVerifier(
    username: 'budi',
    displayName: 'Budi',
    role: 'contributor',
  ),
  images: _images,
  meanings: const [],
);

class _StubRepo implements DictionaryRepository {
  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
  }) async => Either.right(_detail());

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
  }) async => Either.right(_detail());

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async => Either.right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _pump(WidgetTester tester) async {
  final router = GoRouter(
    initialLocation: '/words/$_wordId',
    routes: [
      GoRoute(
        path: '/words/:id',
        builder: (context, state) =>
            WordDetailPage(wordId: state.pathParameters['id']!),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [dictionaryRepositoryProvider.overrideWithValue(_StubRepo())],
      child: MaterialApp.router(
        theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
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
  await tester.runAsync(() async {
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => _images = const []);

  testWidgets('kredit foto tampil mengikuti foto aktif', (tester) async {
    _images = [
      _img(
        'a',
        primary: true,
        attribution: const ImageAttribution(name: 'Ada', provider: 'unsplash'),
      ),
      _img(
        'b',
        attribution: const ImageAttribution(name: 'Bob', provider: 'pixabay'),
      ),
    ];
    await _pump(tester);

    expect(find.text('Foto oleh '), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);

    // Swipe ke foto kedua: kredit ikut berganti.
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('Ada'), findsNothing);
    expect(find.text('Bob'), findsOneWidget);
  });

  testWidgets('tanpa kredit: label Foto oleh tidak muncul', (tester) async {
    _images = [_img('a', primary: true)];
    await _pump(tester);
    expect(find.text('Foto oleh '), findsNothing);
  });

  testWidgets('counter 1/2 berganti saat swipe', (tester) async {
    _images = [_img('a', primary: true), _img('b')];
    await _pump(tester);
    expect(find.text('1/2'), findsOneWidget);
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 800);
    await tester.pumpAndSettle();
    expect(find.text('2/2'), findsOneWidget);
  });
}
