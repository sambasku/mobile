import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/place_contribution_api.dart';
import '../../domain/entities/place.dart';
import '../../domain/sambas_map_config.dart';
import '../../explore_router.dart';
import '../providers/places_providers.dart';
import '../widgets/sambas_map_view.dart';
import 'place_pin_picker_page.dart';

enum PlaceContributeMode { create, edit, photo }

const _types = ['sejarah', 'alam', 'budaya', 'pantai', 'belanja'];

/// Usulan tempat baru, suntingan, atau foto langsung ke tempat yang sudah terbit.
class PlaceContributePage extends ConsumerStatefulWidget {
  const PlaceContributePage({super.key, required this.mode, this.slug});

  final PlaceContributeMode mode;
  final String? slug;

  @override
  ConsumerState<PlaceContributePage> createState() =>
      _PlaceContributePageState();
}

class _PlaceContributePageState extends ConsumerState<PlaceContributePage> {
  final _name = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _desc = TextEditingController();
  final _hours = TextEditingController();
  final _contact = TextEditingController();

  var _step = 0;
  var _busy = false;
  var _filled = false;
  /// Slug sudah terisi dari data lama (mode edit) - jangan ikut nama lagi.
  var _slugTouched = false;
  String _category = 'wisata';
  String? _type;
  String? _regionId;
  String? _regionName;
  String? _villageId;
  String? _villageName;
  LatLng? _point;
  List<PlaceOption> _regions = const [];
  List<PlaceOption> _villages = const [];
  List<AttachmentImageSlot> _images = const [];

  /// Batas foto: mode tambah-foto 5, usulan tempat 20.
  int get _maxImages => widget.mode == PlaceContributeMode.photo ? 5 : 20;

