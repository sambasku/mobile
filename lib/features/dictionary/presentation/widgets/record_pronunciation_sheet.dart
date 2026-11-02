import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/permission_helper.dart';
import '../../../contribution/presentation/utils/invalidate_word_detail.dart';
import '../../application/wav_trim.dart';
import '../providers/audio_player_controller.dart';
import '../providers/pronunciation_providers.dart';
import '../providers/word_detail_providers.dart';

enum _RecordPhase { idle, requestingPermission, recording, trim, submitting }

/// Durasi potongan minimum (detik) - hindari cuplikan hampir kosong.
const _minSelectionSec = 0.3;

/// Di bawah ini: soft warning "terlalu singkat".
const _minComfortSec = 0.45;

/// Peak meter normalisasi di bawah ini: soft warning "terlalu pelan".
const _quietPeakThreshold = 0.15;

/// Sheet rekam: izin → rekam → potong manual (opsional) → pratinjau (opsional)
/// → kirim → consent publikasi → upload.
/// Consent tidak lagi langkah terpisah: muncul saat menekan "Kirim".
/// Pratinjau yang sudah pernah diputar tidak wajib diulang.
/// Nama penutur: default mencantumkan nama saat login, bisa dimatikan (anonim).
/// Selesai dengan `true` bila rekaman terkirim.
Future<bool?> showRecordPronunciationSheet(
  BuildContext context, {
  required WidgetRef ref,
  required String wordId,
  required String languageId,
  String? exampleId,
  String? spokenText,
  String defaultSpeakerName = '',
}) {
  // Hentikan audio di halaman detail sebelum sheet membuka player sendiri.
  try {
    ref.read(wordDetailAudioPlayerProvider(wordId).notifier).stop();
  } catch (_) {}

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Dismiss dikontrol PopScope di dalam sheet saat merekam/mengirim.
    isDismissible: true,
    enableDrag: true,
    builder: (ctx) => _RecordPronunciationSheet(
      wordId: wordId,
      languageId: languageId,
      exampleId: exampleId,
      spokenText: spokenText,
      defaultSpeakerName: defaultSpeakerName,
    ),
  );
}

class _RecordPronunciationSheet extends ConsumerStatefulWidget {
  const _RecordPronunciationSheet({
    required this.wordId,
    required this.languageId,
    this.exampleId,
    this.spokenText,
    this.defaultSpeakerName = '',
  });

  final String wordId;
  final String languageId;
  final String? exampleId;
  final String? spokenText;
  final String defaultSpeakerName;

  @override
  ConsumerState<_RecordPronunciationSheet> createState() =>
      _RecordPronunciationSheetState();
}

