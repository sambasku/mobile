import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import '../utils/compress_image_for_upload.dart';
import '../utils/photo_pick_constants.dart';
import '../../../l10n/app_localizations.dart';

/// Opsi aspect ratio standar untuk crop generik (#142).
/// [ratio] null = Bebas (kotak crop bebas digeser/diubah ukuran).
class CropAspectRatio {
  const CropAspectRatio({required this.label, this.ratio});

  final String label;

  /// width / height. Null = mode bebas (handle sudut).
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

/// Rasio 1:1 untuk logo / avatar (tanpa pilihan Bebas di UI).
const CropAspectRatio kCropAspectRatioSquare = CropAspectRatio(
  label: '1:1',
  ratio: 1,
);

String cropAspectDisplayLabel(AppLocalizations l10n, CropAspectRatio opt) =>
    opt.ratio == null ? l10n.cropAspectFree : opt.label;

/// Crop generik dalam Flutter (tema Forui, tanpa dependensi native).
///
/// Default **Bebas**: kotak crop bisa digeser + diubah ukuran (rasio bebas).
/// Rasio tetap (1:1, …): jendela fixed + pan/zoom foto. Batal → null.
/// [lockedAspectRatio] mengunci rasio + menyembunyikan chip pilihan.
/// **Lewati** → berkas asli. Hasil ≤ [kPhotoPickMaxWidth] sisi terpanjang.
Future<File?> cropImage(
  BuildContext context,
  String sourcePath, {
  CropAspectRatio? lockedAspectRatio,
}) {
  return Navigator.of(context).push<File?>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ImageCropPage(
        sourcePath: sourcePath,
        lockedAspectRatio: lockedAspectRatio,
      ),
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

/// Kotak contain-fit foto di dalam [avail].
Rect containImageRect({
  required int imageWidth,
  required int imageHeight,
  required Size avail,
}) {
  final ratio = imageWidth / imageHeight;
  var w = avail.width;
  var h = w / ratio;
  if (h > avail.height) {
    h = avail.height;
    w = h * ratio;
  }
  return Rect.fromLTWH(
    (avail.width - w) / 2,
    (avail.height - h) / 2,
    w,
    h,
  );
}

/// [norm] (0..1 di ruang foto) → rect layar di atas [imageDisplay].
Rect freeCropToDisplay(Rect norm, Rect imageDisplay) {
  return Rect.fromLTWH(
    imageDisplay.left + norm.left * imageDisplay.width,
    imageDisplay.top + norm.top * imageDisplay.height,
    norm.width * imageDisplay.width,
    norm.height * imageDisplay.height,
  );
}

/// Rect layar → piksel foto (clamp ke batas gambar).
Rect freeCropToSource({
  required Rect cropDisplay,
  required Rect imageDisplay,
  required int imageWidth,
  required int imageHeight,
}) {
  final nx = ((cropDisplay.left - imageDisplay.left) / imageDisplay.width)
      .clamp(0.0, 1.0);
  final ny = ((cropDisplay.top - imageDisplay.top) / imageDisplay.height)
      .clamp(0.0, 1.0);
  final nw = (cropDisplay.width / imageDisplay.width).clamp(0.0, 1.0 - nx);
  final nh = (cropDisplay.height / imageDisplay.height).clamp(0.0, 1.0 - ny);
  return Rect.fromLTWH(
    nx * imageWidth,
    ny * imageHeight,
    math.max(1, nw * imageWidth),
    math.max(1, nh * imageHeight),
  );
}

/// Clamp + min size (fraksi sisi foto) untuk kotak bebas.
Rect clampFreeNorm(Rect norm, {double minFrac = 0.12}) {
  var left = norm.left;
  var top = norm.top;
  var width = norm.width;
  var height = norm.height;
  width = width.clamp(minFrac, 1.0);
  height = height.clamp(minFrac, 1.0);
  left = left.clamp(0.0, 1.0 - width);
  top = top.clamp(0.0, 1.0 - height);
  return Rect.fromLTWH(left, top, width, height);
}

enum _FreeHit { none, move, tl, tr, bl, br }

_FreeHit _hitFreeCrop(Offset local, Rect crop, {double handle = 28}) {
  bool near(Offset p) => (local - p).distance <= handle;
  if (near(crop.topLeft)) return _FreeHit.tl;
  if (near(crop.topRight)) return _FreeHit.tr;
  if (near(crop.bottomLeft)) return _FreeHit.bl;
  if (near(crop.bottomRight)) return _FreeHit.br;
  if (crop.inflate(4).contains(local)) return _FreeHit.move;
  return _FreeHit.none;
}

Rect _applyFreeHit({
  required Rect norm,
  required _FreeHit hit,
  required Offset deltaNorm,
}) {
  var l = norm.left;
  var t = norm.top;
  var r = norm.right;
  var b = norm.bottom;
  switch (hit) {
    case _FreeHit.move:
      l += deltaNorm.dx;
      t += deltaNorm.dy;
      r += deltaNorm.dx;
      b += deltaNorm.dy;
    case _FreeHit.tl:
      l += deltaNorm.dx;
      t += deltaNorm.dy;
    case _FreeHit.tr:
      r += deltaNorm.dx;
      t += deltaNorm.dy;
    case _FreeHit.bl:
      l += deltaNorm.dx;
      b += deltaNorm.dy;
    case _FreeHit.br:
      r += deltaNorm.dx;
      b += deltaNorm.dy;
    case _FreeHit.none:
      break;
  }
  return clampFreeNorm(Rect.fromLTRB(l, t, r, b));
}

class ImageCropPage extends StatefulWidget {
  const ImageCropPage({
    super.key,
    required this.sourcePath,
    this.lockedAspectRatio,
  });

  final String sourcePath;

  /// Null = user boleh ganti rasio. Non-null = kunci + sembunyikan chip.
  final CropAspectRatio? lockedAspectRatio;

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

  /// Kotak crop mode Bebas, fraksi 0..1 di ruang foto.
  Rect _freeNorm = const Rect.fromLTWH(0.08, 0.08, 0.84, 0.84);
  Rect? _imageDisplay;
  _FreeHit _freeHit = _FreeHit.none;
  var _saving = false;

  bool get _isFree => _aspect.ratio == null;
  bool get _aspectLocked => widget.lockedAspectRatio != null;

  @override
  void initState() {
    super.initState();
    _aspect = widget.lockedAspectRatio ?? kCropAspectRatios.first;
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
      if (next.ratio == null) {
        _freeNorm = const Rect.fromLTWH(0.08, 0.08, 0.84, 0.84);
      }
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
    if (image == null || _saving) return;
    if (!_isFree && _box.isEmpty) return;
    if (_isFree && (_imageDisplay == null || _imageDisplay!.isEmpty)) return;
    setState(() => _saving = true);
    try {
      final Rect src;
      if (_isFree) {
        final display = _imageDisplay!;
        final crop = freeCropToDisplay(_freeNorm, display);
        src = freeCropToSource(
          cropDisplay: crop,
          imageDisplay: display,
          imageWidth: image.width,
          imageHeight: image.height,
        );
      } else {
        src = windowCropRect(
          imageWidth: image.width,
          imageHeight: image.height,
          width: _box.width,
          height: _box.height,
          scale: _scale,
          offset: _offset,
        );
      }
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

  Widget _buildFixedCrop(BuildContext context, ui.Image image) {
    final theme = context.theme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = _fitBox(
          Size(constraints.maxWidth - 32, constraints.maxHeight - 32),
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
                final next = (_gestureScale * details.scale).clamp(1.0, 5.0);
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
                  border: Border.all(color: theme.colors.primary, width: 2),
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
    );
  }

  Widget _buildFreeCrop(BuildContext context, ui.Image image) {
    final theme = context.theme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final avail = Size(constraints.maxWidth, constraints.maxHeight);
        final display = containImageRect(
          imageWidth: image.width,
          imageHeight: image.height,
          avail: avail,
        );
        _imageDisplay = display;
        final crop = freeCropToDisplay(_freeNorm, display);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) {
            _freeHit = _hitFreeCrop(d.localPosition, crop);
          },
          onPanUpdate: (d) {
            if (_freeHit == _FreeHit.none) return;
            final deltaNorm = Offset(
              d.delta.dx / display.width,
              d.delta.dy / display.height,
            );
            setState(() {
              _freeNorm = _applyFreeHit(
                norm: _freeNorm,
                hit: _freeHit,
                deltaNorm: deltaNorm,
              );
            });
          },
          onPanEnd: (_) => _freeHit = _FreeHit.none,
          child: CustomPaint(
            size: avail,
            painter: _FreeCropPainter(
              image: image,
              imageDisplay: display,
              crop: crop,
              borderColor: theme.colors.primary,
              dimColor: theme.colors.background.withValues(alpha: 0.55),
              handleColor: theme.colors.primary,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final l10n = AppLocalizations.of(context);

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(l10n.cropPhotoTitle),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
        suffixes: [
          FButton(
            variant: FButtonVariant.ghost,
            onPress: _saving
                ? null
                : () => Navigator.of(context).pop(File(widget.sourcePath)),
            child: Text(l10n.cropSkip),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: image == null
                ? const Center(child: FCircularProgress())
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: _isFree
                        ? _buildFreeCrop(context, image)
                        : _buildFixedCrop(context, image),
                  ),
          ),
          if (!_aspectLocked)
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
                        child: Text(cropAspectDisplayLabel(l10n, opt)),
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
                child: Text(
                  _saving ? l10n.commonSaving : l10n.profileCropUse,
                ),
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

class _FreeCropPainter extends CustomPainter {
  _FreeCropPainter({
    required this.image,
    required this.imageDisplay,
    required this.crop,
    required this.borderColor,
    required this.dimColor,
    required this.handleColor,
  });

  final ui.Image image;
  final Rect imageDisplay;
  final Rect crop;
  final Color borderColor;
  final Color dimColor;
  final Color handleColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      imageDisplay,
      Paint()..filterQuality = FilterQuality.medium,
    );

    final dim = Paint()..color = dimColor;
    // Empat strip di luar kotak crop (dalam bounds layar).
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, crop.top), dim);
    canvas.drawRect(
      Rect.fromLTRB(0, crop.bottom, size.width, size.height),
      dim,
    );
    canvas.drawRect(Rect.fromLTRB(0, crop.top, crop.left, crop.bottom), dim);
    canvas.drawRect(
      Rect.fromLTRB(crop.right, crop.top, size.width, crop.bottom),
      dim,
    );

    canvas.drawRect(
      crop,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = borderColor,
    );

    const handle = 14.0;
    final hp = Paint()..color = handleColor;
    for (final c in [
      crop.topLeft,
      crop.topRight,
      crop.bottomLeft,
      crop.bottomRight,
    ]) {
      canvas.drawRect(
        Rect.fromCenter(center: c, width: handle, height: handle),
        hp,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FreeCropPainter old) =>
      old.image != image ||
      old.imageDisplay != imageDisplay ||
      old.crop != crop ||
      old.borderColor != borderColor ||
      old.dimColor != dimColor ||
      old.handleColor != handleColor;
}
