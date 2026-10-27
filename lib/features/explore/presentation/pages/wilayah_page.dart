import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart' show rootBundle, HapticFeedback;
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../../shared/widgets/floating_overlay_icon_button.dart';
import '../../../../shared/widgets/small_button.dart';
import '../../../event/presentation/providers/event_browse_providers.dart';
import '../../../event/presentation/widgets/event_ui.dart';
import '../../../usaha/domain/entities/usaha.dart';
import '../../../usaha/presentation/providers/usaha_browse_providers.dart';
import '../../../usaha/usaha_router.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/region.dart';
import '../../domain/region_geometry.dart';
import '../../domain/sambas_map_config.dart';
import '../../explore_router.dart';
import '../providers/places_providers.dart';
import '../providers/regions_providers.dart';
import '../widgets/sambas_map_view.dart';

/// Halaman Wilayah: peta polygon 19 kecamatan, tap -> panel nama + jumlah
/// desa + daftar desa. Polygon dari assets (offline aman), daftar wilayah
/// dari CDN (soft-fail). ADM4 (desa) polygon di-load on-demand per kecamatan.
class WilayahPage extends ConsumerStatefulWidget {
  const WilayahPage({super.key, this.initialKecSlug});

  /// Kecamatan slug yang langsung terpilih saat halaman dibuka
  /// (dari link lintas halaman), null = tanpa seleksi awal.
  final String? initialKecSlug;

  @override
  ConsumerState<WilayahPage> createState() => _WilayahPageState();
}

class _WilayahPageState extends ConsumerState<WilayahPage> {
  static const _kecSourceId = 'regions-kecamatan';
  static const _kecFillLayerId = 'regions-fill';
  static const _kecLineLayerId = 'regions-line';
  static const _kecLabelLayerId = 'regions-label';
  static const _desaSourceId = 'regions-desa';
  static const _desaFillLayerId = 'desa-fill';
  static const _desaLineLayerId = 'desa-line';
  static const _desaLabelLayerId = 'desa-label';
  static const _fillColorBase = '#e2b25c';
  static const _fillColorSelected = '#f59e0b';
  static const _desaFillColor = '#3b82f6';
  static const _desaFillColorSelected = '#1d4ed8';

  /// Palet warna fill kecamatan - tiap polygon beda warna (interleave 8
  /// warna tanaman/sawah biar kecamatan bertetangga tidak senada).
  static const _kecPalette = [
    '#e2b25c',
    '#8fbc6f',
    '#c98a5e',
    '#7fa8c9',
    '#b58fc9',
    '#c96f7f',
    '#6fc9b0',
    '#c9c06f',
  ];

  MapLibreMapController? _controller;
  bool _kecLayersAdded = false;
  bool _desaLayersAdded = false;
  bool _styleReady = false;

  /// Ring luar per id kecamatan, dari geojson (cache setelah parse).
  final Map<String, List<List<List<double>>>> _kecRings = {};

  /// Ring luar per id desa, dari ADM4 geojson (load on-demand per kecamatan).
  final Map<String, List<List<List<double>>>> _desaRings = {};

  String? _selectedKecId;
  String? _selectedDesaId;

  /// Token urutan load ADM4: hasil request yang sudah tergantikan dibuang,
  /// sehingga polygon selalu milik kecamatan yang TERAKHIR dipilih (#106).
  int _desaLoadToken = 0;

  /// Hasil decode ADM4 (file besar): decode sekali, load & sync berbagi.
  Map<String, dynamic>? _adm4Cache;

  /// Asset ADM4 pernah gagal decode/korup: jangan retry tiap build
  /// (decode 67K per frame = jank loop). Hardening #106.
  bool _adm4Failed = false;

