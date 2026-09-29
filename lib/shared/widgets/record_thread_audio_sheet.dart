import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../utils/error_bottom_sheet.dart';
import '../utils/permission_helper.dart';
import '../../features/dictionary/presentation/utils/ensure_microphone_ready.dart';

enum _ThreadRecordPhase {
  idle,
  requestingPermission,
  recording,
  preview,
  submitting,
}

const _maxSeconds = 60;
const _minSeconds = 1;

/// Sheet rekam audio thread (balasan diskusi / komentar / lampiran create).
///
/// Jika [onSubmit] null, tombol akhir menjadi "Pakai rekaman" dan menutup
/// sheet dengan [RecordedThreadAudio] (untuk lampiran lokal sebelum upload).
Future<RecordedThreadAudio?> showRecordThreadAudioSheet(
  BuildContext context, {
  String title = 'Rekam suara',
  String subtitle =
      'Maksimal 60 detik. Caption teks bisa ditambahkan di kolom sebelum merekam.',
  String submitLabel = 'Kirim rekaman',
  Future<String?> Function({
    required File audioFile,
    required int durationMs,
  })? onSubmit,
}) async {
  final ready = await ensureMicrophoneReady(context);
  if (!ready || !context.mounted) return null;

  return showModalBottomSheet<RecordedThreadAudio>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    builder: (ctx) => _RecordThreadAudioSheet(
      title: title,
      subtitle: subtitle,
      submitLabel: submitLabel,
      onSubmit: onSubmit,
    ),
  );
}

/// Hasil rekaman lokal (belum diunggah).
class RecordedThreadAudio {
  const RecordedThreadAudio({
    required this.file,
    required this.durationMs,
  });

  final File file;
  final int durationMs;
}

class _RecordThreadAudioSheet extends StatefulWidget {
  const _RecordThreadAudioSheet({
    required this.title,
    required this.subtitle,
    required this.submitLabel,
    this.onSubmit,
  });

  final String title;
  final String subtitle;
  final String submitLabel;
  final Future<String?> Function({
    required File audioFile,
    required int durationMs,
  })? onSubmit;

  @override
  State<_RecordThreadAudioSheet> createState() => _RecordThreadAudioSheetState();
}

