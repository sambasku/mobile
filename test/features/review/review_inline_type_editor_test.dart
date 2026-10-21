import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/review/domain/entities/review_contribution.dart';
import 'package:sambasku_mobile/features/review/domain/failures/review_failure.dart';
import 'package:sambasku_mobile/features/review/domain/repositories/review_repository.dart';
import 'package:sambasku_mobile/features/review/presentation/providers/review_providers.dart';
import 'package:sambasku_mobile/features/review/presentation/widgets/review_inline_type_editor.dart';
import 'package:sambasku_mobile/shared/reference/reference_data.dart';

const _umum = '01CLASSUMUM00000000000000';
const _nomina = '01CLASSNOMINA000000000000';
const _verba = '01CLASSVERBA0000000000000';

class _FakeReviewRepository implements ReviewRepository {
  Map<String, dynamic>? lastBody;
  int correctCalls = 0;

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> correct(
    String id,
    Map<String, dynamic> body,
  ) async {
    correctCalls++;
    lastBody = body;
    return Either.right(const ReviewDecisionResult(status: 'pending'));
  }

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> approve(
    String id, {
    String? comment,
  }) => throw UnimplementedError();

  @override
  Future<Either<ReviewFailure, ReviewDetail>> detail(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<ReviewFailure, ReviewListPage>> list({
    String? status,
    String? entityType,
    String? wordId,
    bool mine = false,
    bool hideSkipped = false,
    int limit = 20,
    String? cursor,
  }) => throw UnimplementedError();

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> reject(
    String id, {
    required String comment,
  }) => throw UnimplementedError();

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> reopen(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<ReviewFailure, Unit>> skip(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<ReviewFailure, Unit>> unskip(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<ReviewFailure, Unit>> unverifyWord(String wordId) =>
      throw UnimplementedError();
}

ReviewDetail _detail(Map<String, dynamic> entity) {
  return ReviewDetail(
    contribution: const ReviewItem(
      id: 'c1',
      contributorUsername: 'kontributor',
      entityType: 'word',
      entityId: 'w1',
      action: 'create',
      status: 'pending',
      createdAt: '2026-01-01T00:00:00.000Z',
    ),
    entity: entity,
  );
}

void main() {
  final classes = [
    const ReferenceItem(id: _umum, name: 'Umum', code: 'umum'),
    const ReferenceItem(
      id: _nomina,
      name: 'Nomina',
      code: 'n',
      alias: 'Kata Benda',
    ),
    const ReferenceItem(
      id: _verba,
      name: 'Verba',
      code: 'v',
      alias: 'Kata Kerja',
    ),
  ];

  Future<void> pumpEditor(
    WidgetTester tester, {
    required _FakeReviewRepository repo,
    required Map<String, dynamic> entity,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reviewRepositoryProvider.overrideWithValue(repo),
          referenceWordClassesProvider.overrideWith((ref) async => classes),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          builder: (context, child) => FToaster(
            child: FTheme(
              data: FThemes.zinc.light.touch,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          home: Scaffold(
            body: ReviewInlineTypeEditor(detail: _detail(entity)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('simpan jenis mengirim correct publish false', (tester) async {
    final repo = _FakeReviewRepository();
    await pumpEditor(
      tester,
      repo: repo,
      entity: {
        'lemma': 'kalintiak',
        'wordType': 'word',
        'languageId': '01LANGSAMBAS0000000000000',
        'meanings': [
          {
            'definition': 'ikan kecil',
            'wordClass': {'id': _umum, 'code': 'umum', 'name': 'Umum'},
            'translations': <Map<String, dynamic>>[],
          },
        ],
      },
    );

    expect(find.text('Simpan jenis'), findsNothing);
    await tester.tap(find.text('Jenis entri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Peribahasa'));
    await tester.pumpAndSettle();

    expect(repo.correctCalls, 1);
    expect(repo.lastBody?['word_type'], 'peribahasa');
    expect(find.text('Simpan jenis'), findsNothing);

    await tester.tap(find.text('Kelas kata'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kata Kerja').first);
    await tester.pumpAndSettle();

    expect(repo.correctCalls, 2);
    expect(repo.lastBody?['publish'], isFalse);
    expect(repo.lastBody?['word_type'], 'peribahasa');
    final meanings = repo.lastBody?['meanings'] as List;
    expect((meanings.single as Map)['word_class_id'], _verba);
    expect(
      find.text('Koreksi disimpan. Usulan tetap menunggu.'),
      findsAtLeastNWidgets(1),
    );
  });

  testWidgets('jenis Kata ditolak lokal bila masih ada has_component', (
    tester,
  ) async {
    final repo = _FakeReviewRepository();
    await pumpEditor(
      tester,
      repo: repo,
      entity: {
        'lemma': 'tangan besi',
        'wordType': 'ungkapan',
        'languageId': '01LANGSAMBAS0000000000000',
        'meanings': [
          {
            'definition': 'keras',
            'wordClass': {'id': _nomina, 'code': 'n', 'name': 'Nomina'},
            'translations': <Map<String, dynamic>>[],
          },
        ],
        'relatedWords': [
          {'wordId': 'w2', 'relationType': 'has_component'},
        ],
      },
    );

    await tester.tap(find.text('Jenis entri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kata'));
    await tester.pumpAndSettle();

    expect(repo.correctCalls, 0);
    expect(
      find.text('has_component hanya untuk entri idiom/peribahasa/ungkapan'),
      findsOneWidget,
    );
  });
}
