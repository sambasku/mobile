import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/contribution/domain/entities/submit_word_result.dart';
import 'package:sambasku_mobile/features/contribution/domain/failures/contribution_failure.dart';
import 'package:sambasku_mobile/features/contribution/domain/repositories/contribution_repository.dart';
import 'package:sambasku_mobile/features/contribution/domain/usecases/submit_anon_word_use_case.dart';

/// Usecase wajib unit test (mobile-base-stack Section 10): trim semua
/// input, buang translation/category kosong, null-kan dialectId/notes
/// kosong, dan teruskan hasil Either apa adanya.
class _FakeRepo implements ContributionRepository {
  _FakeRepo(this.result);

  final Either<ContributionFailure, SubmitWordResult> result;
  String? lemma;
  String? languageId;
  List<SubmitWordMeaning>? meanings;
  String? dialectId;
  List<String>? categoryIds;
  List<String>? usageLabels;
  String? notes;
  List<String>? spellingVariants;
  List<SubmitWordRelation>? relatedWords;
  String? translationLanguageId;
  List<SubmitWordImage>? images;
  String? searchMissId;

  @override
  Future<Either<ContributionFailure, SubmitWordResult>> submitAnon({
    required String lemma,
    required String languageId,
    required List<SubmitWordMeaning> meanings,
    String? dialectId,
    String wordType = 'word',
    List<String> categoryIds = const [],
    List<String> usageLabels = const [],
    String? notes,
    List<String> spellingVariants = const [],
    List<SubmitWordRelation> relatedWords = const [],
    required String translationLanguageId,
    List<SubmitWordImage> images = const [],
    String? searchMissId,
  }) async {
    this.lemma = lemma;
    this.languageId = languageId;
    this.meanings = meanings;
    this.dialectId = dialectId;
    this.categoryIds = categoryIds;
    this.usageLabels = usageLabels;
    this.notes = notes;
    this.spellingVariants = spellingVariants;
    this.relatedWords = relatedWords;
    this.translationLanguageId = translationLanguageId;
    this.images = images;
    this.searchMissId = searchMissId;
    return result;
  }

  @override
  Future<Either<ContributionFailure, String>> confirmDuplicateMeaning({
    required String wordId,
    required String meaningId,
    required int value,
  }) async => Either.left(const ContributionFailure('tidak dipakai'));
}

SubmitAnonWordParams _params({
  String lemma = 'makai',
  String languageId = 'lan-sbs',
  String wordClassId = 'wc-01',
  String definition = 'memakai',
  bool isHaveDefinition = true,
  bool isHaveTranslation = true,
  List<String> translationTexts = const ['make'],
  List<String> exampleSentences = const [],
  String? dialectId,
  List<String> categoryIds = const [],
  String? notes,
  List<SubmitWordRelation> relatedWords = const [],
  List<SubmitWordImage> images = const [],
  String translationLanguageId = 'lan-idn',
}) {
  return SubmitAnonWordParams(
    lemma: lemma,
    languageId: languageId,
    meanings: [
      SubmitAnonWordMeaningParams(
        wordClassId: wordClassId,
        definition: definition,
        isHaveDefinition: isHaveDefinition,
        isHaveTranslation: isHaveTranslation,
        translationTexts: translationTexts,
        exampleSentences: exampleSentences,
      ),
    ],
    dialectId: dialectId,
    categoryIds: categoryIds,
    notes: notes,
    relatedWords: relatedWords,
    images: images,
    translationLanguageId: translationLanguageId,
  );
}

