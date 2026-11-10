import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/models/external_link.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../data/maps_url_resolve.dart';
import '../../data/sambas_nominatim.dart';
import '../../domain/sambas_map_config.dart';
import '../widgets/sambas_map_view.dart';

// Penanda hint yang perlu diterjemahkan saat render (state tidak simpan
// teks berbahasa).
const _hintTooShort = '\u0000hint:tooShort';
const _hintSearching = '\u0000hint:searching';
const _hintResolvingUrl = '\u0000hint:resolvingUrl';
const _hintNotFound = '\u0000hint:notFound';
const _hintOutOfBounds = '\u0000hint:outOfBounds';
const _hintSearchFailed = '\u0000hint:searchFailed';
const _hintFromMaps = '\u0000hint:fromMaps';

/// Hasil layar penuh. `point` null berarti titik dihapus.
class PlacePinPick {
  const PlacePinPick(this.point);

  final LatLng? point;
}

/// Peta layar penuh untuk menaruh titik, plus pencarian Nominatim
/// dan paste tautan Google Maps (resolve di API).
class PlacePinPickerPage extends ConsumerStatefulWidget {
  const PlacePinPickerPage({super.key, this.initial});

  final LatLng? initial;

  @override
  ConsumerState<PlacePinPickerPage> createState() => _PlacePinPickerPageState();
}

class _PlacePinPickerPageState extends ConsumerState<PlacePinPickerPage> {
  final _query = TextEditingController();
  final _nominatim = SambasNominatim();
  MapsUrlResolveApi? _mapsApi;
  MapLibreMapController? _controller;
  Timer? _debounce;
  var _gen = 0;
  var _drawGen = 0;
  var _styleReady = false;
  var _resolvingUrl = false;
  String? _hint;
  String? _lastQuery;
  LatLng? _point;
  List<NominatimHit> _results = const [];

