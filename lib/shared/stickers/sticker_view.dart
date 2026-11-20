import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import 'sticker_models.dart';

/// Render stiker dari URL katalog.
/// GIF di **area baca** (viewport) auto-gerak; di luar viewport diam (hemat CPU).
class CatalogStickerView extends StatelessWidget {
  const CatalogStickerView({
    super.key,
    required this.sticker,
    this.size = 96,
  });

  final CatalogSticker sticker;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (sticker.imageUrl.isEmpty) {
      return _Placeholder(id: sticker.id, size: size);
    }
    return _ViewportAwareGif(
      url: sticker.imageUrl,
      size: size,
    );
  }
}

/// Unknown id / fetch gagal: tampilkan slug, jangan crash.
class StickerIdView extends StatelessWidget {
  const StickerIdView({
    super.key,
    required this.stickerId,
    this.sticker,
    this.size = 96,
  });

  final String stickerId;
  final CatalogSticker? sticker;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = sticker;
    if (s == null) {
      return _Placeholder(id: stickerId, size: size);
    }
    return CatalogStickerView(sticker: s, size: size);
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.id, required this.size});

  final String id;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(id, style: TextStyle(fontSize: size * 0.28)),
      ),
    );
  }
}

/// GIF: animate saat overlap viewport; diam saat keluar area baca.
class _ViewportAwareGif extends StatefulWidget {
  const _ViewportAwareGif({
    required this.url,
    required this.size,
  });

  final String url;
  final double size;

  @override
  State<_ViewportAwareGif> createState() => _ViewportAwareGifState();
}

class _ViewportAwareGifState extends State<_ViewportAwareGif> {
  var _visible = false;
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _detachScroll();
    final scrollable = Scrollable.maybeOf(context);
    _position = scrollable?.position;
    _position?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisible());
  }

  @override
  void dispose() {
    _detachScroll();
    super.dispose();
  }

  void _detachScroll() {
    _position?.removeListener(_onScroll);
    _position = null;
  }

  void _onScroll() => _checkVisible();

  void _checkVisible() {
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) {
      _setVisible(false);
      return;
    }
    final rect = box.localToGlobal(Offset.zero) & box.size;
    final screen = Offset.zero & MediaQuery.sizeOf(context);
    // Sedikit overlap cukup dianggap "area baca".
    _setVisible(rect.overlaps(screen));
  }

  void _setVisible(bool next) {
    if (_visible == next) return;
    setState(() => _visible = next);
  }

  @override
  Widget build(BuildContext context) {
    // Di luar area baca: frame diam. Di dalam: GIF auto-loop (Image.network).
    // playOnce: tap untuk replay sekali via overlay gesture (gate).
    if (!_visible) {
      return _StaticNetworkFrame(url: widget.url, size: widget.size);
    }
    return Image.network(
      widget.url,
      width: widget.size,
      height: widget.size,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Icon(FLucideIcons.imageOff, size: 20),
      ),
    );
  }
}

/// Frame diam: hanya frame pertama GIF (di luar viewport tidak gerak).
class _StaticNetworkFrame extends StatefulWidget {
  const _StaticNetworkFrame({required this.url, required this.size});

  final String url;
  final double size;

  @override
  State<_StaticNetworkFrame> createState() => _StaticNetworkFrameState();
}

class _StaticNetworkFrameState extends State<_StaticNetworkFrame> {
  ui.Image? _frame;
  var _disposed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadFirstFrame());
  }

  @override
  void didUpdateWidget(covariant _StaticNetworkFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.size != widget.size) {
      unawaited(_loadFirstFrame());
    }
  }

  Future<void> _loadFirstFrame() async {
    try {
      final res = await Dio().get<List<int>>(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = res.data;
      if (_disposed ||
          bytes == null ||
          (res.statusCode ?? 0) < 200 ||
          (res.statusCode ?? 0) >= 300) {
        return;
      }
      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(bytes),
        targetWidth: widget.size.round(),
        targetHeight: widget.size.round(),
      );
      final info = await codec.getNextFrame();
      codec.dispose();
      if (_disposed) {
        info.image.dispose();
        return;
      }
      _frame?.dispose();
      if (mounted) setState(() => _frame = info.image);
    } catch (_) {
      if (mounted && !_disposed) setState(() => _frame = null);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _frame?.dispose();
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
