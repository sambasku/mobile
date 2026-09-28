import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

/// Potong file WAV PCM 16-bit (hasil [AudioEncoder.wav] dari package `record`).
class WavTrimResult {
  const WavTrimResult({
    required this.file,
    required this.durationMs,
  });

  final File file;
  final int durationMs;
}

class _WavInfo {
  const _WavInfo({
    required this.bytes,
    required this.sampleRate,
    required this.channels,
    required this.bitsPerSample,
    required this.dataOffset,
    required this.dataSize,
  });

  final Uint8List bytes;
  final int sampleRate;
  final int channels;
  final int bitsPerSample;
  final int dataOffset;
  final int dataSize;

  int get blockAlign => (channels * bitsPerSample) ~/ 8;
  int get byteRate => sampleRate * blockAlign;
  double get durationSec => dataSize / byteRate;
}

_WavInfo _parseWav(Uint8List bytes) {
  if (bytes.length < 44) {
    throw StateError('File WAV terlalu pendek');
  }
  final bd = ByteData.sublistView(bytes);
  final riff = String.fromCharCodes(bytes.sublist(0, 4));
  final wave = String.fromCharCodes(bytes.sublist(8, 12));
  if (riff != 'RIFF' || wave != 'WAVE') {
    throw StateError('Bukan file WAV RIFF');
  }

  var offset = 12;
  var sampleRate = 0;
  var channels = 0;
  var bitsPerSample = 0;
  var dataOffset = -1;
  var dataSize = 0;

  while (offset + 8 <= bytes.length) {
    final id = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final size = bd.getUint32(offset + 4, Endian.little);
    final chunkData = offset + 8;
    if (id == 'fmt ') {
      channels = bd.getUint16(chunkData + 2, Endian.little);
      sampleRate = bd.getUint32(chunkData + 4, Endian.little);
      bitsPerSample = bd.getUint16(chunkData + 14, Endian.little);
    } else if (id == 'data') {
      dataOffset = chunkData;
      dataSize = size;
      break;
    }
    offset = chunkData + size + (size.isOdd ? 1 : 0);
  }

  if (dataOffset < 0 || sampleRate <= 0 || channels <= 0 || bitsPerSample != 16) {
    throw StateError('WAV tidak didukung (butuh PCM 16-bit)');
  }

  return _WavInfo(
    bytes: bytes,
    sampleRate: sampleRate,
    channels: channels,
    bitsPerSample: bitsPerSample,
    dataOffset: dataOffset,
    dataSize: dataSize,
  );
}

/// Durasi detik dari file WAV.
Future<double> wavDurationSeconds(File file) async {
  final info = _parseWav(await file.readAsBytes());
  return info.durationSec;
}

/// Tulis potongan [startSec, endSec] ke file WAV baru di direktori yang sama.
Future<WavTrimResult> trimWavFile(
  File source, {
  required double startSec,
  required double endSec,
}) async {
  final info = _parseWav(await source.readAsBytes());
  final duration = info.durationSec;
  final start = startSec.clamp(0.0, duration);
  var end = endSec.clamp(0.0, duration);
  if (end - start < 0.05) {
    end = math.min(duration, start + 0.05);
  }

  final startByte =
      (start * info.byteRate).floor() ~/ info.blockAlign * info.blockAlign;
  final endByte =
      (end * info.byteRate).ceil() ~/ info.blockAlign * info.blockAlign;
  final sliceStart = info.dataOffset + startByte.clamp(0, info.dataSize);
  final sliceEnd =
      info.dataOffset + endByte.clamp(0, info.dataSize);
  final pcm = info.bytes.sublist(sliceStart, sliceEnd);
  final dataSize = pcm.length;
  final out = BytesBuilder(copy: false);

  void writeString(String s) => out.add(s.codeUnits);
  void writeUint32(int v) {
    final b = ByteData(4)..setUint32(0, v, Endian.little);
    out.add(b.buffer.asUint8List());
  }

  void writeUint16(int v) {
    final b = ByteData(2)..setUint16(0, v, Endian.little);
    out.add(b.buffer.asUint8List());
  }

  writeString('RIFF');
  writeUint32(36 + dataSize);
  writeString('WAVE');
  writeString('fmt ');
  writeUint32(16);
  writeUint16(1); // PCM
  writeUint16(info.channels);
  writeUint32(info.sampleRate);
  writeUint32(info.byteRate);
  writeUint16(info.blockAlign);
  writeUint16(info.bitsPerSample);
  writeString('data');
  writeUint32(dataSize);
  out.add(pcm);

  final dir = source.parent.path;
  final outPath =
      '$dir/trim_${DateTime.now().millisecondsSinceEpoch}.wav';
  final file = File(outPath);
  await file.writeAsBytes(out.toBytes(), flush: true);
  final durationMs = ((end - start) * 1000).round().clamp(1, 600000);
  return WavTrimResult(file: file, durationMs: durationMs);
}

/// Peak waveform (0..1) untuk visual trim - RMS per batang.
Future<List<double>> computeWavPeaks(
  File file, {
  int barCount = 80,
}) async {
  final info = _parseWav(await file.readAsBytes());
  final data = info.bytes.buffer.asByteData();
  final samples = info.dataSize ~/ 2;
  if (samples <= 0 || barCount <= 0) return const [];

  final bars = <double>[];
  final perBar = math.max(1, samples ~/ barCount);
  var peakMax = 1e-6;

  for (var b = 0; b < barCount; b++) {
    final start = b * perBar;
    if (start >= samples) {
      bars.add(0);
      continue;
    }
    final end = math.min(start + perBar, samples);
    var sum = 0.0;
    for (var j = start; j < end; j++) {
      final s = data.getInt16(info.dataOffset + j * 2, Endian.little) / 32768.0;
      sum += s * s;
    }
    final rms = math.sqrt(sum / (end - start));
    bars.add(rms);
    if (rms > peakMax) peakMax = rms;
  }

  return [for (final p in bars) (p / peakMax).clamp(0.0, 1.0)];
}
