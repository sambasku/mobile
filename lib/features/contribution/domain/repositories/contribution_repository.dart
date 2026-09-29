import 'package:fpdart/fpdart.dart';

import '../entities/submit_word_result.dart';
import '../failures/contribution_failure.dart';

/// Satu gambar siap dikirim (upload GitHub ATAU stock Media Explorer).
class SubmitWordImage {
  const SubmitWordImage({
    required this.url,
    required this.providerFileId,
    this.provider,
    this.sha,
    this.altText,
    this.isPrimary = false,
    this.contentWarnings = const [],
  });

  final String url;
  final String providerFileId;
  /// Stock: pexels|… ; upload: null.
  final String? provider;
  final String? sha;
  final String? altText;
  final bool isPrimary;
  /// Peringatan konten dipilih kontributor. V1: 'kekerasan'. Kosong = [].
  final List<String> contentWarnings;
}

/// Relasi inline (Form B) - sinonim/antonim lemma baru ikut makna induk.
class SubmitWordRelation {
  const SubmitWordRelation({required this.relationType, required this.lemma});

  /// `synonym` | `antonym`
  final String relationType;
  final String lemma;
}

/// Satu makna dalam usulan kata (API `meanings[]`).
class SubmitWordMeaning {
  const SubmitWordMeaning({
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

  /// Kalimat contoh bahasa sumber. Kosong = tidak dikirim.
  final List<String> exampleSentences;
}

/// Kontrak repository submit kata.
///
/// Method `submitAnon` = endpoint `POST /api/v1/contributions/words`
/// (auth opsional). Tanpa token → atribusi anonim; Dio menyisipkan
/// Bearer saat login → atribusi user real (backend optionalAuthenticate).
/// Hasil selalu `pending_review` untuk contributor.
/// `images` opsional - hanya untuk user yang sudah upload via token.
abstract interface class ContributionRepository {
  Future<Either<ContributionFailure, SubmitWordResult>> submitAnon({
    required String lemma,
    required String languageId,
    required List<SubmitWordMeaning> meanings,
    String? dialectId,

    /// `word` | `idiom` | `peribahasa` | `ungkapan` (API `word_type`).
    String wordType = 'word',
    List<String> categoryIds = const [],
    List<String> usageLabels = const [],
    String? notes,
    // Ejaan alternatif (variasi penulisan, docs/api/11) - dikirim sebagai
    // variants[] variant_type 'alternative'.
    List<String> spellingVariants = const [],
    // Sinonim/antonim inline Form B (docs/api/04).
    List<SubmitWordRelation> relatedWords = const [],
    // Bahasa target terjemahan = Indonesia (IDN), di-resolve dari page.
    required String translationLanguageId,
    List<SubmitWordImage> images = const [],
    String? searchMissId,
  });

  /// Vote + catat riwayat saat makna exact sudah ada (409 DUPLICATE_MEANING).
  Future<Either<ContributionFailure, String>> confirmDuplicateMeaning({
    required String wordId,
    required String meaningId,
    required int value,
  });
}