void main() {
  const result = SubmitWordResult(
    wordId: '01ARZ3NDEKTSV4RRFFQ69G5FAV',
    status: 'pending_review',
  );

  test('sukses - input di-trim, translation/category kosong dibuang', () async {
    final repo = _FakeRepo(Either.right(result));
    final usecase = SubmitAnonWordUseCase(repo);

    final r = await usecase(
      _params(
        lemma: '  makai  ',
        definition: '  memakai  ',
        dialectId: '  ',
        translationTexts: ['  ', '  make  ', '  '],
        categoryIds: ['  ', 'kat-01'],
        notes: 'halo',
      ),
    );

    expect(repo.lemma, 'makai');
    expect(repo.meanings, hasLength(1));
    expect(repo.meanings!.first.definition, 'memakai');
    expect(repo.meanings!.first.translationTexts, ['make']);
    expect(repo.categoryIds, ['kat-01']);
    // dialectId kosong → di-null-kan (kontrak repository optional)
    expect(repo.dialectId, isNull);
    expect(repo.notes, 'halo');
    expect(repo.translationLanguageId, 'lan-idn');
    expect(r.getRight().toNullable()?.status, 'pending_review');
  });

  test('gagal - failure diteruskan tanpa diubah', () async {
    final repo = _FakeRepo(
      Either.left(
        const ContributionFailure(
          'Language ID tidak dikenal',
          errorCode: 'VALIDATION_ERROR',
        ),
      ),
    );
    final usecase = SubmitAnonWordUseCase(repo);

    final r = await usecase(_params(languageId: 'lan-xyz'));

    final failure = r.getLeft().toNullable();
    expect(failure?.message, 'Language ID tidak dikenal');
    expect(failure?.errorCode, 'VALIDATION_ERROR');
  });

  test(
    'translation teks tetap di-trim tapi tidak dipaksa minimal 1 di usecase',
    () async {
      final repo = _FakeRepo(Either.right(result));
      final usecase = SubmitAnonWordUseCase(repo);

      await usecase(
        _params(lemma: 'x', definition: 'y', translationTexts: ['   ']),
      );

      // usecase hanya membersihkan; validasi minimal 1 ada di backend
      // (VALIDATION_ERROR inline field translation_texts).
      expect(repo.meanings!.first.translationTexts, isEmpty);
    },
  );

  test('contoh kosong dibuang dan yang terisi di-trim', () async {
    final repo = _FakeRepo(Either.right(result));
    final usecase = SubmitAnonWordUseCase(repo);

    await usecase(
      _params(exampleSentences: const ['  nak makan  ', '   ', 'udah makan']),
    );

    expect(repo.meanings!.first.exampleSentences, ['nak makan', 'udah makan']);
  });

  test(
    'tanpa definisi - paksa definition "-" saja; terjemahan tetap',
    () async {
      final repo = _FakeRepo(Either.right(result));
      final usecase = SubmitAnonWordUseCase(repo);

      await usecase(
        _params(
          definition: 'akan diabaikan',
          isHaveDefinition: false,
          translationTexts: ['  memakai  '],
          relatedWords: [
            SubmitWordRelation(relationType: 'synonym', lemma: ' make '),
            SubmitWordRelation(relationType: 'antonym', lemma: 'makai'),
          ],
        ),
      );

      expect(repo.meanings!.first.definition, '-');
      expect(repo.meanings!.first.translationTexts, ['memakai']);
      expect(repo.meanings!.first.isHaveDefinition, false);
      // lemma induk didrop; synonym tetap
      expect(repo.relatedWords?.length, 1);
      expect(repo.relatedWords?.first.lemma, 'make');
      expect(repo.relatedWords?.first.relationType, 'synonym');
    },
  );

  test(
    'tanpa padanan - translations kosong, isHaveTranslation false',
    () async {
      final repo = _FakeRepo(Either.right(result));
      final usecase = SubmitAnonWordUseCase(repo);

      await usecase(
        _params(
          definition: 'uraian makna tanpa padanan tunggal',
          isHaveTranslation: false,
          translationTexts: ['akan diabaikan'],
        ),
      );

      expect(
        repo.meanings!.first.definition,
        'uraian makna tanpa padanan tunggal',
      );
      expect(repo.meanings!.first.translationTexts, isEmpty);
      expect(repo.meanings!.first.isHaveTranslation, false);
    },
  );

  test('multi makna - semua blok di-trim dan order terjaga', () async {
    final repo = _FakeRepo(Either.right(result));
    final usecase = SubmitAnonWordUseCase(repo);

    await usecase(
      const SubmitAnonWordParams(
        lemma: '  makatn  ',
        languageId: 'lan-sbs',
        translationLanguageId: 'lan-idn',
        meanings: [
          SubmitAnonWordMeaningParams(
            wordClassId: ' wc-1 ',
            definition: '  makan  ',
            translationTexts: ['  makan  '],
          ),
          SubmitAnonWordMeaningParams(
            wordClassId: 'wc-2',
            definition: 'sudah makan',
            isHaveDefinition: true,
            isHaveTranslation: false,
            translationTexts: ['abaikan'],
          ),
        ],
      ),
    );

    expect(repo.lemma, 'makatn');
    expect(repo.meanings, hasLength(2));
    expect(repo.meanings![0].wordClassId, 'wc-1');
    expect(repo.meanings![0].definition, 'makan');
    expect(repo.meanings![0].translationTexts, ['makan']);
    expect(repo.meanings![1].definition, 'sudah makan');
    expect(repo.meanings![1].isHaveTranslation, false);
    expect(repo.meanings![1].translationTexts, isEmpty);
  });
}
