import '../../l10n/app_localizations.dart';
import 'locale_prefs.dart';

/// l10n untuk lapisan tanpa `BuildContext` (adapter, usecase, notifier).
/// Membaca bahasa aktif dari seed [LocalePrefs].
///
/// Pakai hanya untuk pesan fallback yang dibuat di dalam kode. Pesan dari
/// server tetap dipakai apa adanya (server yang menentukan bahasanya).
// ponytail: statis, tidak reaktif. Pesan fallback dibuat saat kegagalan
// terjadi, jadi bahasa saat itu sudah benar. Kalau nanti perlu teks lama
// ikut berganti tanpa rebuild, simpan kode error lalu map di UI.
AppLocalizations get l10n =>
    lookupAppLocalizations(LocalePrefs.locale.toLocale());
