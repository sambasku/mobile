import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/share_video_composer.dart';
import '../../../shared/utils/permission_helper.dart';

/// Capture [RepaintBoundary] → PNG bytes.
Future<Uint8List> captureShareCardPngBytes(GlobalKey repaintKey) async {
  await WidgetsBinding.instance.endOfFrame;
  var boundary =
      repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null || !boundary.hasSize || boundary.size.isEmpty) {
    await WidgetsBinding.instance.endOfFrame;
    boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  }
  if (boundary == null) {
    throw StateError('Kartu share belum siap digambar');
  }
  if (!boundary.hasSize || boundary.size.isEmpty) {
    throw StateError('Kartu share belum siap digambar');
  }

  final image = await boundary.toImage(pixelRatio: 2);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Gagal encode PNG');
  }
  return byteData.buffer.asUint8List();
}

/// `unavailable` (platform tidak melapor hasil) dihitung sukses.
bool _notDismissed(ShareResult r) => r.status != ShareResultStatus.dismissed;

/// Render [RepaintBoundary] → PNG temp → native share sheet.
/// Returns `false` jika user menutup share sheet tanpa memilih tujuan.
Future<bool> shareCardAsPng({
  required GlobalKey repaintKey,
  required String caption,
  required Rect sharePositionOrigin,
}) async {
  final bytes = await captureShareCardPngBytes(repaintKey);

  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/sambasku-share-${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(bytes, flush: true);

  final result = await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'image/png')],
      text: caption,
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
  return _notDismissed(result);
}

/// Render [RepaintBoundary] → simpan PNG ke galeri perangkat.
///
/// Throws [StateError] jika render gagal, atau [GalException] dari plugin.
/// Returns `false` jika user menolak izin galeri.
Future<bool> saveCardToGallery({required GlobalKey repaintKey}) async {
  final granted = await requestGalleryWriteAccess();
  if (!granted) return false;

  final bytes = await captureShareCardPngBytes(repaintKey);
  final name = 'sambasku-share-${DateTime.now().millisecondsSinceEpoch}';
  await Gal.putImageBytes(bytes, name: name);
  return true;
}

Future<String> _downloadToTemp(String url) async {
  final dir = await getTemporaryDirectory();
  final file = File(
    '${dir.path}/sambasku-src-${DateTime.now().millisecondsSinceEpoch}.mp4',
  );
  final client = HttpClient();
  try {
    final req = await client.getUrl(Uri.parse(url));
    final res = await req.close();
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('Gagal unduh video (${res.statusCode})');
    }
    final sink = file.openWrite();
    await res.pipe(sink);
  } finally {
    client.close();
  }
  return file.path;
}

Future<bool> shareCardAsVideo({
  required GlobalKey overlayKey,
  required String videoUrl,
  required bool videoIsFile,
  required String caption,
  required Rect sharePositionOrigin,
}) async {
  final overlayBytes = await captureShareCardPngBytes(overlayKey);
  final dir = await getTemporaryDirectory();
  final overlay = File(
    '${dir.path}/sambasku-overlay-${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await overlay.writeAsBytes(overlayBytes, flush: true);

  final videoPath = videoIsFile ? videoUrl : await _downloadToTemp(videoUrl);
  final outPath = await ShareVideoComposer.compose(
    videoPath: videoPath,
    overlayPngPath: overlay.path,
  );

  final result = await SharePlus.instance.share(
    ShareParams(
      files: [XFile(outPath, mimeType: 'video/mp4')],
      text: caption,
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
  return _notDismissed(result);
}

Future<bool> saveCardVideoToGallery({
  required GlobalKey overlayKey,
  required String videoUrl,
  required bool videoIsFile,
}) async {
  final granted = await requestGalleryWriteAccess();
  if (!granted) return false;

  final overlayBytes = await captureShareCardPngBytes(overlayKey);
  final dir = await getTemporaryDirectory();
  final overlay = File(
    '${dir.path}/sambasku-overlay-${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await overlay.writeAsBytes(overlayBytes, flush: true);
  final videoPath = videoIsFile ? videoUrl : await _downloadToTemp(videoUrl);
  final outPath = await ShareVideoComposer.compose(
    videoPath: videoPath,
    overlayPngPath: overlay.path,
  );
  await Gal.putVideo(outPath);
  return true;
}