  @override
  void initState() {
    super.initState();
    unawaited(
      AnalyticsService.instance.logWisataContributeOpen(mode: widget.mode.name),
    );
    _name.addListener(_syncSlug);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLookups());
  }

  @override
  void dispose() {
    _name.dispose();
    _slugCtrl.dispose();
    _desc.dispose();
    _hours.dispose();
    _contact.dispose();
    super.dispose();
  }

  PlaceContributionApi get _api => PlaceContributionApi(ref.read(dioProvider));

  /// Slug diturunkan dari nama (tidak ditampilkan ke user). Saat menyunting,
  /// `_slugTouched` = true supaya slug lama (URL stabil) tidak ikut berubah.
  void _syncSlug() {
    if (_slugTouched) return;
    final next = slugifyPlace(_name.text);
    if (_slugCtrl.text == next) return;
    _slugCtrl.text = next;
  }

  void _apply(Place place) {
    _filled = true;
    _slugTouched = true;
    _name.text = place.name;
    _slugCtrl.text = place.slug;
    _desc.text = place.shortDescription;
    _hours.text = place.hours ?? '';
    _contact.text = _contactText(place);
    _category = place.category.name;
    _type = place.type?.name;
    _regionId = place.regionId;
    if (place.hasCoordinates) {
      _point = LatLng(place.lat!, place.lng!);
    }
  }

  Future<void> _loadLookups() async {
    try {
      final regions = await _api.regions(type: 'kecamatan');
      if (!mounted) return;
      setState(() {
        _regions = regions;
        final match = regions.where((r) => r.id == _regionId);
        if (match.isNotEmpty) _regionName = match.first.name;
      });
      if (_regionId != null) await _loadVillages(_regionId!);
    } catch (_) {}
  }

  Future<void> _loadVillages(String parentId) async {
    try {
      final villages = await _api.regions(type: 'desa', parentId: parentId);
      if (!mounted) return;
      setState(() => _villages = villages);
    } catch (_) {}
  }

  Future<void> _pickCategory() async {
    final picked = await showOptionPickerSheet<String>(
      context,
      title: AppLocalizations.of(context).placeFormPickType,
      icon: FLucideIcons.listFilter,
      items: [
        for (final type in _types)
          OptionPickerItem(
            value: type,
            label: _typeLabel(AppLocalizations.of(context), type),
            selected: type == _type,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() => _type = picked);
  }

  Future<void> _pickRegion() async {
    final picked = await showOptionPickerSheet<PlaceOption>(
      context,
      title: AppLocalizations.of(context).usahaFormPickDistrict,
      icon: FLucideIcons.mapPin,
      searchable: true,
      searchHint: AppLocalizations.of(context).usahaFormSearchDistrict,
      items: [
        for (final r in _regions)
          OptionPickerItem(
            value: r,
            label: r.name,
            selected: r.id == _regionId,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() {
      _regionId = picked.id;
      _regionName = picked.name;
      _villageId = null;
      _villageName = null;
      _villages = const [];
    });
    await _loadVillages(picked.id);
  }

  Future<void> _pickVillage() async {
    if (_regionId == null) {
      _validationError(AppLocalizations.of(context).usahaFormDistrictRequired);
      return;
    }
    final picked = await showOptionPickerSheet<PlaceOption>(
      context,
      title: AppLocalizations.of(context).usahaFormPickVillage,
      icon: FLucideIcons.mapPin,
      searchable: true,
      searchHint: AppLocalizations.of(context).usahaFormSearchVillage,
      items: [
        for (final v in _villages)
          OptionPickerItem(
            value: v,
            label: v.name,
            selected: v.id == _villageId,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() {
      _villageId = picked.id;
      _villageName = picked.name;
    });
  }

  /// Validasi gagal -> bottom sheet (pola sama dengan form acara).
  void _validationError(String message) {
    showAppErrorSheet(
      context,
      message: message,
      title: AppLocalizations.of(context).usahaFormIncompleteTitle,
    );
  }

  Future<void> _openMap() async {
    final result = await Navigator.of(context, rootNavigator: true)
        .push<PlacePinPick>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => PlacePinPickerPage(initial: _point),
          ),
        );
    if (result == null || !mounted) return;
    setState(() => _point = result.point);
  }

bool _stepOk() {
    if (_step == 0) {
      if (_name.text.trim().isEmpty || _desc.text.trim().isEmpty) {
        _validationError(AppLocalizations.of(context).placeFormNameDescRequired);
        return false;
      }
      if (slugifyPlace(_name.text).isEmpty) {
        _validationError(AppLocalizations.of(context).placeFormNameInvalid);
        return false;
      }
    }
    if (_step == 1 && _point != null) {
      final lat = _point!.latitude;
      final lng = _point!.longitude;
      if (lat < 1.0 || lat > 1.8 || lng < 108.5 || lng > 110.0) {
        _validationError(AppLocalizations.of(context).placeFormPointOutside);
        return false;
      }
    }
    return true;
  }

Future<void> _submit() async {
  if (_busy) return;
  // Upload sudah berjalan di AttachmentImagesField; submit hanya memakai
  // slot siap (pola form usul kata - upload-then-submit).
  if (_images.any((s) => s.uploading)) {
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).usahaFormWaitUpload),
    );
    return;
  }
  if (_images.any((s) => s.error)) {
    showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).usahaFormRemoveFailedPhoto),
      variant: FToastVariant.destructive,
    );
    return;
  }
  final urls = [
    for (final s in _images)
      if (s.isReady && s.uploaded != null) s.uploaded!.url,
  ];
  if (widget.mode != PlaceContributeMode.photo && !_stepOk()) return;
  setState(() => _busy = true);
  try {
    if (widget.mode == PlaceContributeMode.photo) {
      final slug = widget.slug;
      if (slug == null || urls.isEmpty) {
        throw PlaceContributionException(
            AppLocalizations.of(context).placeFormPhotoRequired,
          );
      }
      await _api.appendImages(slug, urls);
      unawaited(
        AnalyticsService.instance.logWisataContributeSubmit(mode: 'photo'),
      );
      if (!mounted) return;
      showFToast(
      context: context,
      title: Text(AppLocalizations.of(context).placeFormPhotoToast),
    );
      context.pop();
      return;
    }
    final place = _currentPlace();
    await _api.submit({
      if (widget.mode == PlaceContributeMode.edit) 'place_id': place?.id,
      // Slug tidak lagi diisi user: mode edit mempertahankan slug lama
      // (URL tetap stabil), mode create diturunkan dari nama.
      'slug': _slugCtrl.text.trim().isEmpty
          ? slugifyPlace(_name.text)
          : _slugCtrl.text.trim(),
      'name': _name.text.trim(),
      'category': _category,
      if (_type != null) 'type': _type,
      if (_point != null) 'lat': _point!.latitude,
      if (_point != null) 'lng': _point!.longitude,
      'short_description': _desc.text.trim(),
      if (_regionId != null) 'region_id': _regionId,
      if (_villageId != null) 'village_id': _villageId,
      if (_hours.text.trim().isNotEmpty) 'hours': _hours.text.trim(),
      if (_contact.text.trim().isNotEmpty) 'contact': _contact.text.trim(),
      if (urls.isNotEmpty)
        'images': [
          for (final url in urls) {'url': url},
        ],
    });
    unawaited(
      AnalyticsService.instance.logWisataContributeSubmit(
        mode: widget.mode.name,
      ),
    );
    if (!mounted) return;
    context.pushReplacement(ExploreRouter.placeProposals.path);
  } on PlaceContributionException catch (e) {
    if (!mounted) return;
    if (e.code == 'RATE_LIMITED') {
      showFToast(context: context, title: Text(e.message));
    } else {
      await showAppErrorSheet(context, message: e.message);
    }
  } finally {
    if (mounted) setState(() => _busy = false);
  }
}

  Place? _currentPlace() {
    final slug = widget.slug;
    if (slug == null) return null;
    return ref
        .read(placesProvider)
        .value
        ?.where((p) => p.slug == slug)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider);
    final title = switch (widget.mode) {
      PlaceContributeMode.photo => l10n.placeActionAddPhoto,
      PlaceContributeMode.edit => l10n.placeActionSuggestEdit,
      PlaceContributeMode.create => l10n.placeFormTitleCreate,
    };
    final loggedIn = auth.value?.isAuth == true;
    if (widget.mode != PlaceContributeMode.create && !_filled) {
      final place = _currentPlace();
      if (place != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _filled) return;
          setState(() => _apply(place));
        });
      }
    }

    return FScaffold(
      childPad: true,
      resizeToAvoidBottomInset: true,
      header: FHeader.nested(
        title: Text(title),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      child: auth.isLoading
          ? const Center(child: FCircularProgress())
          : !loggedIn
          ? _LoginGate(onLogin: () => context.push('/login'))
          : widget.mode == PlaceContributeMode.photo
          ? _photoBody(l10n)
          : _stepperBody(l10n),
    );
  }

  Widget _photoBody(AppLocalizations l10n) {
    return ListView(
      children: [
        Text(
          l10n.placeFormPhotoBody,
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const Gap(16),
        _imagesField(),
        const Gap(24),
        SafeArea(
          top: false,
          child: FButton(
            onPress: _busy || _images.isEmpty ? null : _submit,
            child: Text(
              _busy ? l10n.placeFormSending : l10n.placeFormSubmitPhoto,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepperBody(AppLocalizations l10n) {
    final labels = [
      l10n.placeFormStepInfo,
      l10n.placeFormStepLocation,
      l10n.placeFormStepContact,
      l10n.placeFormStepPhoto,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.placeFormStepOf(_step + 1, 4, labels[_step]),
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(4),
        Text(
          l10n.placeFormProposalBody,
          style: context.theme.typography.body.xs.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const Gap(12),
        Expanded(
          child: ListView(
            children: [
              if (_step == 0) ..._identity(l10n),
              if (_step == 1) ..._location(l10n),
              if (_step == 2) ..._contactFields(l10n),
              if (_step == 3) _imagesField(),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Row(
            children: [
              if (_step > 0)
                Expanded(
                  child: FButton(
                    variant: .outline,
                    onPress: _busy
                        ? null
                        : () => setState(() {
                            _step -= 1;
                          }),
                    child: Text(l10n.commonBack),
                  ),
                ),
              if (_step > 0) const Gap(8),
              Expanded(
                child: FButton(
                  onPress: _busy
                      ? null
                      : () {
                          if (_step < 3) {
                            if (_stepOk()) setState(() => _step += 1);
                          } else {
                            _submit();
                          }
                        },
                  child: Text(
                    _step < 3
                        ? l10n.placeFormNext
                        : (_busy ? l10n.placeFormSending : l10n.exploreEditSubmit),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _identity(AppLocalizations l10n) => [
    FTextField(
      control: FTextFieldControl.managed(controller: _name),
      label: Text(l10n.placeFormName),
      hint: l10n.placeFormNameHint,
    ),
    const Gap(12),
    _choice(
      l10n.placeFormCategory,
      _type == null ? l10n.placeFormPickCategory : _typeLabel(l10n, _type!),
      _pickCategory,
    ),
    const Gap(12),
    FTextField(
      control: FTextFieldControl.managed(controller: _desc),
      label: Text(l10n.placeFormDescription),
      hint: l10n.placeFormDescriptionHint,
      maxLines: 4,
    ),
  ];

  List<Widget> _location(AppLocalizations l10n) => [
    _choice(
      l10n.usahaFormDistrict,
      _regionName ?? l10n.usahaFormPickDistrict,
      _pickRegion,
    ),
    const Gap(8),
    _choice(
      l10n.profileVillageLabel,
      _villageName ?? l10n.usahaFormPickVillage,
      _pickVillage,
    ),
    const Gap(12),
    Text(
      l10n.placeFormMapHint,
      style: context.theme.typography.body.xs.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    ),
    const Gap(8),
    GestureDetector(
      onTap: _openMap,
      child: AbsorbPointer(
        child: SizedBox(
          height: 220,
          child: _PinMap(point: _point, onPick: (_) {}),
        ),
      ),
    ),
    if (_point != null) ...[
      const Gap(6),
      Text(
        '${_point!.latitude.toStringAsFixed(6)}, ${_point!.longitude.toStringAsFixed(6)}',
        style: context.theme.typography.body.xs.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const Gap(8),
      FButton(
        variant: .outline,
        onPress: () => setState(() => _point = null),
        child: Text(l10n.placePinPickerRemove),
      ),
    ],
  ];

  List<Widget> _contactFields(AppLocalizations l10n) => [
    FTextField(
      control: FTextFieldControl.managed(controller: _hours),
      label: Text(l10n.placeInfoHours),
      hint: l10n.placeFormHoursHint,
    ),
    const Gap(12),
    FTextField(
      control: FTextFieldControl.managed(controller: _contact),
      label: Text(l10n.placeInfoContactNote),
      hint: l10n.placeFormContactHint,
      maxLines: 3,
    ),
  ];

  /// Field foto kanonik (sama dengan form usul kata): sheet kamera/galeri,
  /// upload segera, thumbnail + status + hapus, preview fullscreen.
  Widget _imagesField() {
    return AttachmentImagesField(
      enabled: !_busy,
      maxImages: _maxImages,
      maxSizeMb: 5,
      images: _images,
      onChanged: (next) => setState(() => _images = next),
      upload: (file, {required bool isPrimary}) async {
        try {
          final url = await _api.uploadImage(file);
          return Either.right(
            AttachmentUploadedImage(
              url: url,
              providerFileId: url,
              isPrimary: isPrimary,
            ),
          );
        } on PlaceContributionException catch (e) {
          return Either.left(
            AttachmentUploadFailure(e.message, errorCode: e.code),
          );
        }
      },
    );
  }

  Widget _choice(String label, String value, VoidCallback onPress) {
    return FTile(title: Text(label), subtitle: Text(value), onPress: onPress);
  }
}

class _LoginGate extends StatelessWidget {
  const _LoginGate({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context).placeFormLoginGate,
          style: context.theme.typography.body.sm,
        ),
        const Gap(16),
        FButton(
      onPress: onLogin,
      child: Text(AppLocalizations.of(context).commonLoginRequiredShort),
    ),
      ],
    );
  }
}

class _PinMap extends StatefulWidget {
  const _PinMap({required this.point, required this.onPick});

  final LatLng? point;
  final ValueChanged<LatLng> onPick;

  @override
  State<_PinMap> createState() => _PinMapState();
}

class _PinMapState extends State<_PinMap> {
  MapLibreMapController? _controller;
  var _styleReady = false;

  @override
  void didUpdateWidget(_PinMap old) {
    super.didUpdateWidget(old);
    if (old.point != widget.point) _draw();
  }

  Future<void> _draw() async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;
    await controller.clearCircles();
    final point = widget.point;
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
    // Kamera ikut ke titik baru supaya marker selalu terlihat.
    if (!mounted) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(point, SambasMapConfig.placeZoom),
    );
  }

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
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
        onMapClick: (_, latLng) => widget.onPick(latLng),
      ),
    );
  }
}

String slugifyPlace(String name) {
  final buf = StringBuffer();
  var dash = false;
  for (final unit in name.toLowerCase().codeUnits) {
    final ok = (unit >= 97 && unit <= 122) || (unit >= 48 && unit <= 57);
    if (ok) {
      buf.writeCharCode(unit);
      dash = false;
    } else if (!dash && buf.isNotEmpty) {
      buf.write('-');
      dash = true;
    }
  }
  var slug = buf.toString();
  if (slug.endsWith('-')) slug = slug.substring(0, slug.length - 1);
  if (slug.length > 80) slug = slug.substring(0, 80);
  if (slug.endsWith('-')) slug = slug.substring(0, slug.length - 1);
  return slug;
}

String _typeLabel(AppLocalizations l10n, String id) => switch (id) {
  'sejarah' => l10n.placeTypeSejarah,
  'alam' => l10n.placeTypeAlam,
  'budaya' => l10n.placeTypeBudaya,
  'pantai' => l10n.placeTypePantai,
  'belanja' => l10n.placeTypeBelanja,
  _ => id,
};

String _contactText(Place place) {
  final contact = place.contact;
  if (contact == null || contact.isEmpty) return '';
  return [
    contact.phone,
    contact.email,
    contact.note,
  ].whereType<String>().where((s) => s.isNotEmpty).join('\n');
}