  /// Pilih desa dari hasil pencarian: set kecamatan induk + desa, buka
  /// panel desa, load polygon, kamera fokus ke centroid desa.
  Future<void> _pickSearchedDesa(Region desa, Region kec) async {
    setState(() {
      _selectedKecId = kec.id;
      _selectedDesaId = desa.id;
    });
    unawaited(_applyKecColors());
    if (_desaShownForKec != kec.id) {
      await _loadDesaGeoJson(kec.id);
    } else {
      await _applyDesaSelection();
    }
    // Fokus kamera ke centroid polygon desa (fallback: centroid kecamatan).
    final rings = _desaRings[desa.id];
    if (rings != null && rings.isNotEmpty && rings.first.isNotEmpty) {
      var latSum = 0.0, lngSum = 0.0;
      for (final p in rings.first) {
        lngSum += p[0];
        latSum += p[1];
      }
      final n = rings.first.length.toDouble();
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(latSum / n, lngSum / n),
          SambasMapConfig.placeZoom - 3.5,
        ),
      );
    }
    unawaited(AnalyticsService.instance.logWilayahDesaSelect(desaId: desa.id));
  }

  /// Slug kecamatan yang polygon desanya sedang tampil di peta.
  String? _desaShownForKec;

  /// Warna fill kecamatan: index palet stabil per posisi di _kecRings.
  String kecColor(String id) {
    final i = _kecRings.keys.toList().indexOf(id);
    return _kecPalette[i < 0 ? 0 : i % _kecPalette.length];
  }

  @override
  void initState() {
    super.initState();
    _selectedKecId = widget.initialKecSlug;
    _loadKecamatanGeoJson();
  }

  Future<void> _loadKecamatanGeoJson() async {
    try {
      _kecRings.addAll(await RegionGeometry.load());
      if (!mounted) return;
      setState(() {});
      await _maybeAddKecLayers();
    } catch (_) {
      // Asset hilang/korup (jarang): peta tetap jalan tanpa polygon.
    }
  }

  Future<void> _maybeAddKecLayers() async {
    final controller = _controller;
    // Style harus fully-loaded dulu: native skip diam-diam layer/source
    // kalau style belum siap (kartu hitam tanpa polygon).
    if (controller == null ||
        !_styleReady ||
        _kecRings.isEmpty ||
        _kecLayersAdded) {
      return;
    }
    _kecLayersAdded = true;
    try {
      final raw = await rootBundle.loadString('assets/data/regions.geojson');
      await controller.addGeoJsonSource(
        _kecSourceId,
        jsonDecode(raw) as Map<String, dynamic>,
      );
      await controller.addFillLayer(
        _kecSourceId,
        _kecFillLayerId,
        // Warna + opacity wajib dari add time: default fill-color MapLibre
        // hitam, jadi kalau _applyKecColors gagal polygon jangan sampai
        // tampil hitam pekat.
        const FillLayerProperties(fillColor: _fillColorBase, fillOpacity: 0.3),
        enableInteraction: false,
      );
      await controller.addLineLayer(
        _kecSourceId,
        _kecLineLayerId,
        const LineLayerProperties(lineColor: '#ffffff', lineWidth: 1.2),
        enableInteraction: false,
      );
      await _addKecLabelLayer();
      await _applyKecColors();
    } catch (_) {
      _kecLayersAdded = false;
    }
  }

  /// Label nama kecamatan: symbol layer dari point centroid per feature.
  /// Sumbernya geojson yang sama (MapLibre otomatis pakai centroid polygon).
  /// textFont wajib font yang di-serve OpenFreeMap ("Noto Sans Regular");
  /// default plugin ("Open Sans Regular") 404 -> label tidak muncul.
  Future<void> _addKecLabelLayer() async {
    final controller = _controller;
    if (controller == null || !_kecLayersAdded) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    try {
      await controller.addSymbolLayer(
        _kecSourceId,
        _kecLabelLayerId,
        SymbolLayerProperties(
          textField: ['get', 'name'],
          textFont: ['Noto Sans Regular'],
          textSize: 10,
          textColor: isDark ? '#f9fafb' : '#1f2937',
          textHaloColor: isDark ? '#111827' : '#ffffff',
          textHaloWidth: 1.2,
          textAllowOverlap: false,
        ),
        enableInteraction: false,
      );
    } catch (_) {
      // Symbol layer gagal (style belum siap dsb.): polygon tetap jalan.
    }
  }

  /// Load (atau ganti) desa polygons untuk kecamatan yang dipilih.
  Future<void> _loadDesaGeoJson(String kecSlug) async {
    if (_desaShownForKec == kecSlug) return;
    final token = ++_desaLoadToken;
    try {
      final geojson = await _loadAdm4();
      if (geojson == null) return;
      final rings = RegionGeometry.ringsFor(geojson, kecSlug);

      // Request lama sudah tergantikan (tap kecamatan cepat): jangan
      // menampilkan polygon yang sudah tak dipilih (#106).
      if (!mounted || token != _desaLoadToken) return;
      setState(() {
        _desaRings.clear();
        _desaRings.addAll(rings);
        _desaShownForKec = kecSlug;
      });
      await _syncDesaLayers(kecSlug, token);
    } catch (_) {
      // Asset hilang/korup: tampilkan list saja tanpa polygon desa.
    }
  }

  /// Decode ADM4 sekali - dipakai _loadDesaGeoJson & _syncDesaLayers.
  Future<Map<String, dynamic>?> _loadAdm4() async {
    if (_adm4Failed) return null;
    final cached = _adm4Cache;
    if (cached != null) return cached;
    try {
      final raw = await rootBundle.loadString(
        'assets/data/regions-adm4.geojson',
      );
      final geojson = jsonDecode(raw);
      if (geojson is! Map<String, dynamic>) {
        throw const FormatException('regions-adm4.geojson bukan object');
      }
      _adm4Cache = geojson;
      return geojson;
    } catch (_) {
      // Korup/hilang sekali = korup selamanya di sesi ini: list desa tetap
      // jalan tanpa polygon, tanpa decode ulang per build.
      _adm4Failed = true;
      return null;
    }
  }

  /// Ganti isi source desa: remove layer+source lama lalu add ulang bila
  /// ada ring untuk kecamatan ini. Aman dipanggil ulang (idempotent).
  Future<void> _syncDesaLayers(String kecSlug, int token) async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    try {
      // Hapus layer lama dulu (layer harus dibuang sebelum source).
      if (_desaLayersAdded) {
        try {
          await controller.removeLayer(_desaFillLayerId);
          await controller.removeLayer(_desaLineLayerId);
          await controller.removeLayer(_desaLabelLayerId);
        } catch (_) {}
        try {
          await controller.removeSource(_desaSourceId);
        } catch (_) {}
        _desaLayersAdded = false;
      }

      // Ganti request terjadi saat menunggu remove: berhenti - layer lama
      // sudah bersih dan sync terbaru yang akan mengisi (#106).
      if (token != _desaLoadToken) return;
      if (_desaRings.isEmpty) return;

      final geojson = await _loadAdm4();
      if (geojson == null || token != _desaLoadToken) return;
      final feats = geojson['features'];
      if (feats is! List) return;

      final filteredFeats = feats.where((f) {
        if (f is! Map || f['properties'] is! Map) return false;
        final props = f['properties'] as Map;
        return props['parentId'] == kecSlug;
      }).toList();
      if (filteredFeats.isEmpty) return;

      await controller.addGeoJsonSource(_desaSourceId, {
        'type': 'FeatureCollection',
        'features': filteredFeats,
      });
      await controller.addFillLayer(
        _desaSourceId,
        _desaFillLayerId,
        // Warna + opacity dari add time (default fill-color = hitam).
        const FillLayerProperties(fillColor: _desaFillColor, fillOpacity: 0.25),
        enableInteraction: false,
      );
      await controller.addLineLayer(
        _desaSourceId,
        _desaLineLayerId,
        const LineLayerProperties(lineColor: '#ffffff', lineWidth: 0.8),
        enableInteraction: false,
      );
      await controller.addSymbolLayer(
        _desaSourceId,
        _desaLabelLayerId,
        // Label nama desa di centroid tiap polygon. Font wajib font yang
        // di-serve OpenFreeMap (lihat komentar _addKecLabelLayer).
        SymbolLayerProperties(
          textField: ['get', 'name'],
          textFont: ['Noto Sans Regular'],
          textSize: 9,
          textColor: isDark ? '#f9fafb' : '#1f2937',
          textHaloColor: isDark ? '#111827' : '#ffffff',
          textHaloWidth: 1.1,
          textAllowOverlap: false,
        ),
        enableInteraction: false,
      );
      // Flag true hanya setelah semua layer sukses: gagal di tengah ->
      // outer catch membuang layer setengah jadi (#106).
      _desaLayersAdded = true;
      await _applyDesaSelection();
    } catch (_) {
      // Gagal di tengah: buang layer setengah jadi supaya state selalu
      // konsisten dengan peta (#106).
      try {
        await controller.removeLayer(_desaFillLayerId);
        await controller.removeLayer(_desaLineLayerId);
        await controller.removeLayer(_desaLabelLayerId);
      } catch (_) {}
      try {
        await controller.removeSource(_desaSourceId);
      } catch (_) {}
      _desaLayersAdded = false;
    }
  }

  /// Warna palet per kecamatan + highlight kuning untuk yang terpilih.
  Future<void> _applyKecColors() async {
    final controller = _controller;
    if (controller == null || !_kecLayersAdded) return;
    try {
      final entries = _kecRings.keys.toList();
      final match = [
        for (var i = 0; i < entries.length; i++)
          [
            '==',
            ['get', 'id'],
            entries[i],
          ],
      ];
      final colors = [
        for (var i = 0; i < entries.length; i++) kecColor(entries[i]),
      ];
      await controller.setLayerProperties(
        _kecFillLayerId,
        FillLayerProperties(
          fillOpacity: 0.3,
          fillColor: [
            'case',
            if (_selectedKecId != null) ...[
              [
                '==',
                ['get', 'id'],
                _selectedKecId,
              ],
              _fillColorSelected,
            ],
            // match/color bergantian: match0, color0, match1, color1, ...
            for (var i = 0; i < entries.length; i++) ...[match[i], colors[i]],
            _fillColorBase,
          ],
        ),
      );
    } catch (_) {}
  }

  /// Warna polygon desa terpilih.
  Future<void> _applyDesaSelection() async {
    final controller = _controller;
    if (controller == null || !_desaLayersAdded) return;
    try {
      await controller.setLayerProperties(
        _desaFillLayerId,
        FillLayerProperties(
          fillOpacity: 0.25,
          fillColor: _selectedDesaId == null
              ? _desaFillColor
              : [
                  'case',
                  [
                    '==',
                    ['get', 'id'],
                    _selectedDesaId,
                  ],
                  _desaFillColorSelected,
                  _desaFillColor,
                ],
        ),
      );
    } catch (_) {}
  }

  void _onTap(math.Point<double> _, LatLng latLng) {
    // Cek desa dulu jika layer desa aktif
    String? hit;
    if (_desaLayersAdded && _desaRings.isNotEmpty) {
      hit = RegionGeometry.hitTest(
        latLng.latitude,
        latLng.longitude,
        _desaRings,
      );
      if (hit != null) {
        if (hit == _selectedDesaId) return;
        setState(() => _selectedDesaId = hit);
        unawaited(_applyDesaSelection());
        unawaited(AnalyticsService.instance.logWilayahDesaSelect(desaId: hit));
        return;
      }
    }
    // Fallback ke kecamatan
    hit = RegionGeometry.hitTest(latLng.latitude, latLng.longitude, _kecRings);
    if (hit == _selectedKecId) return;
    if (hit != null) {
      unawaited(AnalyticsService.instance.logWilayahKecSelect(kecId: hit));
    }
    setState(() {
      _selectedKecId = hit;
      _selectedDesaId = null;
    });
    unawaited(_applyKecColors());
  }

  /// Buka bottomsheet modal (search + daftar desa + places). Modal menutup
  /// peta sementara; tinggi ikut isi (scroll), tutup via drag/barrier -
  /// kartu di peta tetap ringkas dan tak bisa memenuhi layar (#106).
  void _openDesaSheet() {
    final selected =
        (ref.read(regionsKecamatanProvider).value ?? const <Region>[])
            .where((k) => k.id == _selectedKecId)
            .firstOrNull;
    unawaited(
      showFSheet<void>(
        context: context,
        side: FLayout.btt,
        // null tanpa batas ratio: child scrollable -> sheet ikut isi
        // (pola forui untuk sheet berisi scrollable).
        mainAxisMaxRatio: null,
        builder: (context) => WilayahSheet(
          selected: selected,
          initialDesaId: _selectedDesaId,
          onPickSearchedDesa: _pickSearchedDesa,
          onDesaTap: (desa) {
            setState(() => _selectedDesaId = desa.id);
            unawaited(_applyDesaSelection());
            unawaited(
              AnalyticsService.instance.logWilayahDesaSelect(desaId: desa.id),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kecamatanAsync = ref.watch(regionsKecamatanProvider);
    final desaAsync = ref.watch(regionsProvider);
    final kecamatan = kecamatanAsync.value ?? const <Region>[];
    final selected = kecamatan.where((k) => k.id == _selectedKecId).firstOrNull;
    final desaOfSelected = selected == null
        ? const <Region>[]
        : (desaAsync.value ?? const <Region>[])
              .where((r) => r.parentId == selected.id)
              .toList();

    // Load / ganti desa polygons saat kecamatan berubah.
    if (selected != null && _desaShownForKec != selected.id) {
      _loadDesaGeoJson(selected.id);
    }

    return FScaffold(
      childPad: false,
      child: Stack(
        children: [
          // Peta full-bleed sampai belakang status bar.
          Positioned.fill(
            child: SambasMapView(
              initialCameraPosition: selected == null
                  ? CameraPosition(target: LatLng(1.5227, 109.3266), zoom: 8.6)
                  : CameraPosition(
                      target: LatLng(
                        selected.lat ?? 1.36,
                        selected.lng ?? 109.31,
                      ),
                      zoom: SambasMapConfig.kecamatanZoom,
                    ),
              onMapCreated: (c) {
                _controller = c;
                // Remount (ganti tema) = instance map baru: state layer
                // instance lama tidak berlaku, semua harus di-add ulang.
                _styleReady = false;
                _kecLayersAdded = false;
                _desaLayersAdded = false;
                _maybeAddKecLayers();
              },
              onStyleLoaded: () {
                _styleReady = true;
                _maybeAddKecLayers();
                // Desa yang tadi terbuka ikut di-add ulang di instance baru.
                final kec = _desaShownForKec;
                if (kec != null && _desaRings.isNotEmpty) {
                  unawaited(_syncDesaLayers(kec, _desaLoadToken));
                }
              },
              onMapClick: _onTap,
              analyticsEntry: 'wilayah',
            ),
          ),
          // Kolom kiri: back + toggle tema (layout sama dengan pins_page -
          // kompas MapLibre di kanan atas, jadi aksi mengambang di kiri).
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            child: Column(
              children: [
                IconButton(
                  tooltip: AppLocalizations.of(context).commonBack,
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/explore'),
                  style: floatingOverlayIconButtonStyle(context),
                  icon: const Icon(FLucideIcons.arrowLeft, size: 20),
                ),
                const SizedBox(height: 8),
                IconButton(
                  tooltip: Theme.of(context).brightness == Brightness.dark
                      ? AppLocalizations.of(context).exploreMapToggleLight
                      : AppLocalizations.of(context).exploreMapToggleDark,
                  onPressed: () => ref
                      .read(themeModeControllerProvider.notifier)
                      .toggle(Theme.of(context).brightness),
                  style: floatingOverlayIconButtonStyle(context),
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? FLucideIcons.sun
                        : FLucideIcons.moon,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // ponytail: tombol gaya peta disembunyikan sementara (sheet
                // basemap_picker_sheet.dart siap). Aktifkan lagi nanti.
              ],
            ),
          ),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: FBadge(
                    variant: FBadgeVariant.secondary,
                    child: Text(
                      selected == null
                          ? l10n.wilayahTapKecamatan
                          : _selectedDesaId != null
                          ? l10n.regionDesaTitle(
                              desaOfSelected
                                      .where((d) => d.id == _selectedDesaId)
                                      .firstOrNull
                                      ?.name ??
                                  _selectedDesaId!,
                            )
                          : l10n.regionKecamatanTitle(selected.name),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Kartu ringkas di peta: tinggi fixed, tak mungkin memenuhi
          // layar (akar bug #106). Daftar desa/cari/places -> bottomsheet.
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 12,
            child: _CompactPanel(
              selected: selected,
              loading: desaAsync.isLoading,
              desaOfSelected: desaOfSelected,
              selectedDesaId: _selectedDesaId,
              onOpenKecDetail: (kec) => unawaited(
                context.push(
                  ExploreRouter.kecamatan.path.replaceFirst(':slug', kec.id),
                ),
              ),
              onOpenSheet: _openDesaSheet,
            ),
          ),
        ],
      ),
    );
  }
}

/// Isi bottomsheet modal Wilayah: search lintas kecamatan + daftar desa +
/// places. Konsumsi data sendiri (watch provider) supaya selalu segar saat
/// terbuka; daftar tak lagi tumbuh tak terbatas di panel peta (#106).
class WilayahSheet extends ConsumerStatefulWidget {
  const WilayahSheet({
    super.key,
    required this.selected,
    required this.initialDesaId,
    required this.onPickSearchedDesa,
    required this.onDesaTap,
  });

  /// Kecamatan yang dibuka saat sheet (beku: modal menutup peta).
  final Region? selected;

  /// Sorot desa yang sudah terpilih saat sheet dibuka.
  final String? initialDesaId;
  final Future<void> Function(Region desa, Region kec) onPickSearchedDesa;
  final void Function(Region) onDesaTap;

  @override
  ConsumerState<WilayahSheet> createState() => _WilayahSheetState();
}

class _WilayahSheetState extends ConsumerState<WilayahSheet> {
  String _query = '';
  String? _selectedDesaId;
  _SheetTab _tab = _SheetTab.desa;

  @override
  void initState() {
    super.initState();
    _selectedDesaId = widget.initialDesaId;
  }

  /// Hasil cari desa (lintas kecamatan): min 2 huruf, maks 8 hasil.
  static List<(Region, Region)> _resultsFor(
    String query,
    List<Region>? kecamatan,
    List<Region>? desa,
  ) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return const [];
    final kecById = {for (final k in kecamatan ?? const <Region>[]) k.id: k};
    final results = <(Region, Region)>[];
    for (final d in desa ?? const <Region>[]) {
      if (d.type != RegionType.desa) continue;
      final parent = kecById[d.parentId];
      if (parent != null && d.name.toLowerCase().contains(q)) {
        results.add((d, parent));
      }
      if (results.length >= 8) break;
    }
    return results;
  }

  void _openKecDetail(Region kec) => unawaited(
    context.push(ExploreRouter.kecamatan.path.replaceFirst(':slug', kec.id)),
  );

  void _openDesaDetail(Region desa) => unawaited(
    context.push(
      // Kode BPS sebagai slug: id desa mengandung "/" yang memecah
      // segmen path GoRouter (route not found).
      ExploreRouter.desa.path.replaceFirst(
        ':slug',
        Uri.encodeComponent(desa.code ?? desa.id),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final kec = widget.selected;
    final kecamatanAsync = ref.watch(regionsKecamatanProvider);
    final desaAsync = ref.watch(regionsProvider);
    final placesAsync = ref.watch(placesProvider);
    final loading = desaAsync.isLoading;
    final desaOfSelected = kec == null
        ? const <Region>[]
        : (desaAsync.value ?? const <Region>[])
              .where((r) => r.parentId == kec.id)
              .toList();
    final searchResults = _resultsFor(
      _query,
      kecamatanAsync.value,
      desaAsync.value,
    );
    final placesOfKec = (placesAsync.value ?? const <Place>[])
        .where((p) => kec != null && p.regionId == kec.id)
        .toList();
    // Wisata saja (kuliner punya halaman sendiri).
    final wisataOfKec = placesOfKec
        .where((p) => p.category == PlaceCategory.wisata)
        .toList();

    // Gaya kartu sama dengan _PlaceCard (pins_page): radius 16 + border flat.
    final radius = BorderRadius.circular(16);
    return SingleChildScrollView(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colors.background,
            borderRadius: radius,
            border: Border.fromBorderSide(
              BorderSide(color: theme.colors.border),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cari desa lintas kecamatan. Hasil: tap -> peta fokus + sheet
              // tertutup supaya polygon terpilih langsung terlihat.
              FTextField(
                control: FTextFieldControl.managed(
                  onChange: (v) => setState(() => _query = v.text),
                ),
                hint: AppLocalizations.of(context).wilayahSearchVillageHint,
                clearable: (value) => value.text.isNotEmpty,
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
              if (searchResults.isNotEmpty) ...[
                const Gap(4),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colors.muted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      for (final (desa, parent) in searchResults)
                        InkWell(
                          onTap: () {
                            unawaited(widget.onPickSearchedDesa(desa, parent));
                            if (mounted) {
                              Navigator.of(context).maybePop();
                            }
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  FLucideIcons.mapPin,
                                  size: 13,
                                  color: theme.colors.primary,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    desa.name,
                                    style: theme.typography.body.sm,
                                  ),
                                ),
                                Text(
                                  parent.name,
                                  style: theme.typography.body.xs.copyWith(
                                    color: theme.colors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const Gap(8),
              if (kec == null)
                Text(
                  l10n.wilayahTapKecamatanHint,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                )
              else ...[
                Text(
                  _selectedDesaId != null
                      ? l10n.regionDesaTitle(
                          desaOfSelected
                                  .where((d) => d.id == _selectedDesaId)
                                  .firstOrNull
                                  ?.name ??
                              _selectedDesaId ??
                              '',
                        )
                      : l10n.regionKecamatanTitle(kec.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                Text(
                  switch (_tab) {
                    _SheetTab.desa => loading
                        ? l10n.wilayahLoadingVillage
                        : l10n.wilayahDesaCount(desaOfSelected.length),
                    _SheetTab.wisata => l10n.wilayahWisataCount(
                      wisataOfKec.length,
                    ),
                    _SheetTab.usaha => l10n.wilayahUsahaInKecamatan,
                    _SheetTab.acara => l10n.wilayahAcaraInKecamatan,
                  },
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(8),
                _SheetChips(selected: _tab, onChanged: _onTabChanged),
                const Gap(8),
                _tabBody(kec, desaOfSelected, wisataOfKec, loading),
                const Gap(8),
                Row(
                  children: [
                    SmallButton(
                      label: l10n.commonClose,
                      variant: FButtonVariant.primary,
                      onPress: () => Navigator.of(context).maybePop(),
                    ),
                    const Gap(8),
                    SmallButton(
                      label: l10n.wilayahKecamatanProfile,
                      onPress: () => _openKecDetail(kec),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onTabChanged(_SheetTab next) {
    if (next == _tab) return;
    // Ganti filter terasa instan di jari (konsisten chips feed home).
    HapticFeedback.selectionClick();
    unawaited(AnalyticsService.instance.logWilayahSheetTab(tab: next.name));
    setState(() => _tab = next);
  }

  /// Body per chip. Provider usaha/acara hanya di-watch di cabang aktif -
  /// fetch terjadi saat chip pertama dibuka (autoDispose family, lazy).
  /// Empty/loading pakai [_sheetTabSlot] supaya tinggi sheet tidak turun
  /// saat ganti kategori (mis. Desa berisi → Wisata kosong).
  Widget _tabBody(
    Region kec,
    List<Region> desaOfSelected,
    List<Place> wisataOfKec,
    bool loading,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    switch (_tab) {
      case _SheetTab.desa:
        if (loading) {
          return _sheetTabSlot(Text(l10n.wilayahLoadingVillageList, style: muted));
        }
        if (desaOfSelected.isEmpty) {
          return _sheetTabSlot(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.wilayahVillageListFailed,
                  style: muted,
                ),
                const Gap(4),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => ref.invalidate(regionsProvider),
                  child: Text(l10n.wilayahReload),
                ),
              ],
            ),
          );
        }
        return _DesaList(
          desa: desaOfSelected,
          selectedDesaId: _selectedDesaId,
          onDesaTap: (desa) {
            setState(() => _selectedDesaId = desa.id);
            widget.onDesaTap(desa);
          },
          onOpenDesaDetail: _openDesaDetail,
        );
      case _SheetTab.wisata:
        if (wisataOfKec.isEmpty) {
          return _sheetTabSlot(Text(l10n.wilayahNoWisata, style: muted));
        }
        return _PlacesList(places: wisataOfKec);
      case _SheetTab.usaha:
        final async = ref.watch(
          usahaBrowseProvider(UsahaBrowseQuery(regionId: kec.id)),
        );
        if (async.isLoading) {
          return _sheetTabSlot(Text(l10n.wilayahLoadingUsaha, style: muted));
        }
        final items = async.value?.items ?? const [];
        if (items.isEmpty) {
          return _sheetTabSlot(Text(l10n.wilayahNoUsaha, style: muted));
        }
        return _UsahaList(items: items);
      case _SheetTab.acara:
        final async = ref.watch(
          eventBrowseProvider(EventBrowseQuery(regionId: kec.id)),
        );
        if (async.isLoading) {
          return _sheetTabSlot(Text(l10n.wilayahLoadingAcara, style: muted));
        }
        final items = async.value?.items ?? const [];
        if (items.isEmpty) {
          return _sheetTabSlot(Text(l10n.wilayahNoAcara, style: muted));
        }
        return _CappedScrollList(
          itemCount: items.length,
          itemBuilder: (context, i) => EventMiniTile(event: items[i]),
        );
    }
  }

  /// Slot tinggi tetap untuk placeholder loading/empty - samakan dengan
  /// [_kWilayahSheetListHeight] agar ganti chip tidak mengecilkan sheet.
  Widget _sheetTabSlot(Widget child) => SizedBox(
        height: _kWilayahSheetListHeight,
        width: double.infinity,
        child: Align(alignment: Alignment.topLeft, child: child),
      );
}

/// Chip tab isi sheet: gaya sama dengan chips kategori feed home
/// (_FeedCategoryChips) - FButton xs, primary saat aktif, outline saat tidak.
enum _SheetTab { desa, wisata, usaha, acara }

class _SheetChips extends StatelessWidget {
  const _SheetChips({required this.selected, required this.onChanged});

  final _SheetTab selected;
  final ValueChanged<_SheetTab> onChanged;

  String _labelOf(AppLocalizations l10n, _SheetTab tab) => switch (tab) {
    _SheetTab.desa => l10n.profileVillageLabel,
    _SheetTab.wisata => l10n.placeTypeWisata,
    _SheetTab.usaha => l10n.usahaTitle,
    _SheetTab.acara => l10n.feedKindEvent,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        // Key khusus test: sheet punya ListView lain (daftar desa/places).
        key: const ValueKey('wilayah_sheet_chips'),
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _SheetTab.values.length,
        separatorBuilder: (_, _) => const Gap(6),
        itemBuilder: (context, i) {
          final tab = _SheetTab.values[i];
          final isSelected = tab == selected;
          return FButton(
            size: .xs,
            variant: isSelected
                ? FButtonVariant.primary
                : FButtonVariant.outline,
            onPress: () => onChanged(tab),
            child: Text(_labelOf(AppLocalizations.of(context), tab)),
          );
        },
      ),
    );
  }
}

/// Daftar usaha ringkas di sheet: row gaya _PlacesList (icon + nama +
/// chevron), tap = halaman detail usaha.
class _UsahaList extends StatelessWidget {
  const _UsahaList({required this.items});

  final List<Usaha> items;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return _CappedScrollList(
      itemCount: items.length,
      itemBuilder: (context, i) {
        final u = items[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: InkWell(
            onTap: () =>
                unawaited(context.push(UsahaRouter.detailPath(u.slug))),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Icon(
                  FLucideIcons.store,
                  size: 14,
                  color: theme.colors.primary,
                ),
                const Gap(8),
                Expanded(child: Text(u.name, style: theme.typography.body.sm)),
                Icon(
                  FLucideIcons.chevronRight,
                  size: 14,
                  color: theme.colors.mutedForeground,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Kartu ringkas di peta: judul + jumlah desa + tombol. Tinggi fixed tanpa
/// daftar - daftar/cari/places pindah ke bottomsheet (#106).
class _CompactPanel extends StatelessWidget {
  const _CompactPanel({
    required this.selected,
    required this.loading,
    required this.desaOfSelected,
    required this.selectedDesaId,
    required this.onOpenKecDetail,
    required this.onOpenSheet,
  });

  final Region? selected;
  final bool loading;
  final List<Region> desaOfSelected;
  final String? selectedDesaId;
  final void Function(Region kec) onOpenKecDetail;
  final VoidCallback onOpenSheet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final radius = BorderRadius.circular(16);
    final kec = selected;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: radius,
          border: Border.fromBorderSide(BorderSide(color: theme.colors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: kec == null
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.wilayahTapKecamatanHint,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                  const Gap(8),
                  SmallButton(label: l10n.wilayahSearchVillageCta, onPress: onOpenSheet),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedDesaId != null
                        ? l10n.regionDesaTitle(
                            desaOfSelected
                                    .where((d) => d.id == selectedDesaId)
                                    .firstOrNull
                                    ?.name ??
                                selectedDesaId ??
                                '',
                          )
                        : l10n.regionKecamatanTitle(kec.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    loading
                        ? l10n.wilayahLoadingVillageList
                        : l10n.wilayahDesaCount(desaOfSelected.length),
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      SmallButton(
                        label: l10n.wilayahSeeArea,
                        variant: FButtonVariant.primary,
                        onPress: onOpenSheet,
                      ),
                      const Gap(8),
                      SmallButton(
                        label: l10n.wilayahKecamatanProfile,
                        onPress: () => onOpenKecDetail(kec),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

/// Tinggi tetap area daftar di sheet Wilayah. Naik dari 220 supaya lebih
/// banyak item terlihat; juga dipakai placeholder empty/loading supaya
/// ganti kategori (Desa → Wisata kosong) tidak mengecilkan sheet.
const double _kWilayahSheetListHeight = 320;

/// Daftar scrollable tinggi tetap ([_kWilayahSheetListHeight]) + pill
/// floating "Gulir ke bawah" bila masih ada item di bawah viewport.
/// Pill hilang saat sudah sampai dasar.
class _CappedScrollList extends StatefulWidget {
  const _CappedScrollList({required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  @override
  State<_CappedScrollList> createState() => _CappedScrollListState();
}

class _CappedScrollListState extends State<_CappedScrollList> {
  final _controller = ScrollController();
  bool _hasMoreBelow = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateIndicator);
    // Item awal bisa lebih dari viewport: cek setelah first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateIndicator() {
    final more =
        _controller.hasClients && _controller.position.extentAfter > 24;
    if (more != _hasMoreBelow) setState(() => _hasMoreBelow = more);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Stack(
      children: [
        SizedBox(
          height: _kWilayahSheetListHeight,
          child: ListView.builder(
            controller: _controller,
            padding: const EdgeInsets.only(bottom: 4),
            itemCount: widget.itemCount,
            itemBuilder: widget.itemBuilder,
          ),
        ),
        // Pill indikator: ada konten lagi di bawah. Tap = scroll ke dasar.
        if (_hasMoreBelow)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              ignoring: false,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _controller.animateTo(
                      _controller.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colors.background,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: theme.colors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.wilayahScrollDown,
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                        const Gap(4),
                        Icon(
                          FLucideIcons.chevronDown,
                          size: 12,
                          color: theme.colors.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Daftar desa: item row + CTA profil desa.
class _DesaList extends StatelessWidget {
  const _DesaList({
    required this.desa,
    required this.selectedDesaId,
    required this.onDesaTap,
    required this.onOpenDesaDetail,
  });

  final List<Region> desa;
  final String? selectedDesaId;
  final void Function(Region) onDesaTap;
  final void Function(Region) onOpenDesaDetail;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return _CappedScrollList(
      itemCount: desa.length,
      itemBuilder: (context, i) {
        final d = desa[i];
        final isSelected = d.id == selectedDesaId;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: InkWell(
            // Tap baris = highlight polygon + buka halaman detail desa.
            // Tanpa chevron terpisah (lebih compact).
            onTap: () {
              onDesaTap(d);
              onOpenDesaDetail(d);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: isSelected
                  ? BoxDecoration(
                      color: theme.colors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Row(
                children: [
                  Icon(
                    FLucideIcons.mapPin,
                    size: 14,
                    color: isSelected
                        ? theme.colors.primary
                        : theme.colors.mutedForeground,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      d.name,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected ? theme.colors.primary : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Daftar tempat (wisata/kuliner) di kecamatan terpilih.
class _PlacesList extends StatelessWidget {
  const _PlacesList({required this.places});

  final List<Place> places;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return _CappedScrollList(
      itemCount: places.length,
      itemBuilder: (context, i) {
        final p = places[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: InkWell(
            onTap: () => context.push(
              ExploreRouter.place.path.replaceFirst(':slug', p.slug),
              extra: 'wilayah',
            ),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Icon(
                  p.category == PlaceCategory.kuliner
                      ? FLucideIcons.utensilsCrossed
                      : FLucideIcons.landmark,
                  size: 14,
                  color: theme.colors.primary,
                ),
                const Gap(8),
                Expanded(child: Text(p.name, style: theme.typography.body.sm)),
                Icon(
                  FLucideIcons.chevronRight,
                  size: 14,
                  color: theme.colors.mutedForeground,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

