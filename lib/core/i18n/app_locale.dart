import 'dart:ui' show Locale;

/// Registry locale UI aplikasi - satu-satunya sumber daftar bahasa
/// (kontrak docs/mobile/MOBILE-I18N.md Section 2).
///
/// Kode internal memakai underscore (`id_SBS`) selaras ARB; BCP-47
/// hyphen (`id-SBS`) hanya untuk deep link web + header Accept-Language.
enum AppLocale {
  id('id', 'id', 'Bahasa Indonesia'),
  sbs('id_SBS', 'id-SBS', 'Bahasa Sambas');

  const AppLocale(this.code, this.bcp47, this.label);

  /// Kode Flutter/ARB/log (underscore).
  final String code;

  /// BCP-47 (hyphen) untuk header + deep link web.
  final String bcp47;

  /// Label bahasa ditulis dalam bahasa itu sendiri.
  final String label;

  Locale toLocale() => switch (this) {
    AppLocale.id => const Locale('id'),
    AppLocale.sbs => const Locale('id', 'SBS'),
  };

  static AppLocale fromCode(String? code) => switch (code) {
    'id_SBS' => AppLocale.sbs,
    _ => AppLocale.id,
  };

  /// Mapping web ↔ app locale (helper tunggal, kontrak Section 2).
  static AppLocale fromWeb(String? bcp47) => switch (bcp47) {
    'id-SBS' => AppLocale.sbs,
    _ => AppLocale.id,
  };

  static const all = AppLocale.values;
}
