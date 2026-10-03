import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/sambas_map_config.dart';
import 'explore_map_poster.dart';

/// MapLibre view fokus Sambas - hero (gesture off) atau fullscreen (gesture on).
///
/// Style mengikuti tema (Liberty / Dark). Selama belum tampil, poster mode
/// loading menutupi map lalu fade out. Gagal load → [ExploreMapPoster].
class SambasMapView extends StatefulWidget {
  const SambasMapView({
    super.key,
    required this.initialCameraPosition,
    this.interactive = true,
    this.onMapClick,
    this.onMapCreated,
    this.onStyleLoaded,
    this.onCameraMove,
    this.annotationOrder = const [],
    this.onFallbackTap,
    this.analyticsEntry = 'category',
  });

  final CameraPosition initialCameraPosition;
  final bool interactive;
  final OnMapClickCallback? onMapClick;
  final MapCreatedCallback? onMapCreated;

  /// Terpanggil tiap kamera bergerak (pan/zoom/rotate oleh user).
  final OnCameraMoveCallback? onCameraMove;

  /// Annotation (addSymbol dst.) hanya aman setelah ini terpanggil.
  final VoidCallback? onStyleLoaded;

  /// Kosong = semua annotation mati (hemat untuk peta tanpa pin).
  final List<AnnotationType> annotationOrder;

  /// Dipakai poster fallback (biasanya buka Peta & Akses).
  final VoidCallback? onFallbackTap;

  /// Param `entry` untuk `map_open` / `map_fallback_shown`.
  final String analyticsEntry;

  @override
  State<SambasMapView> createState() => _SambasMapViewState();
}

class _SambasMapViewState extends State<SambasMapView> {
  static const _loadTimeout = Duration(seconds: 12);
  static const _fadeDuration = Duration(milliseconds: 250);

  bool _usePoster = false;
  Timer? _timeout;
  bool _styleReady = false;

  /// Tiles viewport sudah tergambar (idle pertama) - placeholder boleh hilang.
  bool _mapReady = false;
  Brightness? _lastBrightness;

  @override
  void initState() {
    super.initState();
    _armTimeout();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    if (_lastBrightness != null &&
        _lastBrightness != brightness &&
        !_usePoster) {
      // Style di-remount lewat ValueKey; tampilkan placeholder lagi.
      _styleReady = false;
      _mapReady = false;
      _armTimeout();
    }
    _lastBrightness = brightness;
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  void _armTimeout() {
    _timeout?.cancel();
    _timeout = Timer(_loadTimeout, () {
      if (!mounted || _mapReady || _usePoster) return;
      if (_styleReady) {
        // Style ada tapi idle tidak pernah datang (tiles lambat sebagian):
        // buka map apa adanya daripada placeholder menggantung.
        _markReady();
        return;
      }
      _showPoster('offline');
    });
  }

  void _showPoster(String reason) {
    _timeout?.cancel();
    if (_usePoster) return;
    setState(() {
      _usePoster = true;
    });
    unawaited(AnalyticsService.instance.logMapFallback(reason: reason));
  }

  void _onStyleLoaded() {
    _styleReady = true;
    widget.onStyleLoaded?.call();
  }

  void _markReady() {
    _timeout?.cancel();
    if (!mounted || _mapReady) return;
    setState(() => _mapReady = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_usePoster) {
      return ExploreMapPoster(
        onTap: widget.onFallbackTap,
        compact: !widget.interactive,
      );
    }

    final brightness = Theme.of(context).brightness;
    final styleUrl = SambasMapConfig.styleUrlFor(brightness);

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMap(styleUrl, brightness),
        IgnorePointer(
          ignoring: _mapReady,
          child: AnimatedOpacity(
            opacity: _mapReady ? 0 : 1,
            duration: _fadeDuration,
            curve: Curves.easeOut,
            child: ExploreMapPoster(
              compact: !widget.interactive,
              loading: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMap(String styleUrl, Brightness brightness) {
    return MapLibreMap(
      key: ValueKey('sambas-map-$styleUrl'),
      styleString: styleUrl,
      initialCameraPosition: widget.initialCameraPosition,
      onMapCreated: (controller) {
        widget.onMapCreated?.call(controller);
      },
      onStyleLoadedCallback: _onStyleLoaded,
      // Style loaded terpicu sebelum tiles tampil; idle = viewport tergambar.
      onMapIdle: _markReady,
      onMapClick: widget.onMapClick,
      onCameraMove: widget.onCameraMove,
      compassEnabled: widget.interactive,
      rotateGesturesEnabled: widget.interactive,
      scrollGesturesEnabled: widget.interactive,
      zoomGesturesEnabled: widget.interactive,
      tiltGesturesEnabled: widget.interactive,
      doubleClickZoomEnabled: widget.interactive,
      dragEnabled: widget.interactive,
      myLocationEnabled: false,
      logoEnabled: false,
      attributionButtonPosition: AttributionButtonPosition.bottomLeft,
      attributionButtonMargins: const math.Point(8, 8),
      annotationOrder: widget.annotationOrder,
      foregroundLoadColor: ExploreMapPoster.baseColor(brightness),
    );
  }
}
