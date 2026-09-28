import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

enum DiscussionCensorBrushMode { pixelate, blur, block }

/// Editor sensor satu gambar (pixelate / blur / block) untuk Tinjauan Diskusi.
class DiscussionImageCensorEditorPage extends StatefulWidget {
  const DiscussionImageCensorEditorPage({
    super.key,
    required this.imageUrl,
    required this.onApply,
  });

  final String imageUrl;
  final void Function(Uint8List pngBytes) onApply;

  @override
  State<DiscussionImageCensorEditorPage> createState() =>
      _DiscussionImageCensorEditorPageState();
}

class _DiscussionImageCensorEditorPageState
    extends State<DiscussionImageCensorEditorPage> {
  ui.Image? _image;
  ByteData? _rgba;
  String? _error;
  var _loading = true;
  var _busy = false;
  var _brushRadius = 28.0;
  DiscussionCensorBrushMode _mode = DiscussionCensorBrushMode.pixelate;
  final List<ByteData> _undoStack = [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await Dio().get<List<int>>(
        widget.imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = res.data;
      if (bytes == null || bytes.isEmpty) {
        throw StateError('Body kosong');
      }
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(bytes),
        targetWidth: 960,
      );
      final frame = await codec.getNextFrame();
      final img = frame.image;
      final rgba = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (rgba == null) throw StateError('Gagal baca piksel');
      if (!mounted) {
        img.dispose();
        return;
      }
      _image?.dispose();
      setState(() {
        _image = img;
        _rgba = rgba;
        _loading = false;
        _undoStack.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal memuat gambar. Periksa koneksi / URL staging.';
      });
    }
  }

  void _pushUndo() {
    final current = _rgba;
    if (current == null) return;
    _undoStack.add(
      ByteData.view(Uint8List.fromList(current.buffer.asUint8List()).buffer),
    );
    if (_undoStack.length > 30) {
      _undoStack.removeAt(0);
    }
  }

  Future<void> _undo() async {
    if (_undoStack.isEmpty || _image == null) return;
    final prev = _undoStack.removeLast();
    final img = await _imageFromRgba(prev, _image!.width, _image!.height);
    if (!mounted) {
      img.dispose();
      return;
    }
    _image?.dispose();
    setState(() {
      _rgba = prev;
      _image = img;
    });
  }

  Future<ui.Image> _imageFromRgba(ByteData rgba, int w, int h) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba.buffer.asUint8List(),
      w,
      h,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  Future<void> _applyBrush(Offset local, Size displaySize) async {
    final img = _image;
    final rgba = _rgba;
    if (img == null || rgba == null || _busy) return;

    final sx = img.width / displaySize.width;
    final sy = img.height / displaySize.height;
    final cx = (local.dx * sx).round().clamp(0, img.width - 1);
    final cy = (local.dy * sy).round().clamp(0, img.height - 1);
    final radius = (_brushRadius * ((sx + sy) / 2)).round().clamp(4, 120);

    _pushUndo();
    _stamp(rgba, img.width, img.height, cx, cy, radius, _mode);
    final next = await _imageFromRgba(rgba, img.width, img.height);
    if (!mounted) {
      next.dispose();
      return;
    }
    img.dispose();
    setState(() {
      _image = next;
      _rgba = rgba;
    });
  }

  void _stamp(
    ByteData data,
    int width,
    int height,
    int cx,
    int cy,
    int radius,
    DiscussionCensorBrushMode mode,
  ) {
    final r2 = radius * radius;
    final block = mode == DiscussionCensorBrushMode.pixelate
        ? (radius ~/ 3).clamp(4, 24)
        : mode == DiscussionCensorBrushMode.blur
            ? (radius ~/ 4).clamp(3, 16)
            : 1;

    for (var y = cy - radius; y <= cy + radius; y++) {
      if (y < 0 || y >= height) continue;
      for (var x = cx - radius; x <= cx + radius; x++) {
        if (x < 0 || x >= width) continue;
        final dx = x - cx;
        final dy = y - cy;
        if (dx * dx + dy * dy > r2) continue;

        if (mode == DiscussionCensorBrushMode.block) {
          final i = (y * width + x) * 4;
          data.setUint8(i, 26);
          data.setUint8(i + 1, 26);
          data.setUint8(i + 2, 26);
          data.setUint8(i + 3, 255);
          continue;
        }

        final bx = (x ~/ block) * block;
        final by = (y ~/ block) * block;
        var sumR = 0, sumG = 0, sumB = 0, count = 0;
        for (var yy = by; yy < by + block && yy < height; yy++) {
          for (var xx = bx; xx < bx + block && xx < width; xx++) {
            final j = (yy * width + xx) * 4;
            sumR += data.getUint8(j);
            sumG += data.getUint8(j + 1);
            sumB += data.getUint8(j + 2);
            count++;
          }
        }
        if (count == 0) continue;
        final i = (y * width + x) * 4;
        data.setUint8(i, sumR ~/ count);
        data.setUint8(i + 1, sumG ~/ count);
        data.setUint8(i + 2, sumB ~/ count);
      }
    }
  }

  Future<void> _export() async {
    final img = _image;
    if (img == null || _busy) return;
    setState(() => _busy = true);
    try {
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) throw StateError('Export gagal');
      final bytes = bd.buffer.asUint8List();
      if (!mounted) return;
      widget.onApply(bytes);
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: const Text('Gagal menyimpan hasil sensor'),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Sensor gambar'),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop(false)),
        ],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.undo2),
            onPress: _undoStack.isEmpty || _busy ? null : () => _undo(),
          ),
        ],
      ),
      child: _loading
          ? const Center(child: FCircularProgress())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const Gap(12),
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: _load,
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Geser jari untuk menyensor. Mode: pixelate, blur, atau blok.',
                      style: theme.typography.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final mode in DiscussionCensorBrushMode.values)
                          FButton(
                            variant: _mode == mode
                                ? FButtonVariant.primary
                                : FButtonVariant.outline,
                            onPress: () => setState(() => _mode = mode),
                            child: Text(switch (mode) {
                              DiscussionCensorBrushMode.pixelate => 'Pixelate',
                              DiscussionCensorBrushMode.blur => 'Blur',
                              DiscussionCensorBrushMode.block => 'Blok',
                            }),
                          ),
                      ],
                    ),
                    const Gap(8),
                    Text(
                      'Ukuran kuas',
                      style: theme.typography.sm,
                    ),
                    Slider(
                      value: _brushRadius,
                      min: 12,
                      max: 64,
                      onChanged: (v) => setState(() => _brushRadius = v),
                    ),
                    const Gap(8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final img = _image!;
                          final maxW = constraints.maxWidth;
                          final maxH = constraints.maxHeight;
                          final scale = (maxW / img.width < maxH / img.height)
                              ? maxW / img.width
                              : maxH / img.height;
                          final w = img.width * scale;
                          final h = img.height * scale;
                          return Center(
                            child: SizedBox(
                              width: w,
                              height: h,
                              child: GestureDetector(
                                onPanStart: (d) => _applyBrush(
                                  d.localPosition,
                                  Size(w, h),
                                ),
                                onPanUpdate: (d) => _applyBrush(
                                  d.localPosition,
                                  Size(w, h),
                                ),
                                child: RawImage(
                                  image: img,
                                  fit: BoxFit.fill,
                                  width: w,
                                  height: h,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const Gap(12),
                    FButton(
                      onPress: _busy ? null : _export,
                      child: _busy
                          ? const FCircularProgress()
                          : const Text('Terapkan sensor'),
                    ),
                    const Gap(8),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: _busy
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: const Text('Batal'),
                    ),
                  ],
                ),
    );
  }
}
