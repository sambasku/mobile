import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/place_contribution_api.dart';
import '../../domain/entities/place.dart';
import '../../domain/sambas_map_config.dart';
import '../../explore_router.dart';
import '../providers/places_providers.dart';
import '../widgets/place_option_sheet.dart';
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
  final _slugFocus = FocusNode();

  var _step = 0;
  var _busy = false;
  var _filled = false;
  var _slugTouched = false;
  var _writingSlug = false;
  String _category = 'wisata';
  String? _type;
  String? _regionId;
  String? _regionName;
  String? _villageId;
  String? _villageName;
  LatLng? _point;
  List<PlaceOption> _regions = const [];
  List<PlaceOption> _villages = const [];
  List<XFile> _files = const [];
  String? _hint;

  @override
  void initState() {
    super.initState();
    _name.addListener(_syncSlug);
    _slugCtrl.addListener(() {
      if (_writingSlug) return;
      if (_slugCtrl.text != slugifyPlace(_name.text)) _slugTouched = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLookups());
  }

  @override
  void dispose() {
    _name.dispose();
    _slugCtrl.dispose();
    _desc.dispose();
    _hours.dispose();
    _contact.dispose();
    _slugFocus.dispose();
    super.dispose();
  }

  PlaceContributionApi get _api => PlaceContributionApi(ref.read(dioProvider));

  void _syncSlug() {
    if (_slugTouched || _slugFocus.hasFocus) return;
    final next = slugifyPlace(_name.text);
    if (_slugCtrl.text == next) return;
    _writingSlug = true;
    _slugCtrl.text = next;
    _writingSlug = false;
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
    final picked = await showPlaceOptionSheet(
      context,
      title: 'Pilih kategori',
      selectedId: _type,
      items: [
        for (final type in _types)
          PlaceOption(id: type, name: _typeLabel(type)),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() => _type = picked.id);
  }

  Future<void> _pickRegion() async {
    final picked = await showPlaceOptionSheet(
      context,
      title: 'Pilih kecamatan',
      icon: FLucideIcons.mapPin,
      searchable: true,
      selectedId: _regionId,
      items: _regions,
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
      setState(() => _hint = 'Pilih kecamatan dulu.');
      return;
    }
    final picked = await showPlaceOptionSheet(
      context,
      title: 'Pilih desa',
      icon: FLucideIcons.mapPin,
      searchable: true,
      selectedId: _villageId,
      items: _villages,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _villageId = picked.id;
      _villageName = picked.name;
      _hint = null;
    });
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

  Future<void> _pickFiles() async {
    final max = widget.mode == PlaceContributeMode.photo ? 5 : 20;
    final picked = await ImagePicker().pickMultiImage(limit: max);
    if (!mounted || picked.isEmpty) return;
    setState(() {
      final paths = _files.map((f) => f.path).toSet();
      _files = [
        ..._files,
        ...picked.where((f) => !paths.contains(f.path)),
      ].take(max).toList();
    });
  }

  bool _stepOk() {
    if (_step == 0) {
      if (_name.text.trim().isEmpty || _desc.text.trim().isEmpty) {
        setState(() => _hint = 'Nama dan deskripsi wajib diisi.');
        return false;
      }
      final slug = _slugCtrl.text.trim().isEmpty
          ? slugifyPlace(_name.text)
          : _slugCtrl.text.trim();
      if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(slug)) {
        setState(() => _hint = 'Slug hanya huruf kecil, angka, dan hyphen.');
        return false;
      }
    }
    if (_step == 1 && _point != null) {
      final lat = _point!.latitude;
      final lng = _point!.longitude;
      if (lat < 1.0 || lat > 1.8 || lng < 108.5 || lng > 110.0) {
        setState(() => _hint = 'Titik harus di dalam Kabupaten Sambas.');
        return false;
      }
    }
    setState(() => _hint = null);
    return true;
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (widget.mode != PlaceContributeMode.photo && !_stepOk()) return;
    setState(() => _busy = true);
    try {
      final urls = <String>[];
      for (final file in _files) {
        urls.add(await _api.uploadImage(File(file.path)));
      }
      if (widget.mode == PlaceContributeMode.photo) {
        final slug = widget.slug;
        if (slug == null || urls.isEmpty) {
          throw const PlaceContributionException('Pilih minimal satu foto.');
        }
        await _api.appendImages(slug, urls);
        if (!mounted) return;
        showFToast(context: context, title: const Text('Foto langsung tampil'));
        context.pop();
        return;
      }
      final place = _currentPlace();
      await _api.submit({
        if (widget.mode == PlaceContributeMode.edit) 'place_id': place?.id,
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
    final auth = ref.watch(authStatusProvider);
    final title = switch (widget.mode) {
      PlaceContributeMode.photo => 'Tambah foto',
      PlaceContributeMode.edit => 'Usulkan perubahan',
      PlaceContributeMode.create => 'Usulkan wisata',
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
          ? _photoBody()
          : _stepperBody(),
    );
  }

  Widget _photoBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nama kamu tercantum sebagai kredit. Foto ke tempat yang sudah terbit langsung tampil.',
          style: context.theme.typography.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const Gap(16),
        FButton(
          onPress: _busy ? null : _pickFiles,
          child: Text(
            _files.isEmpty ? 'Pilih foto' : '${_files.length} foto dipilih',
          ),
        ),
        const Spacer(),
        SafeArea(
          top: false,
          child: FButton(
            onPress: _busy || _files.isEmpty ? null : _submit,
            child: Text(_busy ? 'Mengirim...' : 'Kirim foto'),
          ),
        ),
      ],
    );
  }

  Widget _stepperBody() {
    const labels = ['Informasi umum', 'Lokasi', 'Kontak', 'Foto'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Langkah ${_step + 1} dari 4: ${labels[_step]}',
          style: context.theme.typography.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(4),
        Text(
          'Nama kamu tercantum sebagai kredit. Usulan akan ditinjau terlebih dahulu sebelum tayang ke publik.',
          style: context.theme.typography.xs.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
        const Gap(12),
        Expanded(
          child: ListView(
            children: [
              if (_step == 0) ..._identity(),
              if (_step == 1) ..._location(),
              if (_step == 2) ..._contactFields(),
              if (_step == 3) ..._photos(),
              if (_hint != null) ...[
                const Gap(12),
                Text(
                  _hint!,
                  style: context.theme.typography.sm.copyWith(
                    color: context.theme.colors.destructive,
                  ),
                ),
              ],
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
                            _hint = null;
                          }),
                    child: const Text('Kembali'),
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
                        ? 'Lanjut'
                        : (_busy ? 'Mengirim...' : 'Kirim usulan'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _identity() => [
    FTextField(
      control: FTextFieldControl.managed(controller: _name),
      label: const Text('Nama'),
      hint: 'Nama tempat',
    ),
    const Gap(12),
    FTextField(
      control: FTextFieldControl.managed(controller: _slugCtrl),
      focusNode: _slugFocus,
      label: const Text('Slug'),
      hint: 'otomatis dari nama',
    ),
    const Gap(12),
    _choice(
      'Kategori',
      _type == null ? 'Pilih kategori' : _typeLabel(_type!),
      _pickCategory,
    ),
    const Gap(12),
    FTextField(
      control: FTextFieldControl.managed(controller: _desc),
      label: const Text('Deskripsi'),
      hint: 'Ceritakan tempat ini',
      maxLines: 4,
    ),
  ];

  List<Widget> _location() => [
    _choice('Kecamatan', _regionName ?? 'Pilih kecamatan', _pickRegion),
    const Gap(8),
    _choice('Desa', _villageName ?? 'Pilih desa', _pickVillage),
    const Gap(12),
    Text(
      'Ketuk peta untuk memilih koordinat. Opsional.',
      style: context.theme.typography.xs.copyWith(
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
        style: context.theme.typography.xs.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      const Gap(8),
      FButton(
        variant: .outline,
        onPress: () => setState(() => _point = null),
        child: const Text('Hapus koordinat'),
      ),
    ],
  ];

  List<Widget> _contactFields() => [
    FTextField(
      control: FTextFieldControl.managed(controller: _hours),
      label: const Text('Jam buka'),
      hint: 'Opsional',
    ),
    const Gap(12),
    FTextField(
      control: FTextFieldControl.managed(controller: _contact),
      label: const Text('Kontak'),
      hint: 'Nomor, email, atau catatan',
      maxLines: 3,
    ),
  ];

  List<Widget> _photos() {
    final theme = context.theme;
    final max = widget.mode == PlaceContributeMode.photo ? 5 : 20;
    return [
      Text(
        _files.isEmpty
            ? 'Foto opsional, maksimal $max.'
            : '${_files.length} dari $max foto dipilih.',
        style: context.theme.typography.sm,
      ),
      const Gap(12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var i = 0; i < _files.length; i++)
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_files[i].path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: theme.colors.muted,
                          child: Icon(
                            FLucideIcons.image,
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _files = [..._files]..removeAt(i)),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: theme.colors.destructive,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          FLucideIcons.x,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_files.length < max)
            InkWell(
              onTap: _pickFiles,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colors.border),
                ),
                child: Icon(
                  FLucideIcons.plus,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
        ],
      ),
      if (_files.isEmpty) ...[
        const Gap(12),
        FButton(onPress: _pickFiles, child: const Text('Pilih foto')),
      ],
    ];
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
          'Masuk dulu untuk mengusulkan tempat. Nama kamu tercantum sebagai kredit.',
          style: context.theme.typography.sm,
        ),
        const Gap(16),
        FButton(onPress: onLogin, child: const Text('Masuk')),
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

String _typeLabel(String id) => switch (id) {
  'sejarah' => 'Sejarah',
  'alam' => 'Alam',
  'budaya' => 'Budaya',
  'pantai' => 'Pantai',
  'belanja' => 'Belanja',
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
