import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Prompt rating bawaan OS (Play Store / App Store) di momen sukses user.
///
/// Aturan nanya: sukses ke-3, lalu tiap +10; cooldown 30 hari; hanya di
/// build release (dialog OS memang tidak jalan di debug). Fire-and-forget
/// dari titik sukses - gagal prompt tidak pernah mengganggu flow utama.
abstract final class InAppReviewService {
  static const _prefKey = 'review_prompt_state';
  static const _firstPromptAt = 3;
  static const _repeatEvery = 10;
  static const _cooldown = Duration(days: 30);

  static Future<void> maybePrompt() async {
    if (!kReleaseMode) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      final state = raw == null ? null : _decode(raw);
      final count = (state?.$1 ?? 0) + 1;
      final lastPrompt = state?.$2;

      final due = count == _firstPromptAt ||
          (count > _firstPromptAt && (count - _firstPromptAt) % _repeatEvery == 0);
      final cooledDown =
          lastPrompt == null ||
          DateTime.now().difference(lastPrompt) >= _cooldown;

      await prefs.setString(_prefKey, '$count');

      if (!due || !cooledDown) return;
      final availability = await InAppReview.instance.isAvailable();
      if (!availability) return;
      await InAppReview.instance.requestReview();
      await prefs.setString(
        _prefKey,
        '$count|${DateTime.now().millisecondsSinceEpoch}',
      );
    } catch (_) {
      // ponytail: prompt rating boleh gagal diam - bukan jalur kritis.
      // Upgrade path: log ke ExceptionLog kalau mau audit di DevTool.
    }
  }

  /// Format tersimpan: "count" atau "count|lastPromptMs".
  static (int, DateTime?)? _decode(String raw) {
    final parts = raw.split('|');
    final count = int.tryParse(parts[0]);
    if (count == null) return null;
    final ms = parts.length > 1 ? int.tryParse(parts[1]) : null;
    return (count, ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms));
  }

  // Ekspos untuk test (guard kReleaseMode memblok jalur asli di debug).
  static (int, DateTime?)? decodeForTest(String raw) => _decode(raw);
  static int get firstPromptAtForTest => _firstPromptAt;
  static int get repeatEveryForTest => _repeatEvery;
  static Duration? get cooldownForTest => _cooldown;
}
