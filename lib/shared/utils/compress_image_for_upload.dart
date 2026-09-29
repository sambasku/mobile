import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

import 'file_persist_helper.dart';
import 'photo_pick_constants.dart';

/// Kompres [source] ke WebP (max [maxWidth]×[maxHeight], quality
/// [kPhotoPickQuality]). Gagal / tidak didukung → JPEG fallback; jika
/// tetap gagal → [source] apa adanya.
Future<File> compressImageForUpload(
  File source, {
  double maxWidth = kPhotoPickMaxWidth,
  double maxHeight = kPhotoPickMaxHeight,
  int quality = kPhotoPickQuality,
}) async {
  if (!await source.exists()) return source;

  final dir = await pickedPersistDir();
  final stamp = DateTime.now().microsecondsSinceEpoch;
  final webpPath = p.join(dir.path, 'upload_$stamp.webp');

  try {
    final webp = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      webpPath,
      quality: quality,
      minWidth: maxWidth.round(),
      minHeight: maxHeight.round(),
      format: CompressFormat.webp,
    );
    if (webp != null && await File(webp.path).length() > 0) {
      return File(webp.path);
    }
  } on UnsupportedError catch (e, st) {
    debugPrint('[compressImageForUpload] webp unsupported: $e\n$st');
  } catch (e, st) {
    debugPrint('[compressImageForUpload] webp failed: $e\n$st');
  }

  final jpgPath = p.join(dir.path, 'upload_$stamp.jpg');
  try {
    final jpg = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      jpgPath,
      quality: quality,
      minWidth: maxWidth.round(),
      minHeight: maxHeight.round(),
      format: CompressFormat.jpeg,
    );
    if (jpg != null && await File(jpg.path).length() > 0) {
      return File(jpg.path);
    }
  } catch (e, st) {
    debugPrint('[compressImageForUpload] jpeg fallback failed: $e\n$st');
  }

  return source;
}
