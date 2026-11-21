import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/speaker_status.dart';

/// Pref lokal first-install untuk status penutur/pembelajar (#258).
///
/// Sync ke API saat login (server menang jika sudah terisi).
class SpeakerStatusPrefs {
  SpeakerStatusPrefs._();

  static const prefKey = 'sambasku_speaker_status';

  /// Cache memori; null = belum diisi.
  static SpeakerStatus? value;

  static Future<void> preload([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    value = SpeakerStatus.tryParse(p.getString(prefKey));
  }

  static Future<SpeakerStatus?> read([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    value = SpeakerStatus.tryParse(p.getString(prefKey));
    return value;
  }

  static Future<void> save(
    SpeakerStatus status, [
    SharedPreferences? prefs,
  ]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    await p.setString(prefKey, status.wire);
    value = status;
  }

  /// Mirror dari server (server menang).
  static Future<void> mirrorFromServer(
    SpeakerStatus? status, [
    SharedPreferences? prefs,
  ]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    if (status == null) {
      await p.remove(prefKey);
      value = null;
      return;
    }
    await p.setString(prefKey, status.wire);
    value = status;
  }
}
