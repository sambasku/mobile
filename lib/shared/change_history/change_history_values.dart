import 'dart:convert';

import '../../l10n/app_localizations.dart';

/// Cek apakah field berisi metadata teknis yang tidak perlu ditampilkan ke user.
bool isTechnicalChangeField(String field) {
  final f = field.trim().toLowerCase();
  if (f.endsWith('_id') || f.endsWith('_ids') || f.endsWith('_by')) return true;
  const bookkeeping = {
    'comma_split',
    'created',
    'merged_on_create',
    'merged_on_update',
    'self_applied',
    'source_word_id',
    'split_from_word_id',
    'meaning_ids',
    'merged_word_ids',
    'reopened_by',
    'url',
  };
  return bookkeeping.contains(f);
}

/// Bersihkan value mentah agar user-friendly.
/// - ULID polos → null (sembunyikan)
/// - JSON dengan kunci added/removed → "Ditambah N, dihapus M"
/// - JSON object lain → null (sembunyikan dump teknis)
/// - JSON array/primitive → null (sembunyikan)
/// - Selain itu (string biasa) → kembalikan apa adanya
String? friendlyChangeValue(String value, AppLocalizations l10n) {
  final v = value.trim();
  if (v.isEmpty) return null;

  // ULID Crockford base32 (26 chars) - case insensitive
  if (RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$', caseSensitive: false).hasMatch(v)) {
    return null;
  }

  // Coba parse JSON
  try {
    final decoded = jsonDecode(v);
    if (decoded is Map) {
      // relations/variants/images audit format: {added: [...], removed: [...], set_primary: [...]}
      final added = (decoded['added'] is List)
          ? (decoded['added'] as List).length
          : 0;
      final removed = (decoded['removed'] is List)
          ? (decoded['removed'] as List).length
          : 0;
      final setPrimary = (decoded['set_primary'] is List)
          ? (decoded['set_primary'] as List).length
          : 0;
      if (added > 0 || removed > 0 || setPrimary > 0) {
        return [
          if (added > 0) l10n.historyAdded('$added'),
          if (removed > 0) l10n.historyRemoved('$removed'),
          if (setPrimary > 0) l10n.historySetPrimary('$setPrimary'),
        ].join(', ');
      }
      // JSON object lain (contoh: {status: "published", reason_code: "spam"}) → sembunyikan
      return null;
    }
    // JSON array atau primitive lain (boolean, number) → sembunyikan
    return null;
  } catch (_) {
    // Bukan JSON valid → biarkan apa adanya (string biasa)
  }
  return v;
}

const changeHistoryFieldLabelKeys = <String, String>{
  'lemma': 'lemma',
  'notes': 'notes',
  'definition': 'definition',
  'translation': 'translation',
  'translations': 'translation',
  'meaning': 'meaning',
  'meanings': 'meaning',
  'meanings_count': 'meaning',
  'example': 'example',
  'examples': 'example',
  'source_sentence': 'example',
  'variant': 'variant',
  'variants': 'variant',
  'category': 'category',
  'categories': 'category',
  'relation': 'relation',
  'relations': 'relation',
  'related_words': 'relation',
  'image': 'image',
  'images': 'image',
  'pronunciation': 'pronunciation',
  'pronunciations': 'pronunciation',
  'word_type': 'wordType',
  'language_id': 'language',
  'is_verified': 'verificationStatus',
  'status': 'status',
  'duplicate_vote': 'support',
  'translation_text': 'translation',
  // Teknis: label hanya untuk fallback, tetap disembunyikan lewat isTechnicalChangeField
  'comment': 'notes',
  'reason_code': 'reason',
  'is_corrected': 'corrected',
  'comma_split': 'commaSeparated',
  'created': 'created',
  'merged_on_create': 'mergedOnCreate',
  'merged_on_update': 'mergedOnEdit',
  'self_applied': 'selfApplied',
  'source_word_id': 'sourceId',
  'split_from_word_id': 'splitOriginId',
  'meaning_ids': 'meaningId',
  'merged_word_ids': 'mergedWordId',
};

String _fieldLabel(String key, AppLocalizations l10n) => switch (key) {
  'lemma' => l10n.historyFieldLemma,
  'notes' => l10n.historyFieldNotes,
  'definition' => l10n.historyFieldDefinition,
  'translation' => l10n.historyFieldTranslation,
  'meaning' => l10n.historyFieldMeaning,
  'example' => l10n.historyFieldExample,
  'variant' => l10n.historyFieldVariant,
  'category' => l10n.historyFieldCategory,
  'relation' => l10n.historyFieldRelation,
  'image' => l10n.historyFieldImage,
  'pronunciation' => l10n.historyFieldPronunciation,
  'wordType' => l10n.historyFieldWordType,
  'language' => l10n.historyFieldLanguage,
  'verificationStatus' => l10n.historyFieldVerificationStatus,
  'status' => l10n.historyFieldStatus,
  'support' => l10n.historyFieldSupport,
  'reason' => l10n.historyFieldReason,
  'corrected' => l10n.historyFieldCorrected,
  'commaSeparated' => l10n.historyFieldCommaSeparated,
  'created' => l10n.historyFieldCreated,
  'mergedOnCreate' => l10n.historyFieldMergedOnCreate,
  'mergedOnEdit' => l10n.historyFieldMergedOnEdit,
  'selfApplied' => l10n.historyFieldSelfApplied,
  'sourceId' => l10n.historyFieldSourceId,
  'splitOriginId' => l10n.historyFieldSplitOriginId,
  'meaningId' => l10n.historyFieldMeaningId,
  'mergedWordId' => l10n.historyFieldMergedWordId,
  _ => key,
};

/// Label field untuk timeline: label dari server (wisata, kuliner) menang;
/// kalau kosong (riwayat kata) pakai peta lokal ber-ARB.
String changeHistoryFieldLabel({
  required String field,
  required String entity,
  String? serverLabel,
  required AppLocalizations l10n,
}) {
  final fromServer = serverLabel?.trim();
  if (fromServer != null && fromServer.isNotEmpty) return fromServer;
  final f = field.trim().toLowerCase();
  final e = entity.trim().toLowerCase();
  final key = changeHistoryFieldLabelKeys[f] ?? changeHistoryFieldLabelKeys[e];
  if (key != null) return _fieldLabel(key, l10n);
  return field.isNotEmpty ? field : entity;
}
