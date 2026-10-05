import 'package:cached_network_image_ce/cached_network_image_ce.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'image_placeholder_256.dart';

bool isSvgNetworkUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  return uri.path.toLowerCase().endsWith('.svg');
}

class CachedNetworkImageWithFallback extends StatefulWidget {
  const CachedNetworkImageWithFallback({
    super.key,
    required this.imageUrl,
    this.fallbackUrl,
    this.fallback = const ImagePlaceholder256(),
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final String imageUrl;
  /// URL sekunder (mis. jsDelivr mentah) jika [imageUrl] (wsrv) gagal.
  final String? fallbackUrl;
  final Widget fallback;
  final BoxFit fit;
  final Alignment alignment;

  @override
  State<CachedNetworkImageWithFallback> createState() =>
      _CachedNetworkImageWithFallbackState();
}

class _CachedNetworkImageWithFallbackState
    extends State<CachedNetworkImageWithFallback> {
  late String _activeUrl;
  var _triedFallback = false;

  @override
  void initState() {
    super.initState();
    _activeUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(covariant CachedNetworkImageWithFallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackUrl != widget.fallbackUrl) {
      _activeUrl = widget.imageUrl;
      _triedFallback = false;
    }
  }

  void _switchToFallback() {
    final next = widget.fallbackUrl;
    if (_triedFallback || next == null || next.isEmpty || next == _activeUrl) {
      return;
    }
    setState(() {
      _triedFallback = true;
      _activeUrl = next;
    });
  }

  Widget _errorChild() {
    final next = widget.fallbackUrl;
    if (!_triedFallback &&
        next != null &&
        next.isNotEmpty &&
        next != _activeUrl) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _switchToFallback();
      });
      return const Skeletonizer(child: Bone());
    }
    return widget.fallback;
  }

  @override
  Widget build(BuildContext context) {
    if (_activeUrl.isEmpty) {
      return widget.fallback;
    }

    if (isSvgNetworkUrl(_activeUrl)) {
      return SvgPicture.network(
        _activeUrl,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholderBuilder: (_) => const Skeletonizer(child: Bone()),
        errorBuilder: (_, _, _) => _errorChild(),
      );
    }

    return CachedNetworkImage(
      imageUrl: _activeUrl,
      fit: widget.fit,
      alignment: widget.alignment,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, _) => const Skeletonizer(child: Bone()),
      errorWidget: (_, _, _) => _errorChild(),
    );
  }
}
