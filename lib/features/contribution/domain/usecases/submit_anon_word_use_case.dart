import 'package:fpdart/fpdart.dart';

import '../entities/submit_word_result.dart';
import '../failures/contribution_failure.dart';
import '../repositories/contribution_repository.dart';

class SubmitAnonWordUseCase {
  const SubmitAnonWordUseCase(this._repository);

  final ContributionRepository _repository;

  /// Batas UI + payload: cukup untuk polisemi ringan, hindari form panjang.
  static const maxMeanings = 5;

  Future<Either<ContributionFailure, SubmitWordResult>> call(
    SubmitAnonWordParams params,
  ) {
    final lemma = params.lemma.trim();
    final dialectId = params.dialectId?.trim();
    final notes = params.notes?.trim();

    final meanings = <SubmitWordMeaning>[];
    for (final m in params.meanings.take(maxMeanings)) {
      // Placeholder definisi: hanya definisi sentinel "-" + flag false.
      // Padanan opsional: isHaveTranslation=false → translations [].
      // Kedua flag independen (form Definisi/Padanan boleh salah satu saja).
      final isHaveDefinition = m.isHaveDefinition;
      final isHaveTranslation = m.isHaveTranslation;
      final definition = isHaveDefinition ? m.definition.trim() : '-';
      final translations = isHaveTranslation
          ? m.translationTexts
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(growable: false)
          : <String>[];
      final exampleSentences = m.exampleSentences
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);

      meanings.add(
        SubmitWordMeaning(
          wordClassId: m.wordClassId.trim(),
          definition: definition,
          isHaveDefinition: isHaveDefinition,
          isHaveTranslation: isHaveTranslation,
          meaningSource: m.meaningSource,
          translationTexts: translations,
          exampleSentences: exampleSentences,
        ),
      );
    }

    final categoryIds = params.categoryIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final usageLabels = params.usageLabels
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final seenVariants = <String>{};
    final spellingVariants = params.spellingVariants
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.toLowerCase() != lemma.toLowerCase())
        .where((e) => seenVariants.add(e.toLowerCase()))
        .toList(growable: false);

    // Max 5 Form B per request (API); dedup lemma case-insensitive
    // (termasuk lemma induk).
    final seenRelated = <String>{lemma.toLowerCase()};
    final relatedWords = <SubmitWordRelation>[];
    for (final rel in params.relatedWords) {
      final relLemma = rel.lemma.trim();
      if (relLemma.isEmpty) continue;
      final key = relLemma.toLowerCase();
      if (!seenRelated.add(key)) continue;
      relatedWords.add(
        SubmitWordRelation(relationType: rel.relationType, lemma: relLemma),
      );
      if (relatedWords.length >= 5) break;
    }

    // Pastikan maksimal satu is_primary (mirror validator API).
    var sawPrimary = false;
    final images = <SubmitWordImage>[];
    for (final img in params.images) {
      final primary = img.isPrimary && !sawPrimary;
      if (primary) sawPrimary = true;
      images.add(
        SubmitWordImage(
          url: img.url,
          providerFileId: img.providerFileId,
          provider: img.provider,
          sha: img.sha,
          altText: img.altText,
          isPrimary: primary,
        ),
      );
    }
    if (images.isNotEmpty && !sawPrimary) {
      final first = images.first;
      images[0] = SubmitWordImage(
        url: first.url,
        providerFileId: first.providerFileId,
        provider: first.provider,
        sha: first.sha,
        altText: first.altText,
        isPrimary: true,
      );
    }

    final wordType = params.wordType.trim().isEmpty
        ? 'word'
        : params.wordType.trim();

    return _repository.submitAnon(
      lemma: lemma,
      languageId: params.languageId.trim(),
      meanings: meanings,
      dialectId: (dialectId != null && dialectId.isNotEmpty) ? dialectId : null,
      wordType: wordType,
      categoryIds: categoryIds,
      usageLabels: usageLabels,
      notes: (notes != null && notes.isNotEmpty) ? notes : null,
      spellingVariants: spellingVariants,
      relatedWords: relatedWords,
      translationLanguageId: params.translationLanguageId.trim(),
      images: images,
      searchMissId: params.searchMissId,
    );
  }
}

class SubmitAnonWordMeaningParams {
  const SubmitAnonWordMeaningParams({
    required this.wordClassId,
    required this.definition,
    this.isHaveDefinition = true,
    this.isHaveTranslation = true,
    this.meaningSource = 'manual',
    this.translationTexts = const [],
    this.exampleSentences = const [],
  });

  final String wordClassId;
  final String definition;
  final bool isHaveDefinition;
  final bool isHaveTranslation;
  /// `manual` | `kbbi` | `kbbi_edited`
  final String meaningSource;
  final List<String> translationTexts;
  final List<String> exampleSentences;
}

class SubmitAnonWordParams {
  const SubmitAnonWordParams({
    required this.lemma,
    required this.languageId,
    required this.meanings,
    required this.translationLanguageId,
    this.dialectId,
    this.wordType = 'word',
    this.categoryIds = const [],
    this.usageLabels = const [],
    this.notes,
    this.spellingVariants = const [],
    this.relatedWords = const [],
    this.images = const [],
    this.searchMissId,
  });

  final String lemma;
  final String languageId;
  final List<SubmitAnonWordMeaningParams> meanings;
  final String translationLanguageId;
  final String? dialectId;

  /// `word` | `idiom` | `peribahasa` | `ungkapan`
  final String wordType;
  final List<String> categoryIds;
  final List<String> usageLabels;
  final String? notes;
  final List<String> spellingVariants;
  final List<SubmitWordRelation> relatedWords;
  final List<SubmitWordImage> images;
  final String? searchMissId;
}
