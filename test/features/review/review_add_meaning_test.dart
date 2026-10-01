import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/core/network/auth_token_storage.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/dictionary/dictionary_router.dart';
import 'package:sambasku_mobile/features/suggest_edit/domain/suggest_category.dart';
import 'package:sambasku_mobile/features/review/data/review_correct_body.dart';
import 'package:sambasku_mobile/features/review/domain/entities/review_contribution.dart';
import 'package:sambasku_mobile/features/review/domain/failures/review_failure.dart';
import 'package:sambasku_mobile/features/review/domain/review_access.dart';
import 'package:sambasku_mobile/features/review/domain/repositories/review_repository.dart';
import 'package:sambasku_mobile/features/review/presentation/pages/review_session_page.dart';
import 'package:sambasku_mobile/features/review/presentation/providers/review_providers.dart';
import 'package:sambasku_mobile/features/review/presentation/widgets/review_correct_form.dart';
import 'package:sambasku_mobile/features/review/review_router.dart';
import 'package:sambasku_mobile/shared/reference/reference_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _idA = '01REVIEWITEM0000000000000A';
const _idB = '01REVIEWITEM0000000000000B';
const _wordId = '01WORD0000000000000000000A';
const _meaningId = '01MEANING000000000000000A';
const _classId = '01WORDCLASSESNOMINA000000';
const _idnLang = '01LANGUAGESINDONESIA00000';
const _engLang = '01LANGUAGESENGLISH000000';

class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository({required this.details});

  final Map<String, ReviewDetail> details;
  final List<Map<String, dynamic>> correctedBodies = [];
  int detailCalls = 0;

  @override
  Future<Either<ReviewFailure, ReviewListPage>> list({
    String? status,
    String? entityType,
    String? wordId,
    bool mine = false,
    bool hideSkipped = false,
    int limit = 20,
    String? cursor,
  }) async => Either.right(ReviewListPage(items: details.values.map((d) => d.contribution).toList()));

  @override
  Future<Either<ReviewFailure, ReviewDetail>> detail(String id) async {
    detailCalls++;
    final cached = details[id];
    if (cached == null) return Either.left(ReviewFailure('tidak dipakai'));
    return Either.right(cached);
  }

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> correct(
    String id,
    Map<String, dynamic> body,
  ) async {
    correctedBodies.add(body);
    return Either.right(const ReviewDecisionResult(status: 'corrected'));
  }

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> approve(String id, {String? comment}) async =>
      Either.right(const ReviewDecisionResult(status: 'approved'));

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> reject(String id, {required String comment}) async =>
      Either.left(ReviewFailure('tidak dipakai'));

  @override
  Future<Either<ReviewFailure, ReviewDecisionResult>> reopen(String id) async =>
      Either.left(ReviewFailure('tidak dipakai'));

  @override
  Future<Either<ReviewFailure, Unit>> skip(String id) async => Either.right(unit);

  @override
  Future<Either<ReviewFailure, Unit>> unskip(String id) async =>
      Either.left(ReviewFailure('tidak dipakai'));

  @override
  Future<Either<ReviewFailure, Unit>> unverifyWord(String wordId) async =>
      Either.left(ReviewFailure('tidak dipakai'));
}

ReviewDetail _wordDetail({String lemma = 'kalintiak'}) => ReviewDetail(
  contribution: ReviewItem(
    id: _idA,
    contributorUsername: 'budi',
    entityType: 'word',
    entityId: _wordId,
    action: 'create',
    status: 'pending',
    createdAt: '2026-09-23T00:00:00.000Z',
    wordLemma: lemma,
  ),
  entity: const {
    'lemma': 'kalintiak',
    'wordType': 'word',
    'isVerified': false,
    'meanings': <Map<String, dynamic>>[],
    'images': <Map<String, dynamic>>[],
  },
);

const _verbId = '01WORDCLASSESVERBA0000000';
const _synonymId = '01WORD0000000000000000000S';

