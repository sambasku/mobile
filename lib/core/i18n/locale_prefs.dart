import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';

/// Persist pilihan bahasa UI. Mirror pola [OnboardingPrefs]: seed statis
/// dibaca sinkron (router/interceptor), fetch async hanya di preload.
class LocalePrefs {
  LocalePrefs._();

  static const _localeKey = 'sk_locale';
  static const _chosenKey = 'sk_locale_chosen';

  /// Seed memori - default `id` / false sebelum preload jalan.
  static AppLocale locale = AppLocale.id;
  static bool chosen = false;

  static Future<void> preload([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    locale = AppLocale.fromCode(p.getString(_localeKey));
    chosen = p.getBool(_chosenKey) ?? false;
  }

  /// Simpan pilihan + tandai sudah memilih (first-run gate terbuka).
  static Future<void> set(AppLocale next, [SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setString(_localeKey, next.code);
    await p.setBool(_chosenKey, true);
    locale = next;
    chosen = true;
  }

  /// Reset penuh (dev tool / aksi eksplisit "Reset bahasa").
  static Future<void> reset([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.remove(_localeKey);
    await p.remove(_chosenKey);
    locale = AppLocale.id;
    chosen = false;
  }
}
