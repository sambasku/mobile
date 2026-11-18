import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import 'sticker_models.dart';

/// Satu GIF `playOnce` aktif: claim baru menghentikan yang lama.
class StickerPlaybackGate {
  StickerPlaybackGate._();
  static final instance = StickerPlaybackGate._();

  final ValueNotifier<Object?> active = ValueNotifier<Object?>(null);

  void claim(Object token) {
    if (!identical(active.value, token)) {
      active.value = token;
    }
  }

  void release(Object token) {
    if (identical(active.value, token)) {
      active.value = null;
    }
  }

  bool isActive(Object token) => identical(active.value, token);
}

/// Render stiker dari URL katalog. GIF `playOnce` diputar sekali.
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
    if (sticker.playOnce) {
      return _OncePlayNetworkImage(url: sticker.imageUrl, size: size);
    }
    return Image.network(
      sticker.imageUrl,
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

class _OncePlayNetworkImage extends StatefulWidget {
  const _OncePlayNetworkImage({required this.url, required this.size});

  final String url;
  final double size;

  @override
  State<_OncePlayNetworkImage> createState() => _OncePlayNetworkImageState();
}

class _OncePlayNetworkImageState extends State<_OncePlayNetworkImage> {
  ui.Codec? _codec;
  ui.Image? _frame;
  var _disposed = false;
  var _playGen = 0;
  final _token = Object();

  @override
  void initState() {
    super.initState();
    StickerPlaybackGate.instance.active.addListener(_onActiveChanged);
    unawaited(_replay());
  }

  @override
  void didUpdateWidget(covariant _OncePlayNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      unawaited(_replay());
    }
  }

  void _onActiveChanged() {
    final active = StickerPlaybackGate.instance.active.value;
    if (active != null && !identical(active, _token)) {
      _playGen++;
    }
  }

  Future<void> _replay() async {
    final gen = ++_playGen;
    StickerPlaybackGate.instance.claim(_token);
    _codec?.dispose();
    _codec = null;

    try {
      final res = await Dio().get<List<int>>(
        widget.url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = res.data;
      if (_disposed ||
          gen != _playGen ||
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
      if (_disposed || gen != _playGen) {
        codec.dispose();
        return;
      }
      _codec = codec;

      ui.Image? last;
      for (var i = 0; i < codec.frameCount; i++) {
        if (_disposed || gen != _playGen) return;
        if (!StickerPlaybackGate.instance.isActive(_token)) return;

        final info = await codec.getNextFrame();
        if (_disposed || gen != _playGen) {
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
      if (mounted && gen == _playGen) setState(() => _frame = null);
    } finally {
      if (gen == _playGen) {
        StickerPlaybackGate.instance.release(_token);
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _playGen++;
    StickerPlaybackGate.instance.active.removeListener(_onActiveChanged);
    StickerPlaybackGate.instance.release(_token);
    _frame?.dispose();
    _codec?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => unawaited(_replay()),
        child: frame == null
            ? SizedBox(width: widget.size, height: widget.size)
            : RawImage(
                image: frame,
                width: widget.size,
                height: widget.size,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
