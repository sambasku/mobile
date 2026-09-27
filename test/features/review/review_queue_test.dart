import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/review/data/review_correct_body.dart';
import 'package:sambasku_mobile/features/review/domain/entities/review_contribution.dart';
import 'package:sambasku_mobile/features/review/domain/failures/review_failure.dart';
import 'package:sambasku_mobile/features/review/domain/repositories/review_repository.dart';
import 'package:sambasku_mobile/features/review/presentation/pages/review_queue_page.dart';
import 'package:sambasku_mobile/features/review/presentation/pages/review_session_page.dart';
import 'package:sambasku_mobile/features/review/presentation/providers/review_providers.dart';
import 'package:sambasku_mobile/features/review/presentation/widgets/review_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository({
    this.failure,
    this.items = const [
      ReviewItem(
        id: '01REVIEWITEM00000000000001',
        contributorUsername: 'budi',
        entityType: 'word',
        entityId: '01WORD00000000000000000001',
        action: 'create',
        status: 'pending',
        createdAt: '2026-09-23T00:00:00.000Z',
        wordLemma: 'kalintiak',
      ),
    ],
    this.details = const {},
  });

  final ReviewFailure? failure;
  final List<ReviewItem> items;
  final Map<String, ReviewDetail> details;
  final List<String> approvedIds = [];

  @override
  Future<Either<ReviewFailure, ReviewListPage>> list({
    String? status,
    String? entityType,
    String? wordId,
    int limit = 20,
    String? cursor,
  }) async {
    if (failure != null) return Either.left(failure!);
    return Either.right(ReviewListPage(items: items));
  }

  @override
  Future<Either<ReviewFailure, ReviewDetail>> detail(String id) async {
    final cached = details[id];
    if (cached != null) return Either.right(cached);
    return Either.left(ReviewFailure('tidak dipakai'));
  }

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> approve(
    String id, {
    String? comment,
  }) async {
    approvedIds.add(id);
    return Either.right(const ReviewDecisionResult(status: 'approved'));
  }

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> reject(
    String id, {
    required String comment,
  }) async => Either.left(ReviewFailure('tidak dipakai'));

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> correct(
    String id,
    Map<String, dynamic> body,
  ) async => Either.left(ReviewFailure('tidak dipakai'));
}

ReviewDetail _wordDetail({
  required String id,
  required String lemma,
}) {
  return ReviewDetail(
    contribution: ReviewItem(
      id: id,
      contributorUsername: 'budi',
      entityType: 'word',
      entityId: '01WORD$lemma',
      action: 'create',
      status: 'pending',
      createdAt: '2026-09-23T00:00:00.000Z',
      wordLemma: lemma,
    ),
    entity: {
      'lemma': lemma,
      'wordType': 'word',
      'isVerified': false,
      'meanings': const <Map<String, dynamic>>[],
      'images': const <Map<String, dynamic>>[],
    },
  );
}

