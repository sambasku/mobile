import 'package:sambasku_mobile/l10n/app_localizations.dart';

import '../../../shared/utils/public_account_name.dart';
import '../domain/entities/word_detail.dart';
import '../domain/entities/word_summary.dart';

/// Label UI untuk kode `usage_labels` (domain simpan kode stabil saja).
String usageLabelLabel(String code, AppLocalizations l10n) => switch (code) {
  'kasar' => l10n.dictUsageKasar,
  'tabu' => l10n.dictUsageTabu,
  'informal' => l10n.dictUsageInformal,
  'halus' => l10n.dictUsageHalus,
  'seksual' => l10n.dictUsageSeksual,
  'diskriminatif' => l10n.dictUsageDiskriminatif,
  _ => code,
};

String wordTypeLabel(String wordType, AppLocalizations l10n) =>
    switch (wordType) {
      'idiom' => l10n.dictWordTypeIdiom,
      'peribahasa' => l10n.dictWordTypeProverb,
      'ungkapan' => l10n.dictWordTypeExpression,
      _ => l10n.dictWordTypeWord,
    };

String wordDetailTypeLabel(WordDetail detail, AppLocalizations l10n) =>
    wordTypeLabel(detail.wordType, l10n);

String wordSummaryTypeLabel(WordSummary word, AppLocalizations l10n) =>
    wordTypeLabel(word.wordType, l10n);

String relationLabel(String relationType, AppLocalizations l10n) =>
    switch (relationType) {
      'synonym' => l10n.dictRelationSynonym,
      'antonym' => l10n.dictRelationAntonym,
      'has_component' => l10n.dictRelationComponent,
      'see_also' => l10n.dictRelationSeeAlso,
      'derived_from' => l10n.dictRelationDerivedFrom,
      'variant_of' => l10n.dictRelationVariantOf,
      'nonstandard_of' => l10n.dictRelationNonstandardOf,
      _ => relationType,
    };

String variantTypeLabel(String variantType, AppLocalizations l10n) =>
    switch (variantType) {
      'alternative' => l10n.dictVariantAlternative,
      'inflection' => l10n.dictVariantInflection,
      'derivation' => l10n.dictVariantDerivation,
      'reduplication' => l10n.dictVariantReduplication,
      _ => variantType,
    };

/// Baris atribusi "Dibuat oleh X" / "Diverifikasi oleh X".
String? creatorAttributionLabel(WordDetail detail, AppLocalizations l10n) {
  final name = _attributionName(detail.createdBy);
  return name == null ? null : l10n.dictAttributionCreatedBy(name);
}

String? verifierAttributionLabel(WordDetail detail, AppLocalizations l10n) {
  final name = _attributionName(detail.verifiedBy);
  return name == null ? null : l10n.dictAttributionVerifiedBy(name);
}

String? combinedAttributionLabel(WordDetail detail, AppLocalizations l10n) {
  if (!detail.authoredAndVerifiedBySamePerson) return null;
  final name = _attributionName(detail.verifiedBy ?? detail.createdBy);
  return name == null ? null : l10n.dictAttributionCreatedAndVerifiedBy(name);
}

/// Nama penutur; fallback label anonim.
String displaySpeaker(WordAudio audio, AppLocalizations l10n) {
  final name = audio.speakerName?.trim();
  return (name == null || name.isEmpty) ? l10n.dictSpeakerAnonymous : name;
}

String? _attributionName(WordVerifier? person) {
  if (person == null || person.username.isEmpty) return null;
  final name = person.displayName.trim().isNotEmpty
      ? person.displayName.trim()
      : person.username;
  return displayPublicUsername(name);
}
