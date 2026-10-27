import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/sambas_nominatim.dart';
import '../../domain/sambas_map_config.dart';
import '../widgets/sambas_map_view.dart';

// Penanda hint yang perlu diterjemahkan saat render (state tidak simpan
// teks berbahasa).
const _hintTooShort = '\u0000hint:tooShort';
const _hintSearching = '\u0000hint:searching';
const _hintNotFound = '\u0000hint:notFound';
const _hintOutOfBounds = '\u0000hint:outOfBounds';

/// Hasil layar penuh. `point` null berarti titik dihapus.
class PlacePinPick {
  const PlacePinPick(this.point);

  final LatLng? point;
}

/// Peta layar penuh untuk menaruh titik, plus pencarian Nominatim.
class PlacePinPickerPage extends StatefulWidget {
  const PlacePinPickerPage({super.key, this.initial});

  final LatLng? initial;

  @override
  State<PlacePinPickerPage> createState() => _PlacePinPickerPageState();
}

class _PlacePinPickerPageState extends State<PlacePinPickerPage> {
  final _query = TextEditingController();
  final _nominatim = SambasNominatim();
  MapLibreMapController? _controller;
  Timer? _debounce;
  var _gen = 0;
  var _styleReady = false;
  String? _hint;
  String? _lastQuery;
  LatLng? _point;
  List<NominatimHit> _results = const [];

  @override
  void initState() {
    super.initState();
    _point = widget.initial;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nominatim.dispose();
    _query.dispose();
    super.dispose();
  }

  void _schedule(String raw) {
    _debounce?.cancel();
    final gen = ++_gen;
    final cleaned = cleanNominatimQuery(raw);
    if (cleaned == null) {
      _nominatim.cancel();
      setState(() {
        _results = const [];
        _hint = raw.trim().isEmpty ? null : _hintTooShort;
      });
      return;
    }
    if (cleaned == _lastQuery) {
      _nominatim.cancel();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted || gen != _gen) return;
      _search(cleaned, gen);
    });
  }

  Future<void> _search(String query, int gen) async {
    setState(() {
      _hint = _hintSearching;
      _results = const [];
    });
    try {
      final hits = await _nominatim.searchMany(query);
      if (!mounted || gen != _gen) return;
      _lastQuery = query;
      if (hits.isEmpty) {
        setState(() => _hint = _hintNotFound);
        return;
      }
      setState(() {
        _hint = null;
        _results = hits;
      });
    } on NominatimException catch (e) {
      if (!mounted || gen != _gen) return;
      setState(() => _hint = e.message);
    }
  }

  void _pickHit(NominatimHit hit) {
    final point = LatLng(hit.lat, hit.lng);
    setState(() {
      _point = point;
      _results = const [];
      _hint = hit.label;
    });
    _draw();
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(point, SambasMapConfig.placeZoom),
    );
  }

  void _tap(LatLng point) {
    if (!inSambasBounds(point.latitude, point.longitude)) {
      setState(() => _hint = _hintOutOfBounds);
      return;
    }
    setState(() {
      _point = point;
      _hint = null;
      _results = const [];
    });
    _draw();
  }

  Future<void> _draw() async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    await controller.clearCircles();
    final point = _point;
    if (point == null) return;
    await controller.addCircle(
      CircleOptions(
        geometry: point,
        circleRadius: 8,
        circleColor: '#E11D48',
        circleStrokeWidth: 2,
        circleStrokeColor: '#FFFFFF',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final point = _point;
    return FScaffold(
      childPad: false,
      // Keyboard tidak mengecilkan peta, jadi kamera tidak bergeser.
      resizeToAvoidBottomInset: false,
      header: FHeader.nested(
        title: Text(l10n.placePinPickerTitle),
        prefixes: [
          FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SambasMapView(
              initialCameraPosition: CameraPosition(
                target: point ?? SambasMapConfig.center,
                zoom: point == null
                    ? SambasMapConfig.fullscreenZoom
                    : SambasMapConfig.placeZoom,
              ),
              annotationOrder: const [AnnotationType.circle],
              analyticsEntry: 'contribute',
              onMapCreated: (controller) => _controller = controller,
              onStyleLoaded: () {
                _styleReady = true;
                _draw();
              },
              onMapClick: (_, latLng) => _tap(latLng),
            ),
          ),
          // Overlay pencarian di atas peta.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FTextField(
                      control: FTextFieldControl.managed(
                        controller: _query,
                        onChange: (value) => _schedule(value.text),
                      ),
                      hint: l10n.placePinPickerSearchHint,
                      prefixBuilder: (context, style, variants) =>
                          FTextField.prefixIconBuilder(
                            context,
                            style,
                            variants,
                            const Icon(FLucideIcons.search),
                          ),
                    ),
                    if (_hint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          switch (_hint!) {
                            _hintSearching => l10n.placePinPickerSearching,
                            _hintNotFound => l10n.placePinPickerNotFound,
                            _hintOutOfBounds =>
                              l10n.placePinPickerOutOfBounds,
                            _hintTooShort => l10n.placePinPickerTooShort,
                            final label => label,
                          },
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    if (_results.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Material(
                          color: theme.colors.background,
                          elevation: 4,
                          borderRadius: BorderRadius.circular(10),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 240),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _results.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final hit = _results[i];
                                return InkWell(
                                  onTap: () => _pickHit(hit),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          FLucideIcons.mapPin,
                                          size: 16,
                                          color: theme.colors.primary,
                                        ),
                                        const Gap(10),
                                        Expanded(
                                          child: Text(
                                            hit.label,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.typography.body.sm,
                                          ),
                                        ),
                                        Text(
                                          '${i + 1}',
                                          style: theme.typography.body.xs.copyWith(
                                            color: theme.colors.mutedForeground,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Tombol bawah, tetap terlihat saat keyboard terbuka.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      if (point != null) ...[
                        Expanded(
                          child: FButton(
                            variant: .outline,
                            onPress: () {
                              setState(() => _point = null);
                              _draw();
                            },
                            child: Text(l10n.placePinPickerRemove),
                          ),
                        ),
                        const Gap(8),
                      ],
                      Expanded(
                        child: FButton(
                          onPress: point == null
                              ? (widget.initial == null
                                    ? null
                                    : () => Navigator.of(
                                        context,
                                      ).pop(const PlacePinPick(null)))
                              : () => Navigator.of(
                                  context,
                                ).pop(PlacePinPick(point)),
                          child: Text(
                            point == null && widget.initial != null
                                ? l10n.placePinPickerRemove
                                : l10n.placePinPickerUsePoint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
