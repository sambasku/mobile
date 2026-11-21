import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kVoiceRoomOptIn = 'voice_room_opt_in';

/// Opt-in lokal (SharedPreferences). Default false.
final voiceRoomOptInProvider =
    NotifierProvider<VoiceRoomOptInController, bool>(
      VoiceRoomOptInController.new,
    );

class VoiceRoomOptInController extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!ref.mounted) return;
    state = prefs.getBool(_kVoiceRoomOptIn) ?? false;
  }

  Future<void> setOptIn(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kVoiceRoomOptIn, value);
  }
}
