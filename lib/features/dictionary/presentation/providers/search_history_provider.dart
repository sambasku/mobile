import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_history_provider.g.dart';

/// Riwayat pencarian kata: maksimal 10 query terakhir, tersimpan lokal di
/// SharedPreferences (tidak dikirim ke server). Dedup case-insensitive,
/// query sama digeser ke atas. [preload] wajib dipanggil di main sebelum
/// runApp supaya frame pertama sudah membawa riwayat tersimpan.
@Riverpod(keepAlive: true)
class SearchHistoryController extends _$SearchHistoryController {
  static const prefKey = 'search_history_v1';
  static const maxEntries = 10;

  /// Seed dari [preload]; ikut diperbarui tiap persist agar invalidate
  /// tidak mengembalikan state basi.
  static List<String> initial = const [];

  static Future<void> preload([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    initial = p.getStringList(prefKey) ?? const [];
  }

  @override
  List<String> build() => initial;

  /// Catat query yang benar-benar dieksekusi (dipanggil dari hasil load,
  /// bukan tiap ketikan). Kurang dari 2 karakter dianggap bukan query.
  Future<void> record(String rawQuery) async {
    final q = rawQuery.trim();
    if (q.length < 2) return;
    final lower = q.toLowerCase();
    final next = [
      q,
      ...state.where((e) => e.toLowerCase() != lower),
    ].take(maxEntries).toList();
    state = next;
    initial = next;
    await _persistSafely(next);
  }

  Future<void> remove(String query) async {
    final lower = query.toLowerCase();
    final next = state.where((e) => e.toLowerCase() != lower).toList();
    state = next;
    initial = next;
    await _persistSafely(next);
  }

  Future<void> clear() async {
    state = const [];
    initial = const [];
    await _persistSafely(state);
  }

  /// Kegagalan persist (binding belum siap di test, storage penuh di
  /// lapangan) tidak boleh mengganggu pencarian - state in-memory tetap
  /// benar, hanya hilang saat app ditutup.
  Future<void> _persistSafely(List<String> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(prefKey, list);
    } catch (_) {
      // ponytail: swallow di sini sengaja - riwayat bukan data penting.
      // Upgrade path: log ke ExceptionLog kalau mau terlihat di DevTool.
    }
  }
}
