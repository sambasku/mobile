import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import '../utils/compress_image_for_upload.dart';
import '../utils/photo_pick_constants.dart';
import '../../../l10n/app_localizations.dart';

/// Opsi aspect ratio standar untuk crop generik (#142).
/// [ratio] null = Bebas (full-frame, ikut rasio foto asli).
class CropAspectRatio {
  const CropAspectRatio({required this.label, this.ratio});

  final String label;

  /// width / height.
  final double? ratio;
}

const List<CropAspectRatio> kCropAspectRatios = [
  // Label 'Bebas' = id lokal default; UI pakai [cropAspectDisplayLabel].
  CropAspectRatio(label: 'Bebas'),
  CropAspectRatio(label: '1:1', ratio: 1),
  CropAspectRatio(label: '4:3', ratio: 4 / 3),
  CropAspectRatio(label: '3:4', ratio: 3 / 4),
  CropAspectRatio(label: '16:9', ratio: 16 / 9),
];

String cropAspectDisplayLabel(AppLocalizations l10n, CropAspectRatio opt) =>
    opt.ratio == null ? l10n.cropAspectFree : opt.label;

/// Crop generik dalam Flutter (tema Forui, tanpa dependensi native).
///
/// Default **Bebas** (full-frame). Batal → null. **Lewati** → berkas asli
/// dikembalikan apa adanya. Hasil crop diekspor ≤ [kPhotoPickMaxWidth] sisi
/// terpanjang lalu dikompresi lewat [compressImageForUpload].
Future<File?> cropImage(BuildContext context, String sourcePath) {
  return Navigator.of(context).push<File?>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ImageCropPage(sourcePath: sourcePath),
    ),
  );
}

/// Area piksel pada foto asli yang terlihat di jendela [width]×[height].
Rect windowCropRect({
  required int imageWidth,
  required int imageHeight,
  required double width,
  required double height,
  required double scale,
  required Offset offset,
}) {
  final total = math.max(width / imageWidth, height / imageHeight) * scale;
  final left = (width - imageWidth * total) / 2 + offset.dx;
  final top = (height - imageHeight * total) / 2 + offset.dy;
  final srcLeft = ((0 - left) / total).clamp(0.0, imageWidth.toDouble());
  final srcTop = ((0 - top) / total).clamp(0.0, imageHeight.toDouble());
  final srcW = math.min(width / total, imageWidth - srcLeft);
  final srcH = math.min(height / total, imageHeight - srcTop);
  return Rect.fromLTWH(srcLeft, srcTop, srcW, srcH);
}

Offset clampWindowOffset({
  required int imageWidth,
  required int imageHeight,
  required double width,
  required double height,
  required double scale,
  required Offset offset,
}) {
  final cover = math.max(width / imageWidth, height / imageHeight);
  final overflowX = math.max(0.0, imageWidth * cover * scale - width);
  final overflowY = math.max(0.0, imageHeight * cover * scale - height);
  return Offset(
    offset.dx.clamp(-overflowX / 2, overflowX / 2),
    offset.dy.clamp(-overflowY / 2, overflowY / 2),
  );
}

/// Ukuran piksel ekspor: sisi terpanjang dibatasi [maxSide], tanpa upscale.
Size cropOutputSize(Rect src, {double maxSide = kPhotoPickMaxWidth}) {
  final longest = math.max(src.width, src.height);
  final f = longest > maxSide ? maxSide / longest : 1.0;
  return Size(
    math.max(1, (src.width * f).roundToDouble()),
    math.max(1, (src.height * f).roundToDouble()),
  );
}

class ImageCropPage extends StatefulWidget {
  const ImageCropPage({super.key, required this.sourcePath});

