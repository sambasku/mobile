import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/analytics_service.dart';

part 'theme_mode_controller.g.dart';

/// Preferensi tema: toggle menyimpan light/dark/system ke SharedPreferences.
///
/// [preload] wajib dipanggil di main sebelum runApp supaya frame pertama
/// tidak flash ke ThemeMode.system (ikut device) lalu jump ke nilai prefs.
@Riverpod(keepAlive: true)
class ThemeModeController extends _$ThemeModeController {
  static const prefKey = 'themeMode';

  /// Seed dari [preload] - default system hanya jika preload belum jalan.
  static ThemeMode initial = ThemeMode.system;

  static Future<void> preload([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    // Ada nilai tersimpan → pakai itu. Tidak ada / tidak dikenal → system.
    final raw = p.getString(prefKey);
    initial = raw == null || raw.isEmpty ? ThemeMode.system : _parse(raw);
  }

  static ThemeMode _parse(String raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.system,
  };

  @override
  ThemeMode build() => initial;

  /// Toggle berdasar brightness efektif saat ini → lawannya, lalu persist.
  Future<void> toggle(Brightness currentEffective) async {
    final next = currentEffective == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    state = next;
    initial = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, next.name);
    AnalyticsService.instance.log(
      AnalyticsEvents.themeChange,
      params: {'mode': next.name},
    );
  }

  /// Set mode eksplisit (system/light/dark) dari menu Tampilan, lalu persist.
  Future<void> set(ThemeMode mode) async {
    state = mode;
    initial = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, mode.name);
    AnalyticsService.instance.log(
      AnalyticsEvents.themeChange,
      params: {'mode': mode.name},
    );
  }
}
