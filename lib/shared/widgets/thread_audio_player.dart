import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:just_audio/just_audio.dart';

/// Player ringkas untuk audio di thread (balasan diskusi / komentar kata).
class ThreadAudioPlayer extends StatefulWidget {
  const ThreadAudioPlayer({
    super.key,
    required this.url,
    this.durationMs,
  });

  final String url;
  final int? durationMs;

  @override
  State<ThreadAudioPlayer> createState() => _ThreadAudioPlayerState();
}

class _ThreadAudioPlayerState extends State<ThreadAudioPlayer> {
  final _player = AudioPlayer();
  StreamSubscription<PlayerState>? _sub;
  var _loading = false;
  var _playing = false;
  var _error = false;

  String get _durationLabel {
    final ms = widget.durationMs;
    if (ms == null || ms <= 0) return 'Suara';
    final sec = (ms / 1000).round().clamp(1, 9999);
    if (sec < 60) return '${sec}s';
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _sub = _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _playing = state.playing;
        if (state.processingState == ProcessingState.completed) {
          _playing = false;
          unawaited(_player.seek(Duration.zero));
          unawaited(_player.pause());
        }
      });
    });
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel() ?? Future<void>.value());
    unawaited(() async {
      try {
        await _player.stop();
      } catch (_) {}
      try {
        await _player.dispose();
      } catch (_) {}
    }());
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_loading) return;
    final reload = _error || _player.audioSource == null;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        if (reload) {
          await _player.stop();
          await _player.setUrl(widget.url);
        }
        await _player.play();
      }
    } catch (_) {
      if (mounted) setState(() => _error = true);
      try {
        await _player.stop();
      } catch (_) {}
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final icon = _error
        ? FLucideIcons.circleAlert
        : _loading
            ? FLucideIcons.loader
            : _playing
                ? FLucideIcons.pause
                : FLucideIcons.play;
    final color = _error ? theme.colors.error : theme.colors.primary;

    return Semantics(
      button: true,
      label: _error
          ? 'Gagal memutar rekaman, ketuk untuk coba lagi'
          : _playing
              ? 'Jeda rekaman'
              : 'Putar rekaman',
      child: Material(
        color: theme.colors.secondary.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const Gap(8),
                Text(
                  _durationLabel,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
