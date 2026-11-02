import '../../core/i18n/l10n.dart';
import '../../l10n/app_localizations.dart';

/// Jenis entri API `word_type`. Bukan kelas kata.
/// [detail] boleh panjang: ditampilkan di bottom sheet, bukan di chip kartu.
const wordTypeOptionValues = <String>['word', 'idiom', 'peribahasa', 'ungkapan'];

/// Opsi dengan label/detail lokal (untuk UI picker).
List<({String value, String label, String detail})> wordTypeOptionsFor(
  AppLocalizations loc,
) => [
  (
    value: 'word',
    label: loc.wordTypeKata,
    detail: loc.wordTypeKataDetail,
  ),
  (
    value: 'idiom',
    label: loc.wordTypeIdiom,
    detail: loc.wordTypeIdiomDetail,
  ),
  (
    value: 'peribahasa',
    label: loc.wordTypePeribahasa,
    detail: loc.wordTypePeribahasaDetail,
  ),
  (
    value: 'ungkapan',
    label: loc.wordTypeUngkapan,
    detail: loc.wordTypeUngkapanDetail,
  ),
];

/// Alias untuk kode yang masih mengiterasi `wordTypeOptions` tanpa context.
List<({String value, String label, String detail})> get wordTypeOptions =>
    wordTypeOptionsFor(l10n);

String wordTypeOptionLabel(String? code) {
  for (final option in wordTypeOptions) {
    if (option.value == code) return option.label;
  }
  return l10n.wordTypeKata;
}
