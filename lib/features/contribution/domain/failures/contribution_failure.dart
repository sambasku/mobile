import '../../../../core/models/api_response.dart';

/// Failure untuk operasi submit kata (anonim / login).
///
/// Mendukung:
/// - 400 VALIDATION_ERROR: `details[]` berisi error inline per field
///   → di UI tampilkan di bawah FTextField yang sesuai (mobile-base-stack
///   Section 11 mapping VALIDATION_ERROR).
/// - 429 RATE_LIMITED: usulan dikirim terlalu sering → toast
///   "Terlalu banyak usulan dikirim. Coba lagi nanti".
class ContributionFailure {
  const ContributionFailure(
    this.message, {
    this.errorCode,
    this.details = const <ApiErrorDetail>[],
    this.data,
  });

  final String message;
  final String? errorCode;
  final List<ApiErrorDetail> details;
  /// Payload opsional (mis. DUPLICATE_MEANING: word_id / meaning_id / lemma).
  final Map<String, dynamic>? data;

  /// Cari error inline untuk field tertentu. Kosong = tidak ada error.
  /// Dipakai UI: `Text(failure.errorFor('lemma') ?? '')` di bawah input.
  ///
  /// Field backend bertingkat di-normal-kan ke padanan field form:
  /// - `meanings.0.word_class_id` → `word_class_id`
  /// - `meanings.0.definition` → `definition`
  /// - `meanings.0.translations.0.language_id` → `translation_texts`
  ///
  /// Untuk multi-makna, prefer [errorForMeaning] agar index tidak campur.
  String? errorFor(String field) {
    for (final d in details) {
      if (_displayField(d.field) == field) return d.message;
    }
    return null;
  }

  /// Error inline per indeks makna (`meanings.N.*`).
  String? errorForMeaning(int index, String field) {
    final prefix = 'meanings.$index.';
    for (final d in details) {
      final path = d.field;
      if (field == 'translation_texts') {
        if (path.startsWith('${prefix}translations') ||
            path == '${prefix}is_have_translation') {
          return d.message;
        }
        continue;
      }
      if (path == '$prefix$field' || path.startsWith('$prefix$field.')) {
        return d.message;
      }
    }
    return null;
  }

  /// Normalisasi jalur field dari VALIDATION_ERROR backend (`meanings.N.*`)
  /// ke nama field UI; buang index array supaya `meanings.0.definition`
  /// dan `meanings.1.definition` sama-sama tampil di kolom definisi.
  String _displayField(String path) {
    final parts = path
        .split('.')
        .where((p) => int.tryParse(p) == null)
        .toList(growable: false);
    final flat = parts.join('.');
    if (flat.startsWith('meanings.')) {
      final inner = flat.substring('meanings.'.length);
      if (inner == 'translations' || inner.startsWith('translations.')) {
        return 'translation_texts';
      }
      return inner;
    }
    return flat;
  }

  bool get isRateLimited => errorCode == 'RATE_LIMITED';
  bool get isValidationError => errorCode == 'VALIDATION_ERROR';
  bool get isDuplicateMeaning => errorCode == 'DUPLICATE_MEANING';

  String? get duplicateWordId => data?['word_id']?.toString();
  String? get duplicateMeaningId => data?['meaning_id']?.toString();
  String? get duplicateLemma => data?['lemma']?.toString();
}
