import 'package:flutter/material.dart';

import '../../../../shared/widgets/thread_audio_player.dart';

/// Alias player balasan suara Ruang Diskusi (implementasi di shared).
class DiscussionReplyAudioPlayer extends StatelessWidget {
  const DiscussionReplyAudioPlayer({
    super.key,
    required this.url,
    this.durationMs,
  });

  final String url;
  final int? durationMs;

  @override
  Widget build(BuildContext context) {
    return ThreadAudioPlayer(url: url, durationMs: durationMs);
  }
}
