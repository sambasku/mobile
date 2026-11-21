import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Bel singkat saat ping masuk (in-app).
abstract final class ChatPingSfx {
  static AudioPlayer? _player;
  static Future<void>? _chain;

  static Future<void> play() {
    const asset = 'assets/sounds/chat_ping.wav';
    final next = () async {
      await _chain;
      try {
        final player = _player ??= AudioPlayer();
        await player.stop();
        await player.setAudioSource(AudioSource.asset(asset));
        await player.seek(Duration.zero);
        unawaited(player.play());
      } catch (e, st) {
        debugPrint('ChatPingSfx failed: $e\n$st');
      }
    }();
    _chain = next;
    return next;
  }
}
