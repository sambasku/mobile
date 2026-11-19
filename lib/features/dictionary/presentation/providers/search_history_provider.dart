import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_history_provider.g.dart';

/// Riwayat pencarian kata: maksimal 10 query terakhir, **hanya di memori
/// sesi** (issue mobile#296 - jangan simpan SharedPreferences / cache
/// disk). Dedup case-insensitive; query sama digeser ke atas.
///
/// [preload] membersihkan sisa key lama dari versi sebelumnya supaya
/// field/riwayat tidak "nyangkut" setelah update.
@Riverpod(keepAlive: true)
class SearchHistoryController extends _$SearchHistoryController {
  static const prefKey = 'search_history_v1';
  static const maxEntries = 10;

  static List<String> initial = const [];

  /// Hapus key disk lama; state mulai kosong tiap cold start.
  static Future<void> preload([SharedPreferences? prefs]) async {
    initial = const [];
    try {
      final p = prefs ?? await SharedPreferences.getInstance();
      await p.remove(prefKey);
    } catch (_) {
      // ponytail: gagal hapus prefs tidak boleh gagalkan boot.
    }
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
  }

  Future<void> remove(String query) async {
    final lower = query.toLowerCase();
    final next = state.where((e) => e.toLowerCase() != lower).toList();
    state = next;
    initial = next;
  }

  Future<void> clear() async {
    state = const [];
    initial = const [];
  }
}