void main() {
  test('body koreksi kata membawa gambar dan tidak mengosongkan makna', () {
    final body = buildWordCorrectBody(
      entity: {
        'languageId': '01LANG00000000000000000001',
        'lemma': 'lama',
        'wordType': 'word',
        'isVerified': true,
        'meanings': [
          {
            'definition': 'ikan',
            'orderIndex': 0,
            'wordClass': {'id': '01CLASS0000000000000000001'},
            'translations': [
              {
                'languageId': '01ID0000000000000000000001',
                'translationText': 'ikan kecil',
                'translationType': 'direct',
              },
            ],
          },
        ],
        'images': [
          {
            'url': 'https://cdn.example/a.png',
            'providerFileId': 'file-1',
            'isPrimary': true,
          },
        ],
        'categories': [],
      },
      lemma: 'kalintiak',
      notes: '',
      wordType: 'word',
      meaningEdits: [
        (
          definition: 'ikan kecil',
          translation: 'ikan kecil',
          wordClassId: null,
        ),
      ],
      publish: true,
    );

    expect(body['lemma'], 'kalintiak');
    expect(body['images'], isNotEmpty);
    expect((body['meanings'] as List).first['definition'], 'ikan kecil');
    expect(
      (body['meanings'] as List).first['word_class_id'],
      '01CLASS0000000000000000001',
    );
  });

  test('body koreksi memakai kelas kata dari KBBI', () {
    final body = buildWordCorrectBody(
      entity: {
        'languageId': '01LANG00000000000000000001',
        'lemma': 'lama',
        'wordType': 'word',
        'meanings': [
          {
            'definition': 'makan',
            'orderIndex': 0,
            'wordClass': {'id': '01CLASS0000000000000000001'},
            'translations': [
              {
                'languageId': '01ID0000000000000000000001',
                'translationText': '-',
                'translationType': 'direct',
              },
            ],
          },
        ],
        'categories': [],
      },
      lemma: 'makan',
      notes: '',
      wordType: 'peribahasa',
      meaningEdits: [
        (
          definition: 'aktivitas memasukkan makanan ke mulut',
          translation: 'makan',
          wordClassId: '01CLASSKBBI000000000000001',
        ),
      ],
      publish: true,
    );

    final meaning = (body['meanings'] as List).first as Map<String, dynamic>;
    expect(body['word_type'], 'peribahasa');
    expect(meaning['word_class_id'], '01CLASSKBBI000000000000001');
    expect(meaning['definition'], 'aktivitas memasukkan makanan ke mulut');
    expect(meaning['is_have_definition'], isTrue);
    expect(
      (meaning['translations'] as List).first['translation_text'],
      'makan',
    );
  });

  test('409 menutup kartu dari antrean', () {
    final failure = ReviewFailure(
      'Kontribusi ini sudah diproses',
      errorCode: 'CONTRIBUTION_ALREADY_REVIEWED',
    );
    expect(failure.isAlreadyDecided, isTrue);
    expect(
      ReviewFailure('dilarang', errorCode: 'FORBIDDEN').isForbidden,
      isTrue,
    );
  });

  test('advanceAfterDecision setelah 409 menggeser seperti keputusan sukses',
      () async {
    final container = ProviderContainer(
      overrides: [
        reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
      ],
    );
    addTearDown(container.dispose);

    container.read(reviewSessionProvider.notifier).start(
      ids: const ['a', 'b'],
      index: 0,
    );

    // Simulasi jalur UI: CONTRIBUTION_ALREADY_REVIEWED → advanceAfterDecision.
    final failure = ReviewFailure(
      'Kontribusi ini sudah diproses',
      errorCode: 'CONTRIBUTION_ALREADY_REVIEWED',
    );
    expect(failure.isAlreadyDecided, isTrue);

    final hasNext = await container
        .read(reviewSessionProvider.notifier)
        .advanceAfterDecision('a');

    expect(hasNext, isTrue);
    expect(container.read(reviewSessionProvider)?.currentId, 'b');
  });

  test('advanceAfterDecision menggeser ke item berikutnya', () async {
    final repo = _FakeReviewRepository(
      items: const [
        ReviewItem(
          id: 'a',
          contributorUsername: 'budi',
          entityType: 'word',
          entityId: 'w1',
          action: 'create',
          status: 'pending',
          createdAt: '2026-09-23T00:00:00.000Z',
          wordLemma: 'satu',
        ),
        ReviewItem(
          id: 'b',
          contributorUsername: 'budi',
          entityType: 'word',
          entityId: 'w2',
          action: 'create',
          status: 'pending',
          createdAt: '2026-09-23T00:00:00.000Z',
          wordLemma: 'dua',
        ),
        ReviewItem(
          id: 'c',
          contributorUsername: 'budi',
          entityType: 'word',
          entityId: 'w3',
          action: 'create',
          status: 'pending',
          createdAt: '2026-09-23T00:00:00.000Z',
          wordLemma: 'tiga',
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [reviewRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    container.read(reviewSessionProvider.notifier).start(
      ids: const ['a', 'b', 'c'],
      index: 0,
    );

    final hasNext = await container
        .read(reviewSessionProvider.notifier)
        .advanceAfterDecision('a');

    expect(hasNext, isTrue);
    final session = container.read(reviewSessionProvider);
    expect(session?.currentId, 'b');
    expect(session?.position, 1);
    expect(session?.total, 2);
  });

  test('advanceAfterDecision menghabiskan sesi bila item terakhir', () async {
    final container = ProviderContainer(
      overrides: [
        reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
      ],
    );
    addTearDown(container.dispose);

    container.read(reviewSessionProvider.notifier).start(
      ids: const ['only'],
      index: 0,
    );

    final hasNext = await container
        .read(reviewSessionProvider.notifier)
        .advanceAfterDecision('only');

    expect(hasNext, isFalse);
    expect(container.read(reviewSessionProvider), isNull);
  });

  test('skipCurrent menyimpan rewindSkipId; rewindSkip mengembalikan kartu',
      () async {
    final container = ProviderContainer(
      overrides: [
        reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
      ],
    );
    addTearDown(container.dispose);

    container.read(reviewSessionProvider.notifier).start(
      ids: const ['a', 'b', 'c'],
      index: 0,
    );

    final hasNext =
        await container.read(reviewSessionProvider.notifier).skipCurrent();

    expect(hasNext, isTrue);
    final afterSkip = container.read(reviewSessionProvider);
    expect(afterSkip?.currentId, 'b');
    expect(afterSkip?.canRewind, isTrue);
    expect(afterSkip?.rewindSkipId, 'a');

    final ok = container.read(reviewSessionProvider.notifier).rewindSkip();
    expect(ok, isTrue);
    final afterRewind = container.read(reviewSessionProvider);
    expect(afterRewind?.currentId, 'a');
    expect(afterRewind?.canRewind, isFalse);
    expect(afterRewind?.ids, ['a', 'b', 'c']);
  });

  test('advanceAfterDecision menghapus rewind skip', () async {
    final container = ProviderContainer(
      overrides: [
        reviewRepositoryProvider.overrideWithValue(_FakeReviewRepository()),
      ],
    );
    addTearDown(container.dispose);

    container.read(reviewSessionProvider.notifier).start(
      ids: const ['a', 'b', 'c'],
      index: 0,
    );

    await container.read(reviewSessionProvider.notifier).skipCurrent();
    expect(container.read(reviewSessionProvider)?.canRewind, isTrue);

    await container
        .read(reviewSessionProvider.notifier)
        .advanceAfterDecision('b');

    final session = container.read(reviewSessionProvider);
    expect(session?.currentId, 'c');
    expect(session?.canRewind, isFalse);
  });

  testWidgets('kontributor tidak lolos penjaga antrean', (tester) async {
    SharedPreferences.setMockInitialValues({
      'isAuth': true,
      'sessionUsername': 'budi',
      'sessionRole': 'contributor',
    });
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'test-access',
      'refreshToken': 'test-refresh',
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: ReviewGate(child: Text('antrean')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Kamu tidak berwenang meninjau usulan.'), findsOneWidget);
    expect(find.text('antrean'), findsNothing);
  });

  testWidgets('403 dari API membuka layar penghalang', (tester) async {
    SharedPreferences.setMockInitialValues({
      'isAuth': true,
      'sessionUsername': 'rina',
      'sessionRole': 'reviewer',
    });
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'test-access',
      'refreshToken': 'test-refresh',
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          reviewRepositoryProvider.overrideWithValue(
            _FakeReviewRepository(
              failure: ReviewFailure(
                'Role tidak diizinkan mengakses endpoint ini',
                errorCode: 'FORBIDDEN',
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: ReviewQueuePage(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('Kamu tidak berwenang meninjau usulan.'), findsOneWidget);
    expect(
      find.text('Role tidak diizinkan mengakses endpoint ini'),
      findsOneWidget,
    );
  });

  testWidgets('sesi menampilkan progress dan mode koreksi inline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'isAuth': true,
      'sessionUsername': 'rina',
      'sessionRole': 'reviewer',
    });
    FlutterSecureStorage.setMockInitialValues({
      'accessToken': 'test-access',
      'refreshToken': 'test-refresh',
    });

    const idA = '01REVIEWITEM0000000000000A';
    const idB = '01REVIEWITEM0000000000000B';
    final detailA = _wordDetail(id: idA, lemma: 'kalintiak');
    final detailB = _wordDetail(id: idB, lemma: 'bujak');
    final repo = _FakeReviewRepository(
      items: [detailA.contribution, detailB.contribution],
      details: {idA: detailA, idB: detailB},
    );

    final container = ProviderContainer(
      overrides: [
        authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
        reviewRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    container.read(reviewSessionProvider.notifier).start(
      ids: const [idA, idB],
      index: 0,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
          localizationsDelegates: FLocalizations.localizationsDelegates,
          supportedLocales: FLocalizations.supportedLocales,
          home: FTheme(
            data: FThemes.zinc.light.touch,
            child: const ReviewSessionPage(startId: idA),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Tinjau · 1/2'), findsOneWidget);
    expect(find.text('kalintiak'), findsWidgets);
    expect(find.byIcon(FLucideIcons.check), findsOneWidget);
    expect(find.byIcon(FLucideIcons.x), findsOneWidget);
    expect(
      find.textContaining('Kanan hijau · kiri merah · atas lewati'),
      findsOneWidget,
    );

    await tester.tap(find.text('Koreksi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('Koreksi · 1/2'), findsOneWidget);
    expect(find.text('Simpan dan terbitkan'), findsOneWidget);
    expect(find.text('Batal koreksi'), findsOneWidget);
    expect(find.byIcon(FLucideIcons.check), findsNothing);
    expect(find.byIcon(FLucideIcons.x), findsNothing);

    await tester.tap(find.text('Batal koreksi'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byIcon(FLucideIcons.check), findsOneWidget);
    expect(find.byIcon(FLucideIcons.x), findsOneWidget);
  });
}