const _classes = [
  ReferenceItem(id: _classId, name: 'Nomina', code: 'n'),
  ReferenceItem(id: _verbId, name: 'Verba', code: 'v'),
];

/// Kata pending dengan satu makna lama, satu sinonim, satu variasi.
ReviewDetail _wordDetailWithMeaning() => ReviewDetail(
  contribution: ReviewItem(
    id: _idA,
    contributorUsername: 'budi',
    entityType: 'word',
    entityId: _wordId,
    action: 'create',
    status: 'pending',
    createdAt: '2026-09-23T00:00:00.000Z',
    wordLemma: 'kalintiak',
  ),
  entity: const {
    'languageId': '01LANG00000000000000000001',
    'lemma': 'kalintiak',
    'wordType': 'word',
    'isVerified': false,
    'meanings': [
      {
        'definition': 'ikan kecil',
        'wordClass': {'id': _classId},
        'translations': [
          {'languageId': _idnLang, 'translationText': 'ikan kecil'},
        ],
        'examples': <Map<String, dynamic>>[],
      },
    ],
    'relatedWords': [
      {'wordId': _synonymId, 'lemma': 'bada', 'relationType': 'synonym'},
    ],
    'variants': [
      {'form': 'kalintik', 'variantType': 'alternative'},
    ],
    'images': <Map<String, dynamic>>[],
  },
);

/// Payload `findChildWithParent('meaning', ...)` dari API: snake_case.
ReviewDetail _meaningDetail({String? wordIdInEntity = _wordId}) => ReviewDetail(
  contribution: ReviewItem(
    id: _idB,
    contributorUsername: 'sari',
    entityType: 'meaning',
    entityId: _meaningId,
    action: 'create',
    status: 'pending',
    createdAt: '2026-09-23T00:00:00.000Z',
    wordLemma: 'kalintiak',
  ),
  entity: {
    'word_id': _wordId,
    'meaning_id': _meaningId,
    'wordId': ?wordIdInEntity,
    'data': {
      'word_class_id': _classId,
      'definition': 'ikan kecil',
      'is_have_definition': true,
      'is_have_translation': true,
      'meaning_source': 'kbbi',
      'translations': [
        {
          'language_id': _idnLang,
          'translation_text': 'ikan kecil',
          'translation_type': 'direct',
          'translation_allows_comma': true,
        },
        {
          'language_id': _engLang,
          'translation_text': 'small fish',
          'translation_type': 'idiomatic',
          'translation_allows_comma': false,
        },
      ],
    },
  },
);