  static final _openMapsUri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=Kabupaten+Sambas',
  );

  MapsUrlResolveApi get _resolveApi =>
      _mapsApi ??= MapsUrlResolveApi(ref.read(dioProvider));

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryTick);
    final initial = widget.initial;
    if (initial == null) {
      _point = null;
      return;
    }
    if (!inSambasBounds(initial.latitude, initial.longitude)) {
      _point = null;
      _hint = _hintOutOfBounds;
      return;
    }
    _point = initial;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.removeListener(_onQueryTick);
    _nominatim.dispose();
    _mapsApi?.dispose();
    _query.dispose();
    super.dispose();
  }

  void _onQueryTick() {
    if (mounted) setState(() {});
  }

  void _unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _clearField() {
    _debounce?.cancel();
    _gen++;
    _nominatim.cancel();
    _mapsApi?.cancel();
    _query.clear();
    setState(() {
      _results = const [];
      _hint = null;
      _lastQuery = null;
      _resolvingUrl = false;
    });
  }

  Future<void> _pasteClipboard() async {
    if (_resolvingUrl) return;
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!mounted) return;
    if (text.isEmpty) {
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).placePinPickerClipboardEmpty),
      );
      return;
    }
    _query.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _schedule(text);
  }

  void _schedule(String raw) {
    _debounce?.cancel();
    final gen = ++_gen;

    if (looksLikeMapsUrl(raw)) {
      _nominatim.cancel();
      setState(() {
        _results = const [];
        _hint = _hintResolvingUrl;
        _resolvingUrl = true;
      });
      _debounce = Timer(const Duration(milliseconds: 350), () {
        if (!mounted || gen != _gen) return;
        _resolveMaps(raw, gen);
      });
      return;
    }

    _mapsApi?.cancel();
    _resolvingUrl = false;
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

  Future<void> _resolveMaps(String raw, int gen) async {
    setState(() {
      _hint = _hintResolvingUrl;
      _results = const [];
      _resolvingUrl = true;
    });
    try {
      final hit = await _resolveApi.resolve(raw);
      if (!mounted || gen != _gen) return;
      final point = LatLng(hit.lat, hit.lng);
      setState(() {
        _point = point;
        _results = const [];
        _hint = _hintFromMaps;
        _resolvingUrl = false;
        _lastQuery = extractMapsUrlCandidate(raw);
      });
      _draw();
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(point, SambasMapConfig.placeZoom),
      );
    } on MapsUrlResolveException catch (e) {
      if (!mounted || gen != _gen) return;
      if (e.code == 'CANCELLED') return;
      setState(() {
        _resolvingUrl = false;
        _results = const [];
        _hint = null;
      });
      if (e.code == 'RATE_LIMITED') {
        showFToast(context: context, title: Text(e.message));
        return;
      }
      await showAppErrorSheet(context, message: e.message);
    } catch (_) {
      if (!mounted || gen != _gen) return;
      setState(() {
        _resolvingUrl = false;
        _hint = null;
      });
      await showAppErrorSheet(
        context,
        message: AppLocalizations.of(context).placePinPickerMapsUrlFailed,
      );
    }
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
    } on NominatimException {
      if (!mounted || gen != _gen) return;
      setState(() => _hint = _hintSearchFailed);
    } catch (_) {
      if (!mounted || gen != _gen) return;
      setState(() => _hint = _hintSearchFailed);
    }
  }

  void _pickHit(NominatimHit hit) {
    _unfocus();
    final point = LatLng(hit.lat, hit.lng);
    if (!inSambasBounds(point.latitude, point.longitude)) {
      setState(() {
        _results = const [];
        _hint = _hintOutOfBounds;
      });
      return;
    }
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
    _unfocus();
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
    final gen = ++_drawGen;
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    await controller.clearCircles();
    if (!mounted || gen != _drawGen) return;
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

  Future<void> _openGoogleMaps() async {
    await launchExternalUrl(_openMapsUri);
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
          // Overlay pencarian menempel di bawah header (bukan SafeArea top:
          // FHeader.nested sudah konsumsi inset status bar).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: FTextField(
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
                          suffixBuilder: _resolvingUrl
                              ? (context, style, _) => Padding(
                                  padding: style.clearButtonPadding,
                                  child: const FCircularProgress(size: .sm),
                                )
                              : _query.text.isNotEmpty
                              ? (context, style, _) => Padding(
                                  padding: style.clearButtonPadding,
                                  child: GestureDetector(
                                    onTap: _clearField,
                                    behavior: HitTestBehavior.opaque,
                                    child: Semantics(
                                      button: true,
                                      label: l10n.placePinPickerClearField,
                                      child: Icon(
                                        FLucideIcons.x,
                                        size: 18,
                                        color: theme.colors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const Gap(6),
                      // Tombol tempel kecil - clipboard OS (lebih enak di HP
                      // daripada long-press field).
                      FButton(
                        variant: .outline,
                        onPress: _resolvingUrl ? null : _pasteClipboard,
                        child: Semantics(
                          label: l10n.placePinPickerPaste,
                          child: const Icon(FLucideIcons.clipboardPaste),
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),
                  FButton(
                    variant: .outline,
                    onPress: _resolvingUrl ? null : _openGoogleMaps,
                    prefix: const Icon(FLucideIcons.map),
                    child: Text(l10n.placePinPickerOpenMaps),
                  ),
                  if (_hint != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        switch (_hint!) {
                          _hintSearching => l10n.placePinPickerSearching,
                          _hintResolvingUrl =>
                            l10n.placePinPickerResolvingUrl,
                          _hintNotFound => l10n.placePinPickerNotFound,
                          _hintOutOfBounds =>
                            l10n.placePinPickerOutOfBounds,
                          _hintTooShort => l10n.placePinPickerTooShort,
                          _hintSearchFailed => l10n.nominatimSearchFailed,
                          _hintFromMaps => l10n.placePinPickerFromMaps,
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
                                        style: theme.typography.body.xs
                                            .copyWith(
                                              color: theme
                                                  .colors
                                                  .mutedForeground,
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
                            onPress: _resolvingUrl
                                ? null
                                : () {
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
                          onPress: _resolvingUrl
                              ? null
                              : point == null
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
