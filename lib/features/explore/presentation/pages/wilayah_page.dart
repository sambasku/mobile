import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../../shared/widgets/small_button.dart';
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
  bool _showDesa = false;

  /// Query cari desa (lintas kecamatan). Kosong = tak sedang mencari.
  String _desaQuery = '';

  /// Hasil pencarian desa: (desa, kecamatan induk).
  List<(Region, Region)> get _desaSearchResults {
    final q = _desaQuery.trim().toLowerCase();
    if (q.length < 2) return const [];
    final kecamatanAsync = ref.read(regionsKecamatanProvider);
    final desaAsync = ref.read(regionsProvider);
    final kecById = {
      for (final k in kecamatanAsync.value ?? const <Region>[]) k.id: k,
    };
    final results = <(Region, Region)>[];
    for (final d in desaAsync.value ?? const <Region>[]) {
      if (d.type != RegionType.desa) continue;
      final kec = kecById[d.parentId];
      if (kec != null && d.name.toLowerCase().contains(q)) {
        results.add((d, kec));
      }
      if (results.length >= 8) break;
    }
    return results;
  }

  /// Pilih desa dari hasil pencarian: set kecamatan induk + desa, buka
  /// panel desa, load polygon, kamera fokus ke centroid desa.
  Future<void> _pickSearchedDesa(Region desa, Region kec) async {
    setState(() {
      _desaQuery = '';
      _selectedKecId = kec.id;
      _selectedDesaId = desa.id;
      _showDesa = true;
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
    try {
      final raw = await rootBundle.loadString(
        'assets/data/regions-adm4.geojson',
      );
      final geojson = jsonDecode(raw) as Map<String, dynamic>;
      final rings = <String, List<List<List<double>>>>{};

      final feats = geojson['features'];
      if (feats is List) {
        for (final f in feats) {
          if (f is! Map || f['properties'] is! Map) continue;
          final props = f['properties'] as Map;
          final parentId = props['parentId'];
          if (parentId != kecSlug) continue;

          final id = props['id'];
          final g = f['geometry'];
          if (id is! String || g is! Map) continue;

          if (g['type'] == 'Polygon') {
            rings[id] = [_outerRing(g['coordinates'] as List)];
          } else if (g['type'] == 'MultiPolygon') {
            rings[id] = [
              for (final poly in g['coordinates'] as List)
                _outerRing(poly as List),
            ];
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _desaRings.clear();
        _desaRings.addAll(rings);
        _desaShownForKec = kecSlug;
      });
      await _syncDesaLayers(kecSlug);
    } catch (_) {
      // Asset hilang/korup: tampilkan list saja tanpa polygon desa.
    }
  }

  static List<List<double>> _outerRing(List poly) => [
    for (final p in poly.first as List)
      [(p as List)[0] as double, p[1] as double],
  ];

  /// Ganti isi source desa: remove layer+source lama lalu add ulang bila
  /// ada ring untuk kecamatan ini. Aman dipanggil ulang (idempotent).
  Future<void> _syncDesaLayers(String kecSlug) async {
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

      if (_desaRings.isEmpty) return;
      _desaLayersAdded = true;
      try {
        final raw = await rootBundle.loadString(
          'assets/data/regions-adm4.geojson',
        );
        final geojson = jsonDecode(raw) as Map<String, dynamic>;
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
          const FillLayerProperties(
            fillColor: _desaFillColor,
            fillOpacity: 0.25,
          ),
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
        await _applyDesaSelection();
      } catch (_) {
        _desaLayersAdded = false;
      }
    } catch (_) {}
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
      // showDesa dipertahankan: panel daftar tetap terbuka saat ganti
      // kecamatan, tak perlu tap "Lihat desa" ulang.
    });
    unawaited(_applyKecColors());
  }

  @override
  Widget build(BuildContext context) {
    final kecamatanAsync = ref.watch(regionsKecamatanProvider);
    final desaAsync = ref.watch(regionsProvider);
    final kecamatan = kecamatanAsync.value ?? const <Region>[];
    final selected = kecamatan.where((k) => k.id == _selectedKecId).firstOrNull;
    final desaOfSelected = selected == null
        ? const <Region>[]
        : (desaAsync.value ?? const <Region>[])
              .where((r) => r.parentId == selected.id)
              .toList();
    final desaSearch = _desaQuery.trim().length >= 2
        ? _desaSearchResults
        : const <(Region, Region)>[];

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
                  unawaited(_syncDesaLayers(kec));
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
                  tooltip: 'Kembali',
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/explore'),
                  style: _floatingButtonStyle(context),
                  icon: const Icon(FLucideIcons.arrowLeft, size: 20),
                ),
                const SizedBox(height: 8),
                IconButton(
                  tooltip: Theme.of(context).brightness == Brightness.dark
                      ? 'Peta mode terang'
                      : 'Peta mode gelap',
                  onPressed: () => ref
                      .read(themeModeControllerProvider.notifier)
                      .toggle(Theme.of(context).brightness),
                  style: _floatingButtonStyle(context),
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
                          ? 'Ketuk area kecamatan'
                          : _selectedDesaId != null
                          ? 'Desa ${desaOfSelected.where((d) => d.id == _selectedDesaId).firstOrNull?.name ?? _selectedDesaId}'
                          : 'Kecamatan ${selected.name}',
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Panel bawah kartu mengambang, gaya sama dengan _PlaceCard di
          // pins_page: radius 16 + border flat, margin 16, tanpa shadow.
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 12,
            child: _BottomPanel(
              selected: selected,
              showDesa: _showDesa,
              desaOfSelected: desaOfSelected,
              loading: desaAsync.isLoading,
              searchQuery: _desaQuery,
              searchResults: desaSearch,
              onSearchChanged: (v) => setState(() => _desaQuery = v),
              onPickSearchedDesa: _pickSearchedDesa,
              onToggleDesa: selected == null
                  ? null
                  : () => setState(() => _showDesa = !_showDesa),
              onRetry: () => ref.invalidate(regionsProvider),
              selectedDesaId: _selectedDesaId,
              onOpenKecDetail: (kec) => unawaited(
                context.push(
                  ExploreRouter.kecamatan.path.replaceFirst(':slug', kec.id),
                ),
              ),
              onOpenDesaDetail: (desa) => unawaited(
                context.push(
                  // Kode BPS sebagai slug: id desa mengandung "/" yang
                  // memecah segmen path GoRouter (route not found).
                  ExploreRouter.desa.path.replaceFirst(
                    ':slug',
                    Uri.encodeComponent(desa.code ?? desa.id),
                  ),
                ),
              ),
              onDesaTap: (desa) {
                setState(() => _selectedDesaId = desa.id);
                unawaited(_applyDesaSelection());
                unawaited(
                  AnalyticsService.instance.logWilayahDesaSelect(
                    desaId: desa.id,
                  ),
                );
              },
              placesAsync: ref.watch(placesProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.selected,
    required this.showDesa,
    required this.desaOfSelected,
    required this.loading,
    required this.searchQuery,
    required this.searchResults,
    required this.onSearchChanged,
    required this.onPickSearchedDesa,
    this.onToggleDesa,
    required this.onRetry,
    required this.selectedDesaId,
    required this.onDesaTap,
    required this.placesAsync,
    required this.onOpenKecDetail,
    required this.onOpenDesaDetail,
  });

  final Region? selected;
  final bool showDesa;
  final List<Region> desaOfSelected;
  final bool loading;
  final String searchQuery;
  final List<(Region, Region)> searchResults;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function(Region desa, Region kec) onPickSearchedDesa;
  final VoidCallback? onToggleDesa;
  final VoidCallback onRetry;
  final String? selectedDesaId;
  final void Function(Region) onDesaTap;
  final AsyncValue<List<Place>?> placesAsync;
  final void Function(Region kec) onOpenKecDetail;
  final void Function(Region desa) onOpenDesaDetail;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final kec = selected;
    final placesOfKec = (placesAsync.value ?? const <Place>[])
        .where((p) => kec != null && p.regionId == kec.id)
        .toList();

    // FScaffold Forui bukan Material; InkWell butuh ancestor Material.
    // Gaya kartu sama dengan _PlaceCard (pins_page): radius 16 + border flat.
    final radius = BorderRadius.circular(16);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: radius,
          border: Border.fromBorderSide(BorderSide(color: theme.colors.border)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cari desa lintas kecamatan. Hasil: tap -> polygon desa tampil.
            FTextField(
              control: FTextFieldControl.managed(
                onChange: (v) => onSearchChanged(v.text),
              ),
              hint: 'Cari desa...',
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
                    for (final (desa, kec) in searchResults)
                      InkWell(
                        onTap: () => onPickSearchedDesa(desa, kec),
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
                                  style: theme.typography.sm,
                                ),
                              ),
                              Text(
                                kec.name,
                                style: theme.typography.xs.copyWith(
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
                'Ketuk salah satu area kecamatan untuk melihat desa di dalamnya.',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              )
            else ...[
              Text(
                selectedDesaId != null
                    ? 'Desa ${desaOfSelected.where((d) => d.id == selectedDesaId).firstOrNull?.name ?? selectedDesaId}'
                    : 'Kecamatan ${kec.name}',
                style: theme.typography.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              Text(
                loading
                    ? 'Memuat daftar desa...'
                    : '${desaOfSelected.length} desa',
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              // Daftar desa DI ATAS tombol: panel anchored bottom, konten
              // tumbuh ke atas, tombol Tutup tetap di posisi bawah yang sama.
              if (showDesa && !loading) ...[
                const Gap(8),
                if (desaOfSelected.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar desa belum bisa dimuat. Cek koneksi internetmu lalu coba lagi ya.',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      const Gap(4),
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: onRetry,
                        child: const Text('Muat ulang'),
                      ),
                    ],
                  )
                else
                  _DesaList(
                    desa: desaOfSelected,
                    selectedDesaId: selectedDesaId,
                    onDesaTap: onDesaTap,
                    onOpenDesaDetail: onOpenDesaDetail,
                  ),
              ],
              if (placesOfKec.isNotEmpty) ...[
                const Gap(12),
                Text(
                  'Wisata dan kuliner di sini',
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(4),
                ...placesOfKec.map(
                  (p) => Padding(
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
                          Expanded(
                            child: Text(p.name, style: theme.typography.sm),
                          ),
                          Icon(
                            FLucideIcons.chevronRight,
                            size: 14,
                            color: theme.colors.mutedForeground,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const Gap(8),
              Row(
                children: [
                  SmallButton(
                    label: showDesa ? 'Tutup' : 'Lihat desa',
                    variant: FButtonVariant.primary,
                    onPress: onToggleDesa,
                  ),
                  const Gap(8),
                  SmallButton(
                    label: 'Profil kecamatan',
                    onPress: () => onOpenKecDetail(kec),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Daftar desa scrollable (max 220) + pill floating "Gulir ke bawah" bila
/// masih ada item di bawah viewport. Pill hilang saat sudah sampai dasar.
class _DesaList extends StatefulWidget {
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
  State<_DesaList> createState() => _DesaListState();
}

class _DesaListState extends State<_DesaList> {
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
    final theme = context.theme;
    return Stack(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 220),
          child: ListView.builder(
            controller: _controller,
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 4),
            itemCount: widget.desa.length,
            itemBuilder: (context, i) {
              final desa = widget.desa[i];
              final isSelected = desa.id == widget.selectedDesaId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: InkWell(
                  onTap: () => widget.onDesaTap(desa),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
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
                            desa.name,
                            style: theme.typography.sm.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected ? theme.colors.primary : null,
                            ),
                          ),
                        ),
                        // CTA detail desa (halaman segera hadir). SmallButton
                        // eksplisit: tap baris = pilih polygon di peta, tombol
                        // = buka halaman detail. Aksi terpisah jelas.
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: SmallButton(
                            label: 'Profil desa',
                            onPress: () => widget.onOpenDesaDetail(desa),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
                          'Gulir ke bawah',
                          style: theme.typography.xs.copyWith(
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

/// Style tombol mengambang di atas peta: latar background + border-less,
/// shadow tipis fungsional (bukan dekorasi). Sama dengan pins_page.
ButtonStyle _floatingButtonStyle(BuildContext context) {
  final theme = context.theme;
  return IconButton.styleFrom(
    backgroundColor: theme.colors.background,
    foregroundColor: theme.colors.foreground,
    elevation: 2,
    shadowColor: Colors.black26,
  );
}
