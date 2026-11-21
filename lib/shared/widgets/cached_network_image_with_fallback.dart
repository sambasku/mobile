import 'dart:async';

import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/utils/display_image_url.dart';
import 'image_placeholder_256.dart';

/// Batas tunggu per URL. Lewat = anggap gagal, pindah ke fallback berikutnya.
/// Tanpa ini, wsrv.nl / jsDelivr yang menggantung (foto baru belum ter-purge)
/// meninggalkan [Skeletonizer] placeholder selamanya.
const _imageLoadTimeout = Duration(seconds: 8);

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
    this.expand = true,
  });

  final String imageUrl;
  /// URL sekunder (mis. jsDelivr mentah) jika [imageUrl] (wsrv) gagal.
  final String? fallbackUrl;
  final Widget fallback;
  final BoxFit fit;
  final Alignment alignment;

  /// True (default): lebar & tinggi penuh parent - konteks beruas tetap
  /// (SizedBox.expand, carousel). False: ukuran natural, dibatasi parent -
  /// konten flow (mis. gambar di body markdown).
  final bool expand;

  @override
  State<CachedNetworkImageWithFallback> createState() =>
      _CachedNetworkImageWithFallbackState();
}

class _CachedNetworkImageWithFallbackState
    extends State<CachedNetworkImageWithFallback> {
  late List<String> _candidates;
  var _index = 0;
  Timer? _timeout;

  String get _activeUrl =>
      _index < _candidates.length ? _candidates[_index] : '';

  @override
  void initState() {
    super.initState();
    _candidates = _buildCandidates(widget.imageUrl, widget.fallbackUrl);
    _armTimeout();
  }

  @override
  void didUpdateWidget(covariant CachedNetworkImageWithFallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.fallbackUrl != widget.fallbackUrl) {
      _timeout?.cancel();
      _candidates = _buildCandidates(widget.imageUrl, widget.fallbackUrl);
      _index = 0;
      _armTimeout();
    }
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  /// Urutan: primary → fallback eksplisit → raw.githubusercontent (jsDelivr).
  List<String> _buildCandidates(String primary, String? fallback) {
    final out = <String>[];
    void add(String? url) {
      if (url == null || url.isEmpty) return;
      if (!out.contains(url)) out.add(url);
    }

    add(primary);
    add(fallback);
    add(jsDelivrToRawGithubUrl(primary));
    add(jsDelivrToRawGithubUrl(fallback));
    // Origin di query wsrv (`?url=cdn.jsdelivr.net/gh/...`) juga bisa jadi raw.
    final wsrvOrigin = _jsDelivrOriginFromWsrv(primary);
    add(wsrvOrigin);
    add(jsDelivrToRawGithubUrl(wsrvOrigin));
    return out;
  }

  /// Ekstrak origin jsDelivr dari URL wsrv.nl `?url=cdn.jsdelivr.net/...`.
  String? _jsDelivrOriginFromWsrv(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.toLowerCase() != 'wsrv.nl') return null;
    final raw = uri.queryParameters['url'];
    if (raw == null || raw.isEmpty) return null;
    final withScheme = raw.startsWith('http') ? raw : 'https://$raw';
    return withScheme;
  }

  void _armTimeout() {
    _timeout?.cancel();
    if (_activeUrl.isEmpty) return;
    _timeout = Timer(_imageLoadTimeout, () {
      if (!mounted) return;
      _advance();
    });
  }

  void _advance() {
    if (_index + 1 >= _candidates.length) {
      // Habis kandidat: paksa rebuild ke widget.fallback lewat index di luar.
      if (_index < _candidates.length) {
        setState(() => _index = _candidates.length);
      }
      _timeout?.cancel();
      return;
    }
    setState(() => _index += 1);
    _armTimeout();
  }

  Widget _errorChild() {
    if (_index + 1 < _candidates.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _advance();
      });
      return _slot(const Skeletonizer(child: Bone()));
    }
    return _slot(widget.fallback);
  }

  void _onLoaded() {
    _timeout?.cancel();
  }

  /// Placeholder/fallback sering `height: infinity` atau Bone expand.
  /// Di flow markdown (ListView, tinggi unbounded) itu harus dibatasi.
  Widget _slot(Widget child) {
    if (widget.expand) return child;
    return AspectRatio(aspectRatio: 16 / 9, child: child);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeUrl.isEmpty) {
      return _slot(widget.fallback);
    }

    if (isSvgNetworkUrl(_activeUrl)) {
      return SvgPicture.network(
        _activeUrl,
        fit: BoxFit.contain,
        width: widget.expand ? double.infinity : null,
        height: widget.expand ? double.infinity : null,
        placeholderBuilder: (_) => _slot(const Skeletonizer(child: Bone())),
        errorBuilder: (_, _, _) => _errorChild(),
      );
    }

    return CachedNetworkImage(
      imageUrl: _activeUrl,
      fit: widget.fit,
      alignment: widget.alignment,
      width: widget.expand ? double.infinity : null,
      height: widget.expand ? double.infinity : null,
      placeholder: (_, _) => _slot(const Skeletonizer(child: Bone())),
      // imageBuilder = frame sudah jadi. Batalkan timeout di frame
      // berikutnya (jangan side-effect langsung di build).
      imageBuilder: (context, imageProvider) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _onLoaded();
        });
        return Image(
          image: imageProvider,
          fit: widget.fit,
          alignment: widget.alignment,
          width: widget.expand ? double.infinity : null,
          height: widget.expand ? double.infinity : null,
        );
      },
      errorBuilder: (_, _, _) => _errorChild(),
    );
  }
}
