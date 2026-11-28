import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Nama font meme. Harus sama dengan `family` di `pubspec.yaml`.
const kMemeFontFamily = 'Anton';

/// Sisi stiker keluaran (persegi), selaras dengan kompresi WebP 512 di sheet.
const kMemeCanvasSize = 512.0;

const _kPadding = 12.0;
const _kMaxFontSize = 120.0;
const _kMinFontSize = 18.0;
const _kFontStep = 4.0;
const _kStrokeRatio = 0.12;

/// Preset warna untuk teks dan border meme. Label tampil lewat l10n di UI.
enum MemeColor {
  white(ui.Color(0xFFFFFFFF)),
  black(ui.Color(0xFF000000)),
  yellow(ui.Color(0xFFFFD60A)),
  red(ui.Color(0xFFE53935)),
  blue(ui.Color(0xFF1E88E5));

  const MemeColor(this.value);

  final ui.Color value;
}

/// Ukuran font terbesar yang muat di [maxWidth] x [maxHeight].
/// Turun bertahap; mentok di [_kMinFontSize] walau tetap tidak muat.
double fitMemeFontSize({
  required String text,
  required double maxWidth,
  required double maxHeight,
}) {
  var size = _kMaxFontSize;
  while (size > _kMinFontSize) {
    final painter = _memePainter(text, size, maxWidth, color: const ui.Color(0xFFFFFFFF));
    if (painter.width <= maxWidth && painter.height <= maxHeight) return size;
    size -= _kFontStep;
  }
  return _kMinFontSize;
}

/// Render [baseFile] (persegi) + teks meme atas/bawah ke PNG 512x512 di [outFile].
/// Teks kosong dilewati. Berjalan di luar layar, tanpa RepaintBoundary.
Future<File> renderMemeImage({
  required File baseFile,
  required String topText,
  required String bottomText,
  required File outFile,
  MemeColor textColor = MemeColor.white,
  MemeColor borderColor = MemeColor.black,
}) async {
  final codec = await ui.instantiateImageCodec(await baseFile.readAsBytes());
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawImageRect(
    image,
    ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    const ui.Rect.fromLTWH(0, 0, kMemeCanvasSize, kMemeCanvasSize),
    ui.Paint()..filterQuality = ui.FilterQuality.high,
  );
  _drawMemeLine(canvas, topText, atTop: true, textColor: textColor, borderColor: borderColor);
  _drawMemeLine(canvas, bottomText, atTop: false, textColor: textColor, borderColor: borderColor);

  final picture = recorder.endRecording();
  final output = await picture.toImage(
    kMemeCanvasSize.toInt(),
    kMemeCanvasSize.toInt(),
  );
  final data = await output.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  output.dispose();
  picture.dispose();

  if (data == null) {
    throw StateError('Gagal mengubah teks meme menjadi PNG');
  }
  await outFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
  return outFile;
}

TextPainter _memePainter(
  String text,
  double fontSize,
  double maxWidth, {
  ui.Paint? foreground,
  ui.Color? color,
}) {
  return TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: kMemeFontFamily,
        fontSize: fontSize,
        height: 1.0,
        foreground: foreground,
        color: foreground == null ? color : null,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);
}

void _drawMemeLine(
  ui.Canvas canvas,
  String raw, {
  required bool atTop,
  required MemeColor textColor,
  required MemeColor borderColor,
}) {
  final text = raw.trim().toUpperCase();
  if (text.isEmpty) return;

  const maxWidth = kMemeCanvasSize - _kPadding * 2;
  const maxHeight = kMemeCanvasSize / 2 - _kPadding;
  final size = fitMemeFontSize(
    text: text,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
  );

  // Outline dulu, lalu isi di atasnya: teks berwarna dengan garis tepi berwarna.
  final stroke = _memePainter(
    text,
    size,
    maxWidth,
    foreground: ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = size * _kStrokeRatio
      ..strokeJoin = ui.StrokeJoin.round
      ..color = borderColor.value,
  );
  final fill = _memePainter(
    text,
    size,
    maxWidth,
    color: textColor.value,
  );

  final dy = atTop
      ? _kPadding
      : kMemeCanvasSize - _kPadding - fill.height;
  final offset = ui.Offset(_kPadding, dy);
  stroke.paint(canvas, offset);
  fill.paint(canvas, offset);
}
