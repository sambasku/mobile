import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../shared/utils/compress_image_for_upload.dart';
import '../../../shared/utils/photo_pick_constants.dart';

/// Crop 1:1 di dalam Flutter supaya warna ikut [FTheme] (terang/gelap + palet).
/// Batal → null. Berkas yang diunggah WebP persegi [kPhotoPickMaxWidth]×sama
/// (fallback JPEG); avatar ditampilkan lingkaran.
Future<File?> cropProfilePhoto(BuildContext context, String sourcePath) {
  return Navigator.of(context).push<File?>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ProfilePhotoCropPage(sourcePath: sourcePath),
    ),
  );
}

/// Persegi piksel pada foto asli yang sedang terlihat di jendela [side].
Rect coverCropRect({
  required int imageWidth,
  required int imageHeight,
  required double side,
  required double scale,
  required Offset offset,
}) {
  final cover = math.max(side / imageWidth, side / imageHeight);
  final total = cover * scale;
  final drawnW = imageWidth * total;
  final drawnH = imageHeight * total;
  final left = (side - drawnW) / 2 + offset.dx;
  final top = (side - drawnH) / 2 + offset.dy;
  final srcLeft = ((0 - left) / total).clamp(0.0, imageWidth.toDouble());
  final srcTop = ((0 - top) / total).clamp(0.0, imageHeight.toDouble());
  final size = math.min(
    side / total,
    math.min(imageWidth - srcLeft, imageHeight - srcTop),
  );
  return Rect.fromLTWH(srcLeft, srcTop, size, size);
}

Offset clampCoverOffset({
  required int imageWidth,
  required int imageHeight,
  required double side,
  required double scale,
  required Offset offset,
}) {
  final cover = math.max(side / imageWidth, side / imageHeight);
  final overflowX = math.max(0.0, imageWidth * cover * scale - side);
  final overflowY = math.max(0.0, imageHeight * cover * scale - side);
  return Offset(
    offset.dx.clamp(-overflowX / 2, overflowX / 2),
    offset.dy.clamp(-overflowY / 2, overflowY / 2),
  );
}

class ProfilePhotoCropPage extends StatefulWidget {
  const ProfilePhotoCropPage({super.key, required this.sourcePath});

  final String sourcePath;

  @override
  State<ProfilePhotoCropPage> createState() => _ProfilePhotoCropPageState();
}

class _ProfilePhotoCropPageState extends State<ProfilePhotoCropPage> {
  ui.Image? _image;
  double _scale = 1;
  Offset _offset = Offset.zero;
  double _gestureScale = 1;
  double _side = 0;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final bytes = await File(widget.sourcePath).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() => _image = frame.image);
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final image = _image;
    if (image == null || _side <= 0 || _saving) return;
    setState(() => _saving = true);
    try {
      final src = coverCropRect(
        imageWidth: image.width,
        imageHeight: image.height,
        side: _side,
        scale: _scale,
        offset: _offset,
      );
      final out = kPhotoPickMaxWidth;
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawImageRect(
        image,
        src,
        Rect.fromLTWH(0, 0, out, out),
        Paint()..filterQuality = FilterQuality.high,
      );
      final cropped = await recorder.endRecording().toImage(out.toInt(), out.toInt());
      final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
      cropped.dispose();
      if (data == null || !mounted) return;
      final png = File(
        '${Directory.systemTemp.path}/avatar_crop_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await png.writeAsBytes(data.buffer.asUint8List(), flush: true);
      final file = await compressImageForUpload(png);
      if (!mounted) return;
      Navigator.of(context).pop(file);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final image = _image;

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: const Text('Atur foto profil'),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: image == null
                ? const Center(child: FCircularProgress())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final side = math.min(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ) - 48;
                      _side = side;
                      return Center(
                        child: SizedBox(
                          width: side,
                          height: side,
                          child: GestureDetector(
                            onScaleStart: (_) => _gestureScale = _scale,
                            onScaleUpdate: (details) {
                              final nextScale = (_gestureScale * details.scale)
                                  .clamp(1.0, 5.0);
                              setState(() {
                                _scale = nextScale;
                                _offset = clampCoverOffset(
                                  imageWidth: image.width,
                                  imageHeight: image.height,
                                  side: side,
                                  scale: nextScale,
                                  offset: _offset + details.focalPointDelta,
                                );
                              });
                            },
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colors.primary,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: ColoredBox(
                                  color: theme.colors.muted,
                                  child: Transform.translate(
                                    offset: _offset,
                                    child: Transform.scale(
                                      scale: _scale,
                                      child: CustomPaint(
                                        size: Size(side, side),
                                        painter: _CoverPainter(image),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FButton(
                onPress: image == null || _saving ? null : _save,
                prefix: _saving ? const FCircularProgress() : null,
                child: Text(_saving ? 'Menyimpan...' : 'Pakai'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverPainter extends CustomPainter {
  _CoverPainter(this.image);

  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final cover = math.max(size.width / image.width, size.height / image.height);
    final w = image.width * cover;
    final h = image.height * cover;
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH((size.width - w) / 2, (size.height - h) / 2, w, h),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _CoverPainter oldDelegate) =>
      oldDelegate.image != image;
}
