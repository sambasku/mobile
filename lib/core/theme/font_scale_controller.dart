import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'font_scale_controller.g.dart';

/// Faktor skala teks pilihan user. Nilai mengikuti konvensi aksesibilitas
/// (0.85 kecil, 1.0 normal, 1.15 besar, 1.3 sangat besar). Diterapkan di
/// App.builder lewat MediaQuery textScaler override.
@Riverpod(keepAlive: true)
class FontScaleController extends _$FontScaleController {
  static const prefKey = 'font_scale_v1';

  /// Seed dari [preload]; default 1.0.
  static double initial = 1.0;

  static const allowedValues = [0.85, 1.0, 1.15, 1.3];

  static Future<void> preload([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    initial = _fromRaw(p.getDouble(prefKey));
  }

  static double _fromRaw(double? raw) =>
      raw != null && allowedValues.contains(raw) ? raw : 1.0;

  @override
  double build() => initial;

  Future<void> set(double scale) async {
    if (!allowedValues.contains(scale)) return;
    state = scale;
    initial = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(prefKey, scale);
  }
}