class _RecordThreadAudioSheetState extends State<_RecordThreadAudioSheet>
    with WidgetsBindingObserver {
  final _recorder = AudioRecorder();
  final _previewPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _previewSub;
  Timer? _tick;
  _ThreadRecordPhase _phase = _ThreadRecordPhase.idle;
  String? _filePath;
  int _elapsedSec = 0;
  bool _previewPlaying = false;
  bool _stoppingForLifecycle = false;
  String? _error;

  bool get _blockDismiss =>
      _phase == _ThreadRecordPhase.requestingPermission ||
      _phase == _ThreadRecordPhase.recording ||
      _phase == _ThreadRecordPhase.submitting;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_previewPlayer.setLoopMode(LoopMode.off));
    _previewSub = _previewPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing =
          state.playing && state.processingState != ProcessingState.completed;
      if (playing != _previewPlaying) {
        setState(() => _previewPlaying = playing);
      }
      if (state.processingState == ProcessingState.completed) {
        unawaited(_previewPlayer.seek(Duration.zero));
        unawaited(_previewPlayer.pause());
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_phase == _ThreadRecordPhase.recording && !_stoppingForLifecycle) {
        _stoppingForLifecycle = true;
        unawaited(_stopRecording());
      }
      unawaited(_stopPreview());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    unawaited(_recorder.dispose());
    unawaited(_disposePreview());
    super.dispose();
  }

  Future<void> _stopPreview() async {
    try {
      await _previewPlayer.stop();
    } catch (_) {}
    if (mounted && _previewPlaying) {
      setState(() => _previewPlaying = false);
    }
  }

  Future<void> _disposePreview() async {
    try {
      await _previewSub?.cancel();
    } catch (_) {}
    try {
      await _previewPlayer.dispose();
    } catch (_) {}
    // Jangan hapus file jika sudah dikembalikan ke caller (local attach).
  }

  Future<void> _deleteQuietly(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  Future<void> _startRecording() async {
    setState(() {
      _error = null;
      _phase = _ThreadRecordPhase.requestingPermission;
    });

    final status = await Permission.microphone.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() => _phase = _ThreadRecordPhase.idle);
      if (status.isPermanentlyDenied && mounted) {
        showMicrophonePermissionDeniedDialog(context);
      } else if (mounted) {
        showFToast(
          context: context,
          title: const Text('Izin mikrofon diperlukan untuk merekam'),
        );
      }
      return;
    }

    final hasPerm = await _recorder.hasPermission();
    if (!mounted) return;
    if (!hasPerm) {
      setState(() {
        _phase = _ThreadRecordPhase.idle;
        _error = 'Mikrofon tidak tersedia';
      });
      return;
    }

    await _stopPreview();
    await _deleteQuietly(_filePath);
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/thread_audio_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav),
      path: path,
    );
    if (!mounted) return;

    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _phase = _ThreadRecordPhase.recording;
      _filePath = path;
      _elapsedSec = 0;
      _stoppingForLifecycle = false;
    });

    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      final next = _elapsedSec + 1;
      setState(() => _elapsedSec = next);
      if (next >= _maxSeconds) {
        t.cancel();
        await _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    _tick?.cancel();
    _tick = null;
    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {}
    if (!mounted) return;

    final resolved = path ?? _filePath;
    if (resolved == null || _elapsedSec < _minSeconds) {
      await _deleteQuietly(resolved);
      setState(() {
        _phase = _ThreadRecordPhase.idle;
        _filePath = null;
        _elapsedSec = 0;
        _error = _elapsedSec < _minSeconds
            ? 'Rekaman terlalu singkat'
            : 'Gagal menyimpan rekaman';
      });
      return;
    }

    setState(() {
      _phase = _ThreadRecordPhase.preview;
      _filePath = resolved;
    });
  }

  Future<void> _togglePreview() async {
    final path = _filePath;
    if (path == null) return;
    try {
      if (_previewPlayer.playing) {
        await _previewPlayer.pause();
        return;
      }
      if (_previewPlayer.audioSource == null) {
        await _previewPlayer.setFilePath(path);
      }
      await _previewPlayer.play();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Gagal memutar pratinjau');
      }
    }
  }

  Future<void> _reset() async {
    await _stopPreview();
    await _deleteQuietly(_filePath);
    if (!mounted) return;
    setState(() {
      _phase = _ThreadRecordPhase.idle;
      _filePath = null;
      _elapsedSec = 0;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final path = _filePath;
    if (path == null || _phase == _ThreadRecordPhase.submitting) return;
    final durationMs = (_elapsedSec * 1000).clamp(1000, _maxSeconds * 1000);
    final file = File(path);

    final upload = widget.onSubmit;
    if (upload == null) {
      Navigator.of(context).pop(
        RecordedThreadAudio(file: file, durationMs: durationMs),
      );
      return;
    }

    setState(() {
      _phase = _ThreadRecordPhase.submitting;
      _error = null;
    });
    await _stopPreview();

    final failure = await upload(
      audioFile: file,
      durationMs: durationMs,
    );
    if (!mounted) return;
    if (failure == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _phase = _ThreadRecordPhase.preview;
      _error = failure;
    });
    await showAppErrorSheet(context, message: failure);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final localAttach = widget.onSubmit == null;

    return PopScope(
      canPop: !_blockDismiss,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _blockDismiss
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            Text(
              widget.subtitle,
              style: theme.typography.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            const Gap(16),
            if (_error != null) ...[
              FAlert(
                variant: FAlertVariant.destructive,
                title: Text(_error!),
              ),
              const Gap(12),
            ],
            if (_phase == _ThreadRecordPhase.recording) ...[
              Text(
                'Merekam… ${_elapsedSec}s / ${_maxSeconds}s',
                textAlign: TextAlign.center,
                style: theme.typography.sm.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(12),
              FButton(
                onPress: _stopRecording,
                child: const Text('Selesai rekam'),
              ),
            ] else if (_phase == _ThreadRecordPhase.preview ||
                _phase == _ThreadRecordPhase.submitting) ...[
              Text(
                'Durasi ${_elapsedSec}s',
                textAlign: TextAlign.center,
                style: theme.typography.sm,
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: _phase == _ThreadRecordPhase.submitting
                          ? null
                          : _togglePreview,
                      child: Text(_previewPlaying ? 'Jeda' : 'Pratinjau'),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: FButton(
                      variant: FButtonVariant.outline,
                      onPress: _phase == _ThreadRecordPhase.submitting
                          ? null
                          : _reset,
                      child: const Text('Ulangi'),
                    ),
                  ),
                ],
              ),
              const Gap(8),
              FButton(
                onPress:
                    _phase == _ThreadRecordPhase.submitting ? null : _submit,
                child: Text(
                  _phase == _ThreadRecordPhase.submitting
                      ? 'Mengirim…'
                      : localAttach
                          ? 'Pakai rekaman'
                          : widget.submitLabel,
                ),
              ),
            ] else ...[
              FButton(
                onPress: _startRecording,
                prefix: const Icon(FLucideIcons.mic, size: 16),
                child: const Text('Mulai rekam'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
