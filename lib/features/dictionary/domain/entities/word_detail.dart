import '../../../../core/models/image_attribution.dart';
import '../../../../shared/utils/public_account_name.dart';

/// Closed enum `usage_labels` (sinkron API / console).
const kUsageLabels = <String>[
  'kasar',
  'tabu',
  'informal',
  'halus',
  'seksual',
  'diskriminatif',
];

/// Register: gaya/pantangan berbahasa.
const kRegisterUsageLabels = <String>['kasar', 'tabu', 'informal', 'halus'];

/// Peringatan: sensitivitas isi makna.
const kWarningUsageLabels = <String>['seksual', 'diskriminatif'];

/// Label UI (ID) untuk kode `usage_labels`.
String usageLabelLabel(String code) => switch (code) {
  'kasar' => 'Kasar',
  'tabu' => 'Tabu',
  'informal' => 'Informal',
  'halus' => 'Halus',
  'seksual' => 'Seksual',
  'diskriminatif' => 'Diskriminatif',
  _ => code,
};

/// Badge lebih menonjol: kasar/tabu/seksual/diskriminatif.
bool isProminentUsageLabel(String code) =>
    code == 'kasar' ||
    code == 'tabu' ||
    code == 'seksual' ||
    code == 'diskriminatif';

/// Kode `usage_labels` yang dikenal, urutan enum. Payload review camelCase.
List<String> knownUsageLabels(Object? raw) {
  if (raw is! List) return const [];
  final present = <String>{
    for (final item in raw)
      if (item != null) item.toString(),
  };
  return [
    for (final code in kUsageLabels)
      if (present.contains(code)) code,
  ];
}

/// `halus` dan `kasar` saling bertentangan.
bool hasConflictingUsageLabels(Iterable<String> labels) {
  var hasHalus = false;
  var hasKasar = false;
  for (final code in labels) {
    if (code == 'halus') hasHalus = true;
    if (code == 'kasar') hasKasar = true;
    if (hasHalus && hasKasar) return true;
  }
  return false;
}

/// Detail kata lengkap (domain) - hasil GET /api/v1/words/:id.
class WordDetail {
  const WordDetail({
    required this.id,
    required this.lemma,
    required this.languageId,
    required this.wordType,
    required this.status,
    required this.isVerified,
    required this.isCorrected,
    this.selfVerified = false,
    this.notes,
    this.verifiedAt,
    this.verifiedBy,
    this.createdBy,
    this.meanings = const [],
    this.categories = const [],
    this.usageLabels = const [],
    this.pronunciations = const [],
    this.audios = const [],
    this.images = const [],
    this.relatedWords = const [],
    this.appearsIn = const [],
    this.variants = const [],
  });

  final String id;
  final String lemma;
  final String languageId;
  final String? notes;
  final String wordType;
  final String status;
  final bool isVerified;
  final bool isCorrected;
  final bool selfVerified;
  final String? verifiedAt;
  final WordVerifier? verifiedBy;
  final WordVerifier? createdBy;
  final List<WordMeaning> meanings;
  final List<WordCategory> categories;

  /// Kode register & peringatan (`usage_labels` API).
  final List<String> usageLabels;
  final List<WordPronunciation> pronunciations;
  final List<WordAudio> audios;
  final List<WordImage> images;
  final List<RelatedWord> relatedWords;
  final List<RelatedWord> appearsIn;
  final List<WordVariant> variants;

  String get wordTypeLabel => switch (wordType) {
    'idiom' => 'Idiom',
    'peribahasa' => 'Peribahasa',
    'ungkapan' => 'Ungkapan',
    _ => 'Kata',
  };

  String? get creatorAttributionLabel {
    final person = createdBy;
    if (person == null || person.username.isEmpty) return null;
    return 'Dibuat oleh ${_attributionLabel(person)}';
  }

  String? get verifierAttributionLabel {
    final person = verifiedBy;
    if (person == null || person.username.isEmpty) return null;
    return 'Diverifikasi oleh ${_attributionLabel(person)}';
  }

  /// Satu kalimat kalau orangnya sama, supaya nama tidak tertulis dua kali.
  bool get authoredAndVerifiedBySamePerson {
    final creator = createdBy?.username;
    final verifier = verifiedBy?.username;
    final hasCreator = creator != null && creator.isNotEmpty;
    final hasVerifier = verifier != null && verifier.isNotEmpty;
    if (hasCreator && hasVerifier) return creator == verifier;
    return selfVerified && hasVerifier;
  }

  String? get combinedAttributionLabel {
    if (!authoredAndVerifiedBySamePerson) return null;
    final person = verifiedBy ?? createdBy;
    if (person == null || person.username.isEmpty) return null;
    return 'Dibuat dan diverifikasi oleh ${_attributionLabel(person)}';
  }

  static String _attributionLabel(WordVerifier person) {
    final name = person.displayName.trim().isNotEmpty
        ? person.displayName.trim()
        : person.username;
    return displayPublicUsername(name);
  }

  /// Orang yang sama dan perannya tim verifikator, bukan kontributor.
  bool get combinedByVerifier {
    if (!authoredAndVerifiedBySamePerson) return false;
    final role = (verifiedBy?.role ?? createdBy?.role)?.toLowerCase();
    return role == 'admin' ||
        role == 'editor' ||
        role == 'root' ||
        role == 'reviewer';
  }
}

