import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// SFX singkat voice room (join/leave). Satu player, fire-and-forget.
abstract final class VoiceRoomSfx {
  static AudioPlayer? _player;
  static Future<void>? _chain;

  static Future<void> joinSelf() => _play('assets/sounds/voice_join_self.wav');

  static Future<void> leaveSelf() =>
      _play('assets/sounds/voice_leave_self.wav');

  static Future<void> joinOther() =>
      _play('assets/sounds/voice_join_other.wav');

  static Future<void> _play(String asset) {
    // Seri: stop + ganti asset supaya join orang lain tidak hilang bentrok.
    final next = () async {
      await _chain;
      try {
        final player = _player ??= AudioPlayer();
        await player.stop();
        await player.setAudioSource(AudioSource.asset(asset));
        await player.seek(Duration.zero);
        unawaited(player.play());
      } catch (e, st) {
        debugPrint('VoiceRoomSfx failed ($asset): $e\n$st');
      }
    }();
    _chain = next;
    return next;
  }
}
