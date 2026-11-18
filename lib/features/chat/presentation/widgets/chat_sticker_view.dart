import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/chat_models.dart';

/// Render stiker dari pack lokal. GIF diputar **sekali** lalu diam di
/// frame terakhir (hemat CPU vs loop Image.asset).
class ChatStickerView extends StatelessWidget {
  const ChatStickerView({
    super.key,
    required this.stickerId,
    this.size = 96,
  });

  final String stickerId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final sticker = chatStickerById(stickerId);
    if (sticker == null) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Text(stickerId, style: TextStyle(fontSize: size * 0.45)),
        ),
      );
    }
    if (sticker.playOnce) {
      return _OncePlayAssetImage(asset: sticker.asset, size: size);
    }
    return Image.asset(
      sticker.asset,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => SizedBox(
        width: size,
        height: size,
        child: const Icon(FLucideIcons.imageOff, size: 20),
      ),
    );
  }
}

class _OncePlayAssetImage extends StatefulWidget {
  const _OncePlayAssetImage({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  State<_OncePlayAssetImage> createState() => _OncePlayAssetImageState();
}

class _OncePlayAssetImageState extends State<_OncePlayAssetImage> {
  ui.Codec? _codec;
  ui.Image? _frame;
  var _disposed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_play());
  }

  @override
  void didUpdateWidget(covariant _OncePlayAssetImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) {
      unawaited(_play());
    }
  }

  Future<void> _play() async {
    _codec?.dispose();
    _codec = null;
    try {
      final data = await rootBundle.load(widget.asset);
      if (_disposed) return;
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: widget.size.round(),
        targetHeight: widget.size.round(),
      );
      if (_disposed) {
        codec.dispose();
        return;
      }
      _codec = codec;
      ui.Image? last;
      for (var i = 0; i < codec.frameCount; i++) {
        final info = await codec.getNextFrame();
        if (_disposed) {
          info.image.dispose();
          return;
        }
        last?.dispose();
        last = info.image;
        if (mounted) setState(() => _frame = last);
        final delay = info.duration;
        if (delay > Duration.zero && i < codec.frameCount - 1) {
          await Future<void>.delayed(delay);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _frame = null);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _frame?.dispose();
    _codec?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    if (frame == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return RawImage(
      image: frame,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
    );
  }
}