  final String sourcePath;

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  ui.Image? _image;
  late CropAspectRatio _aspect;
  double _scale = 1;
  Offset _offset = Offset.zero;
  double _gestureScale = 1;
  Size _box = Size.zero;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _aspect = kCropAspectRatios.first;
    _load();
  }

  Future<void> _load() async {
    try {
      final bytes = await File(widget.sourcePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() => _image = frame.image);
    } catch (_) {
      // Gagal decode → pakai foto asli, jangan blok user.
      if (mounted) Navigator.of(context).pop(File(widget.sourcePath));
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  void _pickAspect(CropAspectRatio next) {
    setState(() {
      _aspect = next;
      _scale = 1;
      _offset = Offset.zero;
    });
  }

  /// Jendela crop terbesar dengan rasio terpilih di dalam area [avail].
  Size _fitBox(Size avail, ui.Image image) {
    final ratio = _aspect.ratio ?? image.width / image.height;
    var w = avail.width;
    var h = w / ratio;
    if (h > avail.height) {
      h = avail.height;
      w = h * ratio;
    }
    return Size(w, h);
  }

  Future<void> _save() async {
    final image = _image;
    if (image == null || _box.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final src = windowCropRect(
        imageWidth: image.width,
        imageHeight: image.height,
        width: _box.width,
        height: _box.height,
        scale: _scale,
        offset: _offset,
      );
      final out = cropOutputSize(src);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawImageRect(
        image,
        src,
        Rect.fromLTWH(0, 0, out.width, out.height),
        Paint()..filterQuality = FilterQuality.high,
      );
      final cropped = await recorder.endRecording().toImage(
            out.width.toInt(),
            out.height.toInt(),
          );
      final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
      cropped.dispose();
      if (data == null || !mounted) return;
      final png = File(
        '${Directory.systemTemp.path}/crop_${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await png.writeAsBytes(data.buffer.asUint8List(), flush: true);
      final file = await compressImageForUpload(
        png,
        maxWidth: kPhotoPickMaxWidth,
        maxHeight: kPhotoPickMaxHeight,
      );
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
        title: Text(AppLocalizations.of(context).cropPhotoTitle),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
        suffixes: [
          FButton(
            variant: FButtonVariant.ghost,
            onPress: _saving
                ? null
                : () => Navigator.of(context).pop(File(widget.sourcePath)),
            child: Text(AppLocalizations.of(context).cropSkip),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: image == null
                ? const Center(child: FCircularProgress())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final box = _fitBox(
                        Size(
                          constraints.maxWidth - 32,
                          constraints.maxHeight - 32,
                        ),
                        image,
                      );
                      _box = box;
                      return Center(
                        child: SizedBox(
                          width: box.width,
                          height: box.height,
                          child: GestureDetector(
                            onScaleStart: (_) => _gestureScale = _scale,
                            onScaleUpdate: (details) {
                              final next = (_gestureScale * details.scale)
                                  .clamp(1.0, 5.0);
                              setState(() {
                                _scale = next;
                                _offset = clampWindowOffset(
                                  imageWidth: image.width,
                                  imageHeight: image.height,
                                  width: box.width,
                                  height: box.height,
                                  scale: next,
                                  offset: _offset + details.focalPointDelta,
                                );
                              });
                            },
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colors.primary,
                                  width: 2,
                                ),
                              ),
                              child: ClipRect(
                                  child: ColoredBox(
                                    color: theme.colors.muted,
                                    child: Transform.translate(
                                      offset: _offset,
                                      child: Transform.scale(
                                        scale: _scale,
                                        child: CustomPaint(
                                          size: box,
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
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final opt in kCropAspectRatios)
                    GestureDetector(
                      onTap: () => _pickAspect(opt),
                      child: FBadge(
                        variant: _aspect == opt
                            ? FBadgeVariant.primary
                            : FBadgeVariant.secondary,
                        child: Text(cropAspectDisplayLabel(AppLocalizations.of(context), opt)),
                      ),
                    ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FButton(
                onPress: image == null || _saving ? null : _save,
                prefix: _saving ? const FCircularProgress() : null,
                child: Text(_saving ? AppLocalizations.of(context).commonSaving : AppLocalizations.of(context).profileCropUse),
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
