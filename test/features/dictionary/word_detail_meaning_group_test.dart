import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/dictionary/data/providers/dictionary_data_providers.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_detail.dart';
import 'package:sambasku_mobile/features/dictionary/domain/entities/word_of_day.dart';
import 'package:sambasku_mobile/features/dictionary/domain/failures/dictionary_failure.dart';
import 'package:sambasku_mobile/features/dictionary/domain/repositories/dictionary_repository.dart';
import 'package:sambasku_mobile/features/dictionary/presentation/pages/word_detail_page.dart';

const _wordId = '01AAAAAAAAAAAAAAAAAAAAAAAA';

/// PRD relasi-lemma: section "Makna terkait" di detail kata.
WordDetail _detail(List<MeaningGroup> groups) => WordDetail(
      id: _wordId,
      lemma: 'apam',
      languageId: 'lang-1',
      wordType: 'word',
      status: 'published',
      isVerified: true,
      isCorrected: false,
      meanings: const [],
      meaningGroups: groups,
    );

class _StubRepo implements DictionaryRepository {
  _StubRepo(this.groups);

  final List<MeaningGroup> groups;

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordById(
    String id, {
    bool forceRefresh = false,
  }) async =>
      Either.right(_detail(groups));

  @override
  Future<Either<DictionaryFailure, WordDetail>> getWordByLemma(
    String lemma, {
    bool forceRefresh = false,
  }) async =>
      Either.right(_detail(groups));

  @override
  Future<Either<DictionaryFailure, WordOfDay?>> getWordOfDay({
    bool forceRefresh = false,
  }) async =>
      Either.right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _pump(WidgetTester tester, List<MeaningGroup> groups) async {
  // Layar tinggi: section "Makna terkait" ada di bawah makna & relasi,
  // perlu viewport besar supaya ikut dibangun tanpa scroll.
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
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dictionaryRepositoryProvider.overrideWithValue(_StubRepo(groups)),
      ],
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
  testWidgets('satu grup: label "Makna terkait" + semua anggota tampil', (
    tester,
  ) async {
    await _pump(tester, const [
      MeaningGroup(
        groupId: 'g1',
        name: 'Kumis',
        members: [
          MeaningGroupMember(wordId: 'w2', lemma: 'misai', notes: 'lebih jarang'),
          MeaningGroupMember(wordId: 'w3', lemma: 'kumis'),
        ],
      ),
    ]);

    expect(tester.takeException(), isNull);
    // _SectionLabel merender teks uppercase.
    expect(find.text('MAKNA TERKAIT'), findsOneWidget);
    expect(find.text('misai'), findsOneWidget);
    expect(find.text('kumis'), findsOneWidget);
    expect(find.text('lebih jarang'), findsOneWidget);
  });

  testWidgets('lebih dari satu grup: label pakai nama grup', (tester) async {
    await _pump(tester, const [
      MeaningGroup(
        groupId: 'g1',
        name: 'Kumis',
        members: [MeaningGroupMember(wordId: 'w2', lemma: 'misai')],
      ),
      MeaningGroup(
        groupId: 'g2',
        name: 'Kumis tebal',
        members: [MeaningGroupMember(wordId: 'w4', lemma: 'somet')],
      ),
    ]);

    expect(find.text('MAKNA TERKAIT'), findsNothing);
    expect(find.text('KUMIS'), findsOneWidget);
    expect(find.text('KUMIS TEBAL'), findsOneWidget);
    expect(find.text('misai'), findsOneWidget);
    expect(find.text('somet'), findsOneWidget);
  });

  testWidgets('tanpa kelompok makna: section tidak dirender', (tester) async {
    await _pump(tester, const []);
    expect(find.text('MAKNA TERKAIT'), findsNothing);
  });
}