class _RecordPronunciationSheetState
    extends ConsumerState<_RecordPronunciationSheet>
    with WidgetsBindingObserver {
  /// Lemma singkat; contoh kalimat boleh lebih panjang.
  int get _maxSeconds => widget.exampleId == null ? 15 : 30;

  final _recorder = AudioRecorder();

  /// Player khusus pratinjau - jangan pakai [wordDetailAudioPlayerProvider]
  /// supaya dispose sheet (hapus file temp) tidak merusak player detail.
  final _previewPlayer = AudioPlayer();
  StreamSubscription<PlayerState>? _previewSub;
  StreamSubscription<Amplitude>? _ampSub;
  String? _dialectId;
  _RecordPhase _phase = _RecordPhase.idle;
  String? _filePath;
  int _elapsedSec = 0;
  double _totalSec = 0;
  RangeValues _range = const RangeValues(0, 1);
  List<double> _peaks = const [];
  String? _previewTrimPath;
  double _ampLevel = 0;

  /// Peak tertinggi selama sesi rekam (0…1) - deteksi terlalu pelan.
  double _peakAmpSeen = 0;
  bool _trimBusy = false;
  bool _previewPlaying = false;
  bool _hasPreviewed = false;

  /// Tekan-tahan: lepas = stop. Tap singkat = mode terkunci (ketuk lagi untuk stop).
  bool _holdRecording = false;
  bool _lockedRecording = false;
  bool _releaseWhileStarting = false;
  DateTime? _pressDownAt;
  Timer? _tick;
  String? _error;

  /// Soft warning kualitas (tidak memblokir kirim).
  String? _qualityHint;
  bool _stoppingForLifecycle = false;

  /// Default ON saat login (nama tampilan tersedia); user bisa matikan untuk anonim.
  bool _creditSpeakerName = false;

  /// PDP Pasal 8: setuju publikasi; diminta lewat sheet saat menekan "Kirim"
  /// (sekali per sesi sheet).
  bool _speakerConsent = false;

  String get _accountSpeakerName => widget.defaultSpeakerName.trim();
  String? get _speakerNameForUpload =>
      _creditSpeakerName && _accountSpeakerName.isNotEmpty
      ? _accountSpeakerName
      : null;
  String get _spoken => widget.spokenText?.trim() ?? '';

  bool get _blockDismiss =>
      _phase == _RecordPhase.requestingPermission ||
      _phase == _RecordPhase.recording ||
      _phase == _RecordPhase.submitting;

  bool get _showSpeakerMeta =>
      _phase != _RecordPhase.recording &&
      _phase != _RecordPhase.requestingPermission;

  @override
  void initState() {
    super.initState();
    _creditSpeakerName = _accountSpeakerName.isNotEmpty;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_previewPlayer.setLoopMode(LoopMode.off));
    _previewSub = _previewPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      final playing =
          state.playing && state.processingState != ProcessingState.completed;
      if (playing == _previewPlaying) {
        if (state.processingState == ProcessingState.completed) {
          unawaited(_previewPlayer.seek(Duration.zero));
          unawaited(_previewPlayer.pause());
        }
        return;
      }
      setState(() => _previewPlaying = playing);
      if (state.processingState == ProcessingState.completed) {
        unawaited(_previewPlayer.seek(Duration.zero));
        unawaited(_previewPlayer.pause());
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dialects =
          ref.read(wordDialectsProvider(widget.languageId)).value ??
          const <DialectOption>[];
      final def = dialects.where((d) => d.isDefault).firstOrNull;
      if (def != null && mounted) {
        setState(() => _dialectId = def.id);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_phase == _RecordPhase.recording && !_stoppingForLifecycle) {
        _stoppingForLifecycle = true;
        unawaited(_stopRecording(fromLifecycle: true));
      }
      unawaited(_stopPreviewPlayer());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    unawaited(_ampSub?.cancel());
    unawaited(_recorder.dispose());
    // Jangan panggil ref di dispose (tidak aman di Riverpod). Player detail
    // sudah di-stop saat sheet dibuka; di sini cukup lepas preview + file.
    unawaited(_disposePreviewResources());
    super.dispose();
  }

  Future<void> _stopPreviewPlayer() async {
    try {
      await _previewPlayer.stop();
    } catch (_) {}
    if (mounted && _previewPlaying) {
      setState(() => _previewPlaying = false);
    } else {
      _previewPlaying = false;
    }
  }

  Future<void> _disposePreviewResources() async {
    try {
      await _previewSub?.cancel();
    } catch (_) {}
    _previewSub = null;
    try {
      await _previewPlayer.stop();
    } catch (_) {}
    try {
      await _previewPlayer.dispose();
    } catch (_) {}
    final paths = <String?>[_filePath, _previewTrimPath];
    _filePath = null;
    _previewTrimPath = null;
    for (final p in paths) {
      await _deleteQuietly(p);
    }
  }

  Future<void> _deleteQuietly(String? path) async {
    if (path == null) return;
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  Future<void> _invalidatePreview() async {
    await _stopPreviewPlayer();
    final preview = _previewTrimPath;
    _previewTrimPath = null;
    _hasPreviewed = false;
    await _deleteQuietly(preview);
  }

  Future<void> _cancelAmplitude() async {
    try {
      await _ampSub?.cancel();
    } catch (_) {}
    _ampSub = null;
    _ampLevel = 0;
  }

  /// dBFS (−∞…0) → 0…1 untuk meter visual.
  double _normAmp(double db) {
    const floor = -45.0;
    if (db.isNaN || db.isInfinite) return 0;
    return ((db - floor) / -floor).clamp(0.0, 1.0);
  }

  Future<void> _startRecording() async {
    setState(() {
      _error = null;
      _phase = _RecordPhase.requestingPermission;
    });

    final status = await Permission.microphone.request();
    if (!mounted) return;
    if (!status.isGranted) {
      setState(() {
        _phase = _RecordPhase.idle;
        _holdRecording = false;
        _lockedRecording = false;
        _releaseWhileStarting = false;
      });
      if (status.isPermanentlyDenied && mounted) {
        showMicrophonePermissionDeniedDialog(context);
      } else if (mounted) {
        showFToast(
          context: context,
          title: Text(AppLocalizations.of(context).dictMicPermissionTitle),
        );
      }
      return;
    }

    final hasPerm = await _recorder.hasPermission();
    if (!mounted) return;
    if (!hasPerm) {
      setState(() {
        _phase = _RecordPhase.idle;
        _holdRecording = false;
        _lockedRecording = false;
        _releaseWhileStarting = false;
        _error = AppLocalizations.of(context).dictRecMicUnavailable;
      });
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/pronunciation_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.wav),
      path: path,
    );

    if (!mounted) return;
    AnalyticsService.instance.log(
      AnalyticsEvents.audioRecordStart,
      params: {'word_id': widget.wordId},
    );

    await _cancelAmplitude();
    _peakAmpSeen = 0;
    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .listen((amp) {
          if (!mounted || _phase != _RecordPhase.recording) return;
          final next = _normAmp(amp.current);
          final smoothed = _ampLevel * 0.35 + next * 0.65;
          if (next > _peakAmpSeen) _peakAmpSeen = next;
          if ((smoothed - _ampLevel).abs() < 0.02 && next <= _peakAmpSeen) {
            return;
          }
          setState(() => _ampLevel = smoothed);
        });

    // Lepas selama meminta izin → lanjut mode terkunci (ketuk untuk stop).
    final lockAfterRelease = _releaseWhileStarting;
    _releaseWhileStarting = false;

    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _phase = _RecordPhase.recording;
      _filePath = path;
      _elapsedSec = 0;
      _totalSec = 0;
      _range = const RangeValues(0, 1);
      _peaks = const [];
      _hasPreviewed = false;
      _ampLevel = 0;
      _qualityHint = null;
      _stoppingForLifecycle = false;
      if (lockAfterRelease) {
        _holdRecording = false;
        _lockedRecording = true;
      }
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
        await _stopRecording();
      }
    });
  }

  /// Tekan tombol rekam (mulai) atau ketuk stop saat mode terkunci.
  Future<void> _onRecordPressDown() async {
    if (_phase == _RecordPhase.recording && _lockedRecording) {
      await _stopRecording();
      return;
    }
    if (_phase != _RecordPhase.idle) return;
    _pressDownAt = DateTime.now();
    _releaseWhileStarting = false;
    setState(() {
      _holdRecording = true;
      _lockedRecording = false;
    });
    await _startRecording();
  }

  /// Lepas: tahan lama → stop; tap singkat → kunci sampai ketuk stop.
  Future<void> _onRecordPressUp() async {
    if (_phase == _RecordPhase.requestingPermission ||
        (_holdRecording && _phase == _RecordPhase.idle)) {
      _releaseWhileStarting = true;
      return;
    }
    if (_phase != _RecordPhase.recording || !_holdRecording) return;

    final held = DateTime.now().difference(_pressDownAt ?? DateTime.now());
    // Tap singkat (<280ms): kunci rekaman, perlu ketuk lagi untuk stop.
    if (held < const Duration(milliseconds: 280)) {
      if (!mounted) return;
      unawaited(HapticFeedback.selectionClick());
      setState(() {
        _holdRecording = false;
        _lockedRecording = true;
      });
      return;
    }
    _holdRecording = false;
    await _stopRecording();
  }

  Future<void> _onRecordPressCancel() async {
    if (_phase == _RecordPhase.requestingPermission) {
      _releaseWhileStarting = true;
      return;
    }
    if (_phase == _RecordPhase.recording && _holdRecording) {
      _holdRecording = false;
      await _stopRecording();
    }
  }

  Future<void> _stopRecording({bool fromLifecycle = false}) async {
    _tick?.cancel();
    await _cancelAmplitude();
    _holdRecording = false;
    _lockedRecording = false;
    _releaseWhileStarting = false;
    final path = await _recorder.stop();
    if (!mounted) return;
    final filePath = path ?? _filePath;
    if (filePath == null) {
      setState(() {
        _phase = _RecordPhase.idle;
        _error = AppLocalizations.of(context).dictRecSaveFailed;
        _stoppingForLifecycle = false;
      });
      return;
    }

    unawaited(HapticFeedback.mediumImpact());
    setState(() {
      _filePath = filePath;
      _phase = _RecordPhase.trim;
      _trimBusy = true;
      _qualityHint = null;
      _error = fromLifecycle
          ? AppLocalizations.of(context).dictRecStoppedInactive
          : null;
      _stoppingForLifecycle = false;
    });

    try {
      final file = File(filePath);
      final total = await wavDurationSeconds(file);
      final peaks = await computeWavPeaks(file);
      if (!mounted) return;
      final totalSec = total <= 0
          ? (_elapsedSec.clamp(1, _maxSeconds)).toDouble()
          : total;
      final wavPeak = peaks.isEmpty ? 0.0 : peaks.reduce(math.max);
      final qualityHint = _buildQualityHint(
        totalSec: totalSec,
        peakAmp: math.max(_peakAmpSeen, wavPeak),
      );
      // Rentang awal = seluruh rekaman. Potong diam hanya lewat slider manual.
      setState(() {
        _totalSec = totalSec;
        _range = RangeValues(0, _totalSec);
        _peaks = peaks;
        _trimBusy = false;
        _qualityHint = qualityHint;
      });
      // Auto-pratinjau supaya langkah "dengar dulu" terasa alami.
      if (!fromLifecycle) {
        unawaited(_togglePreview());
      }
    } catch (_) {
      if (!mounted) return;
      final total = _elapsedSec.clamp(1, _maxSeconds).toDouble();
      setState(() {
        _totalSec = total;
        _range = RangeValues(0, total);
        _peaks = const [];
        _trimBusy = false;
        _qualityHint = _buildQualityHint(
          totalSec: total,
          peakAmp: _peakAmpSeen,
        );
      });
      if (!fromLifecycle) {
        unawaited(_togglePreview());
      }
    }
  }

  String? _buildQualityHint({
    required double totalSec,
    required double peakAmp,
  }) {
    if (totalSec < _minComfortSec) {
      return AppLocalizations.of(context).dictRecTooShort;
    }
    if (peakAmp < _quietPeakThreshold) {
      return AppLocalizations.of(context).dictRecTooQuiet;
    }
    return null;
  }

  Future<void> _discardAndRerecord() async {
    await _invalidatePreview();
    final path = _filePath;
    _filePath = null;
    await _deleteQuietly(path);
    if (!mounted) return;
    setState(() {
      _elapsedSec = 0;
      _totalSec = 0;
      _range = const RangeValues(0, 1);
      _peaks = const [];
      _ampLevel = 0;
      _peakAmpSeen = 0;
      _holdRecording = false;
      _lockedRecording = false;
      _releaseWhileStarting = false;
      _qualityHint = null;
      _phase = _RecordPhase.idle;
      _error = null;
    });
  }

  void _onRangeChanged(RangeValues v) {
    if (v.end - v.start < _minSelectionSec) return;
    unawaited(_invalidatePreview());
    setState(() => _range = v);
  }

  /// Preview = file hasil trim (bukan ClippingAudioSource) agar tidak loop.
  Future<void> _togglePreview() async {
    final path = _filePath;
    if (path == null || _trimBusy) return;
    if (_range.end - _range.start < _minSelectionSec) {
      setState(
        () => _error = AppLocalizations.of(
          context,
        ).dictRecClipTooShort(_minSelectionSec.toStringAsFixed(1)),
      );
      return;
    }

    if (_previewPlaying) {
      await _stopPreviewPlayer();
      return;
    }

    setState(() {
      _trimBusy = true;
      _error = null;
    });
    try {
      String playPath = _previewTrimPath ?? '';
      if (playPath.isEmpty || !await File(playPath).exists()) {
        final trimmed = await trimWavFile(
          File(path),
          startSec: _range.start,
          endSec: _range.end,
        );
        if (!mounted) return;
        final oldPreview = _previewTrimPath;
        _previewTrimPath = trimmed.file.path;
        playPath = trimmed.file.path;
        if (oldPreview != null && oldPreview != playPath) {
          unawaited(_deleteQuietly(oldPreview));
        }
      }

      await _previewPlayer.stop();
      await _previewPlayer.setLoopMode(LoopMode.off);
      await _previewPlayer.setFilePath(playPath);
      await _previewPlayer.play();
      if (!mounted) return;
      setState(() {
        _previewPlaying = true;
        _hasPreviewed = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _previewPlaying = false;
        _error = AppLocalizations.of(context).dictRecPreviewFailed;
      });
    } finally {
      if (mounted) setState(() => _trimBusy = false);
    }
  }

  /// Sheet persetujuan publikasi + lisensi (PDP Pasal 8). Hasil true = setuju.
  Future<bool> _showConsentSheet() async {
    final theme = FTheme.of(context);
    final agreed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(sheetCtx).dictRecLicenseTitle,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(12),
            Text(
              AppLocalizations.of(sheetCtx).dictRecLicenseBody,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.5,
              ),
            ),
            const Gap(24),
            FButton(
              onPress: () => Navigator.of(sheetCtx).pop(true),
              child: Text(AppLocalizations.of(sheetCtx).dictRecAgree),
            ),
            const Gap(8),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => Navigator.of(sheetCtx).pop(false),
              child: Text(AppLocalizations.of(sheetCtx).commonCancel),
            ),
          ],
        ),
      ),
    );
    if (agreed == true && mounted) {
      setState(() {
        _speakerConsent = true;
        _error = null;
      });
    }
    return agreed == true;
  }

  Future<void> _submit() async {
    final path = _filePath;
    if (path == null) {
      setState(() => _error = AppLocalizations.of(context).dictRecNoRecording);
      return;
    }
    if (_creditSpeakerName && _accountSpeakerName.isEmpty) {
      setState(
        () => _error = AppLocalizations.of(context).dictRecNoDisplayName,
      );
      return;
    }
    if (_range.end - _range.start < _minSelectionSec) {
      setState(
        () => _error = AppLocalizations.of(
          context,
        ).dictRecClipTooShort(_minSelectionSec.toStringAsFixed(1)),
      );
      return;
    }
    // Consent = bagian dari aksi kirim (sekali per sesi sheet), bukan chip
    // terpisah. Hentikan preview dulu supaya suara tidak menumpuk saat sheet
    // consent terbuka.
    await _stopPreviewPlayer();
    if (!_speakerConsent) {
      final agreed = await _showConsentSheet();
      if (!mounted) return;
      if (agreed != true) {
        // Batal: kembali ke editor apa adanya. Lanjutkan pratinjau yang tadi
        // berhenti - user tidak perlu menekan putar ulang.
        if (_hasPreviewed) unawaited(_togglePreview());
        return;
      }
    }
    setState(() {
      _phase = _RecordPhase.submitting;
      _error = null;
      _trimBusy = true;
    });
    // Hentikan preview; cache trim dipertahankan supaya kalau upload gagal,
    // pratinjau tinggal lanjut tanpa memotong ulang.
    await _stopPreviewPlayer();
    late final File uploadFile;
    late final int durationMs;
    try {
      final trimmed = await trimWavFile(
        File(path),
        startSec: _range.start,
        endSec: _range.end,
      );
      uploadFile = trimmed.file;
      durationMs = trimmed.durationMs;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _RecordPhase.trim;
        _trimBusy = false;
        _error = AppLocalizations.of(context).dictRecTrimFailed;
      });
      return;
    }

    final result = await ref
        .read(pronunciationAudioUploadServiceProvider)
        .upload(
          wordId: widget.wordId,
          audioFile: uploadFile,
          speakerName: _speakerNameForUpload,
          speakerConsent: _speakerConsent,
          durationMs: durationMs > 0 ? durationMs : 1000,
          dialectId: _dialectId,
          exampleId: widget.exampleId,
        );

    if (uploadFile.path != path) {
      unawaited(_deleteQuietly(uploadFile.path));
    }

    if (!mounted) return;

    await result.match(
      (failure) async {
        if (failure.isUploadUnavailable) {
          ref
              .read(
                pronunciationUploadUnavailableProvider(widget.wordId).notifier,
              )
              .markUnavailable();
          final shown = ref
              .read(
                pronunciationUploadToastShownProvider(widget.wordId).notifier,
              )
              .markShown();
          if (shown && mounted) {
            showFToast(
              context: context,
              title: Text(failure.message),
              variant: FToastVariant.destructive,
            );
          }
          if (mounted) Navigator.of(context).pop();
          return;
        }
        setState(() {
          _phase = _RecordPhase.trim;
          _trimBusy = false;
          _error = failure.isRateLimited
              ? AppLocalizations.of(context).dictRecTooMany
              : failure.message;
        });
      },
      (_) async {
        // Issue #159: flush L1 + Riverpod, bukan invalidate polos.
        await invalidateWordDetailCaches(
          ref,
          widget.wordId,
          ref.read(wordDetailProvider(widget.wordId)).value?.lemma ?? '',
        );
        if (!mounted) return;
        AnalyticsService.instance.log(
          AnalyticsEvents.audioRecordSubmit,
          params: {'word_id': widget.wordId},
        );
        showFToast(
          context: context,
          title: Text(AppLocalizations.of(context).dictRecThanks),
        );
        Navigator.of(context).pop(true);
      },
    );
  }

  Widget _dialectChips(
    FThemeData theme,
    AsyncValue<List<DialectOption>> async,
  ) {
    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        final locked =
            _phase == _RecordPhase.recording ||
            _phase == _RecordPhase.submitting;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).dictRecDialectOptional,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final d in items)
                  GestureDetector(
                    onTap: locked
                        ? null
                        : () => setState(() {
                            _dialectId = _dialectId == d.id ? null : d.id;
                          }),
                    child: Opacity(
                      opacity: locked ? 0.7 : 1,
                      child: FBadge(
                        variant: _dialectId == d.id
                            ? FBadgeVariant.primary
                            : FBadgeVariant.secondary,
                        child: Text(d.name),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _fmt(double sec) {
    final s = sec.floor().clamp(0, 9999);
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dialectsAsync = ref.watch(wordDialectsProvider(widget.languageId));
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final isExample = widget.exampleId != null;
    final selectionSec = (_range.end - _range.start).clamp(0.0, _totalSec);
    final l10n = AppLocalizations.of(context);
    final hintMax = isExample
        ? l10n.dictRecMaxSecondsHint(_maxSeconds)
        : l10n.dictRecMaxSecondsHintSpeak(_maxSeconds);

    return PopScope(
      canPop: !_blockDismiss,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !_blockDismiss) return;
        showFToast(
          context: context,
          title: Text(
            _phase == _RecordPhase.submitting
                ? l10n.dictRecWaitUpload
                : l10n.dictRecFinishOrCancel,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isExample
                    ? l10n.dictRecordExampleAudio
                    : l10n.dictRecordPronunciation,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              Text(
                hintMax,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              if (_spoken.isNotEmpty) ...[
                const Gap(14),
                Text(
                  l10n.dictRecSay,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(4),
                Text(
                  _spoken,
                  textAlign: TextAlign.center,
                  style: theme.typography.body.xl.copyWith(
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                    height: 1.25,
                  ),
                ),
              ],
              if (_showSpeakerMeta) ...[
                const Gap(14),
                Row(
                  children: [
                    Expanded(child: Text(l10n.dictRecIncludeName)),
                    FSwitch(
                      semanticsLabel: l10n.dictRecIncludeName,
                      value: _creditSpeakerName,
                      enabled: _phase != _RecordPhase.submitting,
                      onChange: (value) =>
                          setState(() => _creditSpeakerName = value),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  _creditSpeakerName
                      ? (_accountSpeakerName.isEmpty
                            ? l10n.dictRecNoDisplayNameShort
                            : _accountSpeakerName)
                      : l10n.dictRecAnonymous,
                  style: theme.typography.body.md.copyWith(
                    color: _creditSpeakerName && _accountSpeakerName.isNotEmpty
                        ? null
                        : theme.colors.mutedForeground,
                  ),
                ),
                if (_creditSpeakerName) ...[
                  const Gap(2),
                  Text(
                    l10n.dictRecFollowProfileName,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
                const Gap(12),
                _dialectChips(theme, dialectsAsync),
              ],
              if (_phase == _RecordPhase.idle) ...[
                const Gap(12),
                Text(
                  l10n.dictRecHoldHint,
                  textAlign: TextAlign.center,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ],
              const Gap(12),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.error,
                  ),
                ),
                const Gap(8),
              ],
              if (_qualityHint != null &&
                  (_phase == _RecordPhase.trim ||
                      _phase == _RecordPhase.submitting)) ...[
                Text(
                  _qualityHint!,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.primary,
                  ),
                ),
                const Gap(8),
              ],
              if (_phase == _RecordPhase.idle ||
                  _phase == _RecordPhase.requestingPermission ||
                  _phase == _RecordPhase.recording) ...[
                if (_phase == _RecordPhase.recording) ...[
                  Text(
                    l10n.dictRecRecording(_elapsedSec, _maxSeconds),
                    textAlign: TextAlign.center,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _ampLevel.clamp(0.05, 1.0),
                      minHeight: 10,
                      backgroundColor: theme.colors.secondary,
                      color: theme.colors.error,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    _holdRecording
                        ? l10n.dictRecReleaseToStop
                        : l10n.dictRecMicLevel,
                    textAlign: TextAlign.center,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const Gap(16),
                ],
                // Satu widget stabil agar pointer up tetap diterima setelah start.
                _RecordRoundButton(
                  busy: _phase == _RecordPhase.requestingPermission,
                  recording: _phase == _RecordPhase.recording,
                  onPressDown: _onRecordPressDown,
                  onPressUp: _onRecordPressUp,
                  onPressCancel: _onRecordPressCancel,
                  label: switch (_phase) {
                    _RecordPhase.requestingPermission => AppLocalizations.of(
                      context,
                    ).dictMicRequesting,
                    _RecordPhase.recording when _holdRecording =>
                      l10n.dictRecReleaseToStop,
                    _RecordPhase.recording => l10n.dictRecStop,
                    _ => l10n.dictRecStart,
                  },
                ),
              ],
              if (_phase == _RecordPhase.trim ||
                  _phase == _RecordPhase.submitting) ...[
                Text(
                  l10n.dictRecTrim,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  _trimBusy
                      ? l10n.dictRecPreparingEditor
                      : '${l10n.dictRecTrimRange(_fmt(selectionSec), _fmt(_totalSec))} '
                            '${l10n.dictRecTrimSelectionLabel}',
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                if (!_trimBusy && _totalSec > 0) ...[
                  const Gap(8),
                  SizedBox(
                    height: 64,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _WavformPainter(
                        peaks: _peaks,
                        selectionStart: (_range.start / _totalSec).clamp(
                          0.0,
                          1.0,
                        ),
                        selectionEnd: (_range.end / _totalSec).clamp(0.0, 1.0),
                        barColor: theme.colors.mutedForeground.withValues(
                          alpha: 0.35,
                        ),
                        selectedColor: theme.colors.primary,
                        trackColor: theme.colors.secondary,
                      ),
                    ),
                  ),
                  if (_peaks.isEmpty) ...[
                    const Gap(4),
                    Text(
                      l10n.dictRecWaveformUnavailable,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                  RangeSlider(
                    values: _range,
                    min: 0,
                    max: _totalSec,
                    divisions: (_totalSec * 20).clamp(10, 600).round(),
                    labels: RangeLabels(_fmt(_range.start), _fmt(_range.end)),
                    onChanged: _phase == _RecordPhase.submitting
                        ? null
                        : _onRangeChanged,
                  ),
                ],
                const Gap(8),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: (_phase == _RecordPhase.submitting || _trimBusy)
                      ? null
                      : _togglePreview,
                  prefix: Icon(
                    _previewPlaying ? FLucideIcons.pause : FLucideIcons.play,
                  ),
                  child: Text(
                    _previewPlaying ? l10n.dictRecPause : l10n.dictRecPreview,
                  ),
                ),
                const Gap(6),
                Text(
                  l10n.dictRecAgreeBeforeSend,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: _phase == _RecordPhase.submitting
                            ? null
                            : _discardAndRerecord,
                        child: Text(l10n.dictRecRerecord),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: FButton(
                        onPress:
                            (_phase == _RecordPhase.submitting || _trimBusy)
                            ? null
                            : _submit,
                        child: Text(
                          _phase == _RecordPhase.submitting
                              ? l10n.dictRecSending
                              : l10n.dictRecSend,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const Gap(8),
              FButton(
                variant: FButtonVariant.ghost,
                onPress: _blockDismiss
                    ? null
                    : () => Navigator.of(context).pop(),
                child: Text(l10n.commonCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tombol rekam klasik: lingkaran merah (mulai) / kotak di dalam lingkaran (stop).
/// Mendukung tahan-lepas dan ketuk-kunci lewat pointer down/up.
class _RecordRoundButton extends StatelessWidget {
  const _RecordRoundButton({
    required this.recording,
    required this.busy,
    required this.onPressDown,
    required this.onPressUp,
    required this.onPressCancel,
    required this.label,
  });

  final bool recording;
  final bool busy;
  final VoidCallback? onPressDown;
  final VoidCallback? onPressUp;
  final VoidCallback? onPressCancel;
  final String label;

  static const _red = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final enabled = !busy;

    return Column(
      children: [
        Center(
          child: Semantics(
            button: true,
            label: label,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: enabled && onPressDown != null
                  ? (_) => onPressDown!()
                  : null,
              onPointerUp: onPressUp != null ? (_) => onPressUp!() : null,
              onPointerCancel: onPressCancel != null
                  ? (_) => onPressCancel!()
                  : null,
              child: Opacity(
                opacity: enabled ? 1 : 0.45,
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _red.withValues(alpha: 0.35),
                      width: 4,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: recording ? 28 : 52,
                    height: recording ? 28 : 52,
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(recording ? 6 : 26),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Gap(8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: enabled
                ? theme.colors.foreground
                : theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

/// Waveform batang + highlight rentang seleksi.
class _WavformPainter extends CustomPainter {
  _WavformPainter({
    required this.peaks,
    required this.selectionStart,
    required this.selectionEnd,
    required this.barColor,
    required this.selectedColor,
    required this.trackColor,
  });

  final List<double> peaks;
  final double selectionStart;
  final double selectionEnd;
  final Color barColor;
  final Color selectedColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = trackColor.withValues(alpha: 0.5),
    );

    if (peaks.isEmpty || size.width <= 0 || size.height <= 0) return;

    final n = peaks.length;
    const gap = 1.0;
    final barW = math.max(1.0, (size.width - gap * (n - 1)) / n);
    final midY = size.height / 2;
    final maxH = size.height * 0.85;

    for (var i = 0; i < n; i++) {
      final t = (i + 0.5) / n;
      final inSel = t >= selectionStart && t <= selectionEnd;
      final h = math.max(2.0, peaks[i] * maxH);
      final x = i * (barW + gap);
      final paint = Paint()
        ..color = inSel ? selectedColor : barColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barW / 2, midY),
            width: barW,
            height: h,
          ),
          const Radius.circular(1),
        ),
        paint,
      );
    }

    final x0 = selectionStart * size.width;
    final x1 = selectionEnd * size.width;
    final edge = Paint()
      ..color = selectedColor
      ..strokeWidth = 2;
    canvas.drawLine(Offset(x0, 0), Offset(x0, size.height), edge);
    canvas.drawLine(Offset(x1, 0), Offset(x1, size.height), edge);
  }

  @override
  bool shouldRepaint(covariant _WavformPainter oldDelegate) {
    return oldDelegate.peaks != peaks ||
        oldDelegate.selectionStart != selectionStart ||
        oldDelegate.selectionEnd != selectionEnd ||
        oldDelegate.barColor != barColor ||
        oldDelegate.selectedColor != selectedColor;
  }
}
