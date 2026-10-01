import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Latar video muted loop. Texture tidak ikut `RepaintBoundary.toImage`.
class ShareVideoLayer extends StatefulWidget {
  const ShareVideoLayer({
    super.key,
    required this.url,
    this.isFile = false,
    this.fallback,
    required this.gradient,
    this.alignment = Alignment.center,
  });

  final String url;
  final bool isFile;
  final ImageProvider? fallback;
  final List<Color> gradient;
  final Alignment alignment;

  @override
  State<ShareVideoLayer> createState() => _ShareVideoLayerState();
}

class _ShareVideoLayerState extends State<ShareVideoLayer> {
  VideoPlayerController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(ShareVideoLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.isFile != widget.isFile) {
      _disposeController();
      _init();
    }
  }

  Future<void> _init() async {
    final controller = widget.isFile
        ? VideoPlayerController.file(File(widget.url))
        : VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted) setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_error != null ||
        controller == null ||
        !controller.value.isInitialized) {
      if (widget.fallback != null) {
        return Image(
          image: widget.fallback!,
          fit: BoxFit.cover,
          alignment: widget.alignment,
          width: double.infinity,
          height: double.infinity,
        );
      }
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.gradient,
          ),
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      alignment: widget.alignment,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
