import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/place.dart';
import '../../domain/sambas_map_config.dart';
import '../../explore_router.dart';
import '../place_ui.dart';
import 'sambas_map_view.dart';

/// Peta dengan pin semua Place. Pin ketuk → detail Place (entry: pin).
///
/// Kamera dipulihkan lintas sesi (SharedPreferences, debounce 500 ms) dan
/// saat remount ganti tema. Gagal load map → poster fallback otomatis
/// (di SambasMapView).
class SambasMapPins extends StatefulWidget {
  const SambasMapPins({
    super.key,
    required this.places,
    this.initialPlace,
    this.onRetryMap,
  });

  final List<Place> places;
  final Place? initialPlace;

  /// Poster fallback diketuk (peta gagal dimuat) = muat ulang peta.
  final VoidCallback? onRetryMap;

  @override
  State<SambasMapPins> createState() => _SambasMapPinsState();
}

class _SambasMapPinsState extends State<SambasMapPins>
    with SingleTickerProviderStateMixin {
  /// Hanya tempat berkoordinat yang bisa jadi pin (Place.lat nullable).
  List<Place> get _mappablePlaces =>
      widget.places.where((p) => p.hasCoordinates).toList();

  MapLibreMapController? _controller;
  bool _symbolsAdded = false;
  Set<String> _addedSlugs = {};

  /// Kamera terakhir yang dipindahkan user; dipulihkan setelah map di-remount
  /// (ganti tema). Null = pakai posisi awal dari widget. Juga di-persist ke
  /// SharedPreferences (debounce) supaya app dibunuh sistem tetap pulih.
  CameraPosition? _lastCamera;
  SharedPreferences? _prefs;
  Timer? _cameraSaveDebounce;

  /// Denyut halo tempat yang dibuka. Ticker berhenti sendiri saat route
  /// tertutup halaman lain (TickerMode).
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  Circle? _pulseRing;
  bool _pulseBusy = false;

  @override
  void initState() {
    super.initState();
    _pulse.addListener(_onPulseTick);
    _loadSavedCamera();
  }

  Future<void> _loadSavedCamera() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      _prefs = prefs;
      _lastCamera ??= decodeMapCamera(prefs.getString(pinsCameraPrefKey));
    } catch (_) {
      // Prefs gagal (jarang): kamera pakai default. Jangan gagalkan peta.
    }
    if (mounted) setState(() {});
  }

  /// ponytail: simpan debounce 500 ms; kalau app dibunuh dalam 500 ms setelah
  /// gerakan terakhir, posisi terakhir yang hilang (restore tetap masuk akal).
  void _persistCamera(CameraPosition pos) {
    final prefs = _prefs;
    if (prefs == null) return;
    _cameraSaveDebounce?.cancel();
    _cameraSaveDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(prefs.setString(pinsCameraPrefKey, encodeMapCamera(pos)));
    });
  }

  @override
  void dispose() {
    _cameraSaveDebounce?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _onMapCreated(MapLibreMapController controller) {
    // Ganti tema = map baru (key style beda): pin wajib dipasang ulang.
    _pulse.stop();
    _pulseRing = null;
    _controller = controller;
    _symbolsAdded = false;
    controller.onFeatureTapped.add(_onFeatureTapped);
  }

  // ponytail: updateCircle mengirim ulang semua lingkaran tiap frame; frame
  // dilewati selama kiriman sebelumnya belum selesai. Aman untuk puluhan pin.
  // Ratusan pin: pindah ke layer style sendiri + setLayerProperties.
  Future<void> _onPulseTick() async {
    final controller = _controller;
    final ring = _pulseRing;
    if (controller == null || ring == null || _pulseBusy) return;
    _pulseBusy = true;
    final t = _pulse.value;
    try {
      await controller.updateCircle(
        ring,
        CircleOptions(
          circleRadius: 9 + 22 * Curves.easeOut.transform(t),
          circleOpacity: 0.45 * (1 - t),
        ),
      );
    } catch (_) {
      // Map sudah di-dispose di tengah frame (keluar halaman / ganti tema).
      // AnimationController ikut di-dispose saat keluar halaman.
      if (mounted) _pulse.stop();
    } finally {
      _pulseBusy = false;
    }
  }

  @override
  void didUpdateWidget(SambasMapPins oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Data ter-refresh saat peta terbuka (pull-to-refresh / tombol reload):
    // slug sama -> update pin di tempat; slug berubah -> pasang ulang semua.
    if (_symbolsAdded &&
        !setEquals(_addedSlugs, {..._mappablePlaces.map((p) => p.slug)})) {
      _symbolsAdded = false;
      _pulse.stop();
      _pulseRing = null;
      unawaited(_rebuildPins());
    }
  }

  Future<void> _rebuildPins() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.clearCircles();
      await controller.clearSymbols();
    } catch (_) {
      return; // Map sudah dibuang; remount berikutnya pasang ulang sendiri.
    }
    await _addPins();
  }

  Future<void> _addPins() async {
    final controller = _controller;
    if (controller == null || _symbolsAdded || _mappablePlaces.isEmpty) return;
    _symbolsAdded = true;
    _addedSlugs = {..._mappablePlaces.map((p) => p.slug)};

    final colors = context.theme.colors;
    String hex(Color c) =>
        '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

    final focusId = widget.initialPlace?.id;
    final focus = _mappablePlaces.where((p) => p.id == focusId);
    final others = _mappablePlaces.where((p) => p.id != focusId);

    // Titik lingkaran = marker tanpa aset gambar; symbol cuma label nama.
    // Tempat yang dibuka: halo berdenyut + titik primary besar. Lainnya: titik
    // abu kecil.
    // ponytail: label tidak ikut collision dengan lingkaran (layer beda), jadi
    // tempat yang sangat berdekatan bisa tetap tertimpa label. Upgrade: ganti
    // lingkaran jadi icon symbol (addImage) supaya MapLibre yang mengatur.
    final circles = await controller.addCircles([
      for (final p in focus)
        CircleOptions(
          geometry: LatLng(p.lat!, p.lng!),
          circleRadius: 20,
          circleColor: hex(colors.primary),
          circleOpacity: 0.2,
        ),
      for (final p in others)
        CircleOptions(
          geometry: LatLng(p.lat!, p.lng!),
          circleRadius: 6,
          circleColor: hex(colors.mutedForeground),
          circleStrokeWidth: 2,
          circleStrokeColor: '#FFFFFF',
        ),
      for (final p in focus)
        CircleOptions(
          geometry: LatLng(p.lat!, p.lng!),
          circleRadius: 9,
          circleColor: hex(colors.primary),
          circleStrokeWidth: 3,
          circleStrokeColor: '#FFFFFF',
        ),
    ]);
    // Halo statis (radius 20) tetap dipakai kalau user mematikan animasi.
    if (focus.isNotEmpty &&
        mounted &&
        !MediaQuery.disableAnimationsOf(context)) {
      _pulseRing = circles.first;
      _pulse.repeat();
    }
    // zIndex = symbol-sort-key: makin kecil makin diprioritaskan, jadi label
    // tempat yang dibuka menang saat bertabrakan dengan label lain.
    await controller.addSymbols([
      for (final p in focus)
        SymbolOptions(
          geometry: LatLng(p.lat!, p.lng!),
          textField: p.name,
          textSize: 14,
          textOffset: const Offset(0, 1.6),
          textAnchor: 'top',
          textColor: hex(colors.foreground),
          textHaloColor: hex(colors.background),
          textHaloWidth: 2,
          zIndex: 0,
        ),
      for (final p in others)
        SymbolOptions(
          geometry: LatLng(p.lat!, p.lng!),
          textField: p.name,
          textSize: 11,
          textOffset: const Offset(0, 1.1),
          textAnchor: 'top',
          textColor: hex(colors.mutedForeground),
          textHaloColor: hex(colors.background),
          textHaloWidth: 1.5,
          zIndex: 1,
        ),
    ]);
  }

  void _onFeatureTapped(
    math.Point<double> point,
    LatLng latLng,
    String id,
    String layerId,
    dynamic annotation,
  ) {
    // Cari place terdekat dari titik tap (pin yang diketuk).
    Place? hit;
    double? best;
    for (final p in _mappablePlaces) {
      final d =
          (p.lat! - latLng.latitude).abs() +
          (p.lng! - latLng.longitude).abs();
      if (best == null || d < best) {
        best = d;
        hit = p;
      }
    }
    if (hit == null || best == null || best > 0.01) return;
    if (!mounted) return;
    // Pin tempat yang dibuka: peta ini datang dari detail-nya, cukup kembali
    // supaya stack tidak jadi detail → peta → detail → peta.
    if (hit.id == widget.initialPlace?.id && context.canPop()) {
      context.pop();
      return;
    }
    context.push(
      ExploreRouter.place.path.replaceFirst(':slug', hit.slug),
      extra: 'pin',
    );
  }

  @override
  Widget build(BuildContext context) {
    final initialCamera = widget.initialPlace?.hasCoordinates ?? false
        ? CameraPosition(
            target: LatLng(widget.initialPlace!.lat!, widget.initialPlace!.lng!),
            zoom: SambasMapConfig.placeZoom,
          )
        : SambasMapConfig.fullscreenCamera;
    return SambasMapView(
      // Peta dibuka untuk tempat lain: abaikan posisi tersimpan (dari sesi
      // tempat sebelumnya), mulai dari tempat yang diminta.
      initialCameraPosition: widget.initialPlace == null
          ? (_lastCamera ?? initialCamera)
          : initialCamera,
      interactive: true,
      analyticsEntry: 'pins',
      onMapCreated: _onMapCreated,
      // Kamera user dipantau terus; saat ganti tema map di-remount dan posisi
      // terakhir jadi initial camera map baru, plus dipersist ke prefs.
      onCameraMove: (pos) {
        _lastCamera = pos;
        _persistCamera(pos);
      },
      onStyleLoaded: _addPins,
      annotationOrder: const [AnnotationType.circle, AnnotationType.symbol],
      // Poster gagal muat diketuk = coba lagi (bikin instance map baru).
      onFallbackTap: widget.onRetryMap,
    );
  }
}