class WordVerifier {
  const WordVerifier({
    required this.username,
    required this.displayName,
    required this.role,
  });

  final String username;
  /// Nama tampilan untuk label atribusi; fallback ke [username] di mapper.
  final String displayName;
  final String role;
}

class WordMeaning {
  const WordMeaning({
    required this.id,
    this.wordClassId,
    this.wordClassCode,
    this.wordClassName,
    this.definition,
    required this.orderIndex,
    this.translations = const [],
    this.examples = const [],
  });

  final String id;
  final String? wordClassId;

  /// Kode singkat kelas kata dari API (`n`, `v`, `adj`, …) untuk format `[n]`.
  final String? wordClassCode;
  final String? wordClassName;
  final String? definition;
  final int orderIndex;
  final List<WordTranslation> translations;
  final List<WordExample> examples;

  /// Label bracket kamus, mis. `[n]`. Kosong jika kode tidak ada.
  String? get wordClassBracket {
    final code = wordClassCode?.trim();
    if (code == null || code.isEmpty) return null;
    return '[${code.toLowerCase()}]';
  }
}

class WordTranslation {
  const WordTranslation({
    required this.text,
    required this.type,
    this.languageId,
  });

  final String text;
  final String type;
  final String? languageId;

  String get typeLabel => switch (type) {
    'descriptive' => 'deskriptif',
    'idiomatic' => 'idiomatis',
    _ => 'langsung',
  };
}

class WordExample {
  const WordExample({
    required this.id,
    required this.sourceSentence,
    this.targetSentence,
    this.audios = const [],
  });

  final String id;
  final String sourceSentence;

  /// Null bila contoh belum punya terjemahan kalimat (`target_sentence`).
  final String? targetSentence;
  final List<WordAudio> audios;
}

/// Audio pelafalan (kata atau contoh kalimat).
class WordAudio {
  const WordAudio({
    required this.id,
    required this.url,
    this.dialectId,
    this.speakerName,
    this.durationMs,
    this.isPrimary = false,
    this.mimeType,
    this.isVerified = true,
  });

  final String id;
  final String url;
  final String? dialectId;
  final String? speakerName;
  final int? durationMs;
  final bool isPrimary;
  final String? mimeType;

  /// false jika API mengembalikan is_verified: false.
  /// Default true agar payload lama tanpa field tetap normal.
  final bool isVerified;

  bool get isPendingReview => !isVerified;

  String get displaySpeaker {
    final name = speakerName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Anonim';
  }

  String? get formattedDuration {
    final ms = durationMs;
    if (ms == null || ms <= 0) return null;
    final totalSec = (ms / 1000).round();
    final min = totalSec ~/ 60;
    final sec = totalSec % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }
}

/// Urutkan: primary dulu, sisanya urutan API.
List<WordAudio> sortWordAudios(List<WordAudio> audios) {
  if (audios.length <= 1) return audios;
  final primary = audios.where((a) => a.isPrimary).toList(growable: false);
  final rest = audios.where((a) => !a.isPrimary).toList(growable: false);
  return [...primary, ...rest];
}

class WordCategory {
  const WordCategory({required this.id, required this.name});

  final String id;
  final String name;
}

class WordPronunciation {
  const WordPronunciation({required this.notation, required this.value});

  final String notation;
  final String value;
}

class WordImage {
  const WordImage({
    required this.id,
    required this.url,
    this.altText,
    required this.isPrimary,
    this.isVerified = true,
    this.contentWarnings = const [],
    this.attribution,
  });

  final String id;
  final String url;
  final String? altText;
  final bool isPrimary;

  /// Kredit foto stock Media Explorer; null = upload / data lama.
  final ImageAttribution? attribution;

  /// false jika API mengembalikan is_verified: false (gambar staging belum
  /// disetujui). Default true agar payload lama yang tidak menyertakan
  /// field ini tetap berfungsi normal.
  final bool isVerified;

  /// Peringatan konten per gambar. V1: 'kekerasan'. Kosong = aman.
  final List<String> contentWarnings;

  /// Gambar belum terverifikasi; tampilkan asset lokal, bukan URL asli.
  bool get isPendingReview => !isVerified;

  /// Gambar mengandung konten kekerasan; blur sampai user konfirmasi.
  bool get hasViolenceWarning => contentWarnings.contains('kekerasan');
}

class RelatedWord {
  const RelatedWord({
    required this.wordId,
    required this.lemma,
    required this.relationType,
  });

  final String wordId;
  final String lemma;
  final String relationType;

  String get relationLabel => switch (relationType) {
    'synonym' => 'Sinonim',
    'antonym' => 'Antonim',
    'has_component' => 'Komponen',
    'see_also' => 'Lihat juga',
    'derived_from' => 'Diturunkan dari',
    _ => relationType,
  };
}

class WordVariant {
  const WordVariant({
    required this.form,
    required this.variantType,
    this.affixType,
    this.affixValue,
    this.notes,
  });

  final String form;
  final String variantType;
  final String? affixType;
  final String? affixValue;
  final String? notes;

  String get variantTypeLabel => switch (variantType) {
    'alternative' => 'Variasi penulisan',
    'inflection' => 'Fleksi',
    'derivation' => 'Derivasi',
    'reduplication' => 'Reduplikasi',
    _ => variantType,
  };

  bool get isSpellingVariant => variantType == 'alternative';
}