void main() {
  group('ReviewDetail.wordId', () {
    test('kontribusi kata memakai entityId', () {
      expect(_wordDetail().wordId, _wordId);
    });

    test('kontribusi anak memakai wordId dari payload entity', () {
      expect(_meaningDetail().wordId, _wordId);
    });

    test('null saat payload anak tidak punya wordId', () {
      expect(_meaningDetail(wordIdInEntity: null).wordId, isNull);
    });

    test('null saat wordId kosong', () {
      expect(_meaningDetail(wordIdInEntity: '   ').wordId, isNull);
    });
  });

  group('parseSuggestCategory', () {
    test('add_meaning dipetakan ke addMeaning', () {
      expect(parseSuggestCategory('add_meaning'), SuggestCategory.addMeaning);
    });

    test('kategori lain ikut terpetakan', () {
      for (final category in SuggestCategory.values) {
        expect(parseSuggestCategory(category.code), category);
      }
    });

    test('nilai tak dikenal diabaikan, bukan crash', () {
      expect(parseSuggestCategory('ganti_semua'), isNull);
    });

    test('null dan string kosong berarti tidak ada preset', () {
      expect(parseSuggestCategory(null), isNull);
      expect(parseSuggestCategory(''), isNull);
    });
  });

  group('correctableEntityTypes', () {
    test('makna bisa dikoreksi (rekam jejak kedua sisi server-klien)', () {
      expect(canCorrectEntityType('meaning'), isTrue);
    });

    test('enam tipe entity punya jalur koreksi', () {
      expect(correctableEntityTypes, {
        'word',
        'meaning',
        'pronunciation',
        'word_image',
        'word_audio',
        'example',
      });
    });

    test('tipe tak dikenal tidak bisa dikoreksi', () {
      expect(canCorrectEntityType('gloss'), isFalse);
    });
  });

  Future<ProviderContainer> bootSession(
    ProviderContainer container,
    WidgetTester tester,
    Widget home,
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
    // Router asli: sukses koreksi di kartu terakhir keluar ke antrean.
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => home),
        GoRoute(
          path: ReviewRouter.queue.path,
          builder: (context, state) => const Text('antrean'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
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
    await tester.pump();
    // pump() tanpa durasi tidak menjalankan Timer.zero dispose Riverpod.
    await tester.pump(Duration.zero);
    return container;
  }

  group('lengkapi kata dari form Koreksi', () {
    testWidgets('action bar tetap satu baris tanpa tombol Tambah makna', (tester) async {
      final repo = _FakeReviewRepository(details: {_idA: _wordDetail()});
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          reviewRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      container.read(reviewSessionProvider.notifier).start(
        ids: const [_idA, _idB],
        index: 0,
      );

      await bootSession(container, tester, const ReviewSessionPage(startId: _idA));

      expect(find.text('Tambah makna'), findsNothing);
      expect(find.text('Koreksi'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.check), findsOneWidget);
      expect(find.byIcon(FLucideIcons.x), findsOneWidget);
    });

    testWidgets('Koreksi -> Tambah makna -> pilih kelas -> Simpan mengirim 2 makna', (tester) async {
      final repo = _FakeReviewRepository(details: {_idA: _wordDetailWithMeaning()});
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          reviewRepositoryProvider.overrideWithValue(repo),
          referenceWordClassesProvider.overrideWith((ref) async => _classes),
        ],
      );
      addTearDown(container.dispose);
      container.read(reviewSessionProvider.notifier).start(
        ids: const [_idA],
        index: 0,
      );

      await bootSession(container, tester, const ReviewSessionPage(startId: _idA));

      await tester.tap(find.text('Koreksi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // relasi & variasi lama terbaca di section Kelengkapan
      final formScroll = find
          .descendant(of: find.byType(ReviewCorrectForm), matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(find.text('Sinonim & antonim'), 200, scrollable: formScroll);
      expect(find.text('1 sinonim'), findsOneWidget);
      expect(find.text('kalintik'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Tambah makna'), -200, scrollable: formScroll);
      await tester.tap(find.text('Tambah makna'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Verba'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      await tester.enterText(
        find.descendant(
          of: find.widgetWithText(FTextField, 'Terjemahan').last,
          matching: find.byType(EditableText),
        ),
        'melompat',
      );
      await tester.pump();

      await tester.tap(find.text('Simpan dan terbitkan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(repo.correctedBodies, hasLength(1));
      final body = repo.correctedBodies.single;
      final meanings = body['meanings'] as List;
      expect(meanings, hasLength(2));
      expect(meanings[0]['word_class_id'], _classId);
      expect(meanings[1]['word_class_id'], _verbId);
      expect(meanings[1]['translations'], [
        {
          'language_id': _idnLang,
          'translation_text': 'melompat',
          'translation_type': 'direct',
        },
      ]);
      // replace semantics: relasi & variasi lama wajib ikut terkirim
      expect(body['related_words'], [
        {'word_id': _synonymId, 'relation_type': 'synonym'},
      ]);
      expect((body['variants'] as List).single['form'], 'kalintik');
    });
  });

  group('koreksi makna', () {
    testWidgets('kartu makna punya tombol Koreksi', (tester) async {
      final detail = _meaningDetail();
      final repo = _FakeReviewRepository(details: {_idB: detail});
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          reviewRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      container.read(reviewSessionProvider.notifier).start(
        ids: const [_idB],
        index: 0,
      );

      await bootSession(container, tester, const ReviewSessionPage(startId: _idB));

      expect(find.text('Koreksi'), findsOneWidget);
    });

    testWidgets('form terisi dari payload makna dan mengirim SEMUA terjemahan', (tester) async {
      final detail = _meaningDetail();
      final repo = _FakeReviewRepository(details: {_idB: detail});
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          reviewRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      container.read(reviewSessionProvider.notifier).start(
        ids: const [_idB],
        index: 0,
      );

      await bootSession(container, tester, const ReviewSessionPage(startId: _idB));

      await tester.tap(find.text('Koreksi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // bukan lagi pesan "tidak didukung"
      expect(
        find.textContaining('Koreksi langsung tidak didukung'),
        findsNothing,
      );
      // preview kartu tetap di tree; cek label field di form saja
      Finder inForm(String text) =>
          find.descendant(of: find.byType(ReviewCorrectForm), matching: find.text(text));
      expect(inForm('Definisi'), findsOneWidget);
      expect(inForm('Terjemahan'), findsOneWidget);
      // terjemahan kedua tidak jadi text field, tapi tetap dihitung
      expect(find.textContaining('Terjemahan lain milik makna ini (1)'), findsOneWidget);

      // prefill: definisi & terjemahan pertama dari payload
      expect(find.text('ikan kecil'), findsWidgets);

      await tester.tap(find.text('Simpan dan terbitkan'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(repo.correctedBodies, hasLength(1));
      final body = repo.correctedBodies.single;
      expect(body['entity_type'], 'meaning');
      expect(body['definition'], 'ikan kecil');
      expect(body['word_class_id'], _classId);
      expect(body['meaning_source'], 'kbbi');
      expect(body['publish'], isTrue);

      final translations = body['translations'] as List;
      // dua-duanya terkirim: yang diedit + yang dibawa apa adanya
      expect(translations, hasLength(2));
      expect(translations.first, {
        'language_id': _idnLang,
        'translation_text': 'ikan kecil',
        'translation_type': 'direct',
      });
      expect(translations[1], {
        'language_id': _engLang,
        'translation_text': 'small fish',
        'translation_type': 'idiomatic',
        'translation_allows_comma': false,
      });
    });

    testWidgets('koreksi tanpa terbit tetap mengirim daftar terjemahan lengkap', (tester) async {
      final detail = _meaningDetail();
      final repo = _FakeReviewRepository(details: {_idB: detail});
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(AuthTokenStorage()),
          reviewRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);
      container.read(reviewSessionProvider.notifier).start(
        ids: const [_idB],
        index: 0,
      );

      await bootSession(container, tester, const ReviewSessionPage(startId: _idB));

      await tester.tap(find.text('Koreksi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.byType(FSwitch).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Simpan, tetap menunggu'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(repo.correctedBodies, hasLength(1));
      expect(repo.correctedBodies.single['publish'], isFalse);
      expect(repo.correctedBodies.single['translations'], hasLength(2));
    });

    test('buildWordCorrectBody tidak ikut berubah oleh jalur makna', () {
      // regression: edit makna tidak boleh menggeser bentuk payload
      // koreksi kata (replace meanings, bukan translations).
      final body = buildWordCorrectBody(
        entity: const {
          'languageId': '01LANG00000000000000000001',
          'lemma': 'kalintiak',
          'wordType': 'word',
          'meanings': <Map<String, dynamic>>[],
          'images': <Map<String, dynamic>>[],
          'categories': <Map<String, dynamic>>[],
        },
        lemma: 'kalintiak',
        notes: '',
        wordType: 'word',
        usageLabels: const [],
        meanings: const [],
        relatedWords: const [],
        variants: const [],
        publish: true,
      );
      expect(body.containsKey('translations'), isFalse);
      expect(body['meanings'], isNotNull);
    });
  });
}
