import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../explore/domain/sambas_map_config.dart';
import '../../../explore/presentation/pages/place_pin_picker_page.dart';
import '../../../explore/presentation/widgets/sambas_map_view.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_contribution.dart';
import '../providers/event_proposals_provider.dart';
import '../providers/event_providers.dart';

/// Form usulan acara. Boleh anonim - server yang mensyaratkan login
/// hanya untuk daftar usulan pribadi.
class EventContributePage extends ConsumerStatefulWidget {
  const EventContributePage({super.key});

  @override
  ConsumerState<EventContributePage> createState() =>
      _EventContributePageState();
}

class _EventContributePageState extends ConsumerState<EventContributePage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _organizer = TextEditingController();
  final _sourceUrl = TextEditingController();
  final _sourceAttribution = TextEditingController();

  String? _categoryId;
  EventSourceType? _sourceType;
  LatLng? _point;

  /// Tanggal (UTC midnight) + jam hasil pilihan pengguna.
  DateTime? _startDate;
  FTime? _startTime;
  DateTime? _endDate;
  FTime? _endTime;

  /// Slot poster (upload segera via AttachmentImagesField, pola form usul kata).
  List<AttachmentImageSlot> _posters = const [];

  /// Batas poster per usulan - samakan dengan validator API (max 10).
  static const _maxPosters = 10;

  var _busy = false;
  var _done = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _location.dispose();
    _organizer.dispose();
    _sourceUrl.dispose();
    _sourceAttribution.dispose();
    super.dispose();
  }

  /// Jadwal gabungan. Tanggal dari FDateField selalu UTC midnight
  /// (lihat `FDateSelectionController`), jam digabung di waktu lokal.
  DateTime? get _startsAt => _combine(_startDate, _startTime);

  DateTime? get _endsAt => _combine(_endDate, _endTime);

  static DateTime? _combine(DateTime? date, FTime? time) {
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Tanggal dari kalender = UTC midnight. Formatnya pakai komponen tanggal
  /// langsung (bukan `toLocal()`) supaya tidak bergeser sehari di zona negatif.
  static String? _dateLabel(DateTime? date) => date == null
      ? null
      : formatDateShort(DateTime(date.year, date.month, date.day));

  /// Tile untuk satu field jadwal - buka bottom sheet saat ditekan.
  FTile _scheduleTile({
    required IconData icon,
    required String title,
    required String? value,
    required String placeholder,
    required VoidCallback onPress,
  }) {
    return FTile(
      prefix: Icon(icon, size: 18),
      title: Text(title),
      subtitle: Text(value ?? placeholder),
      suffix: const Icon(FLucideIcons.chevronRight, size: 18),
      onPress: onPress,
    );
  }

  /// Bottom sheet kalender - hindari popover yang merusak layout form.
  /// [start] membatasi pilihan (tanggal selesai tidak boleh sebelum mulai).
  Future<DateTime?> _pickDate(
    BuildContext context, {
    required String title,
    DateTime? initial,
    DateTime? start,
  }) {
    final selectionController = FDateSelectionController.single(
      initial: initial,
      toggleable: false,
    );
    return showModalBottomSheet<DateTime?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: sheetContext.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(12),
              FCalendar.grid(
                selectionControl: FDateSelectionControl.managedSingle(
                  controller: selectionController,
                ),
                control: FGridCalendarControl(
                  selectable: start == null
                      ? null
                      : (date) => !date.isBefore(start),
                ),
              ),
              const Gap(12),
              FButton(
                onPress: () =>
                    Navigator.of(sheetContext).pop(selectionController.value),
                child: const Text('Pilih tanggal'),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(selectionController.dispose);
  }

  /// Bottom sheet jam - roda jam/menit lebih mudah disentuh daripada popover.
  Future<FTime?> _pickTime(
    BuildContext context, {
    required String title,
    required FTime initial,
  }) {
    var selected = initial;
    return showModalBottomSheet<FTime?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: sheetContext.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(12),
              // Roda butuh tinggi terbatas; 200 = batas popover bawaan Forui.
              SizedBox(
                height: 200,
                child: FTimePicker(
                  hour24: true,
                  control: FTimePickerControl.managed(
                    initial: initial,
                    onChange: (value) => selected = value,
                  ),
                ),
              ),
              const Gap(12),
              FButton(
                onPress: () => Navigator.of(sheetContext).pop(selected),
                child: const Text('Pilih jam'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Peta layar penuh - sama dengan alur usulan wisata.
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

  /// Validasi gagal -> bottom sheet (bukan teks merah inline).
  void _validationError(String message) {
    showAppErrorSheet(context, message: message, title: 'Lengkapi dulu ya');
  }

  Future<void> _submit() async {
    final startsAt = _startsAt;
    final endsAt = _endsAt;
    if (_name.text.trim().isEmpty) {
      _validationError('Nama acara wajib diisi.');
      return;
    }
    if (_description.text.trim().isEmpty) {
      _validationError('Ceritakan singkat acaranya.');
      return;
    }
    if (_categoryId == null) {
      _validationError('Pilih kategori acara dulu.');
      return;
    }
    if (startsAt == null || _startDate == null || _startTime == null) {
      _validationError('Tentukan waktu mulai.');
      return;
    }
    if (endsAt == null || _endDate == null || _endTime == null) {
      _validationError('Tentukan waktu selesai.');
      return;
    }
    if (endsAt.isBefore(startsAt)) {
      _validationError('Waktu selesai tidak boleh sebelum waktu mulai.');
      return;
    }
    if (_location.text.trim().isEmpty) {
      _validationError('Tuliskan lokasi acaranya.');
      return;
    }
    final sourceUrl = _sourceUrl.text.trim();
    if (sourceUrl.isNotEmpty && !sourceUrl.startsWith('https://')) {
      _validationError('Link sumber harus diawali https://');
      return;
    }

    // Poster diunggah segera oleh AttachmentImagesField; submit hanya memakai
    // URL slot siap (upload-then-submit seperti form usul kata).
    if (_posters.any((s) => s.uploading)) {
      _validationError('Tunggu upload poster selesai.');
      return;
    }
    if (_posters.any((s) => s.error)) {
      _validationError('Hapus poster yang gagal diunggah dulu.');
      return;
    }
    final posterUrls = [
      for (final s in _posters)
        if (s.isReady && s.uploaded != null) s.uploaded!.url,
    ];
    setState(() {
      _busy = true;
    });
    try {
      await ref
          .read(eventContributionApiProvider)
          .submit(
            EventContributionDraft(
              name: _name.text.trim(),
              description: _description.text.trim(),
              categoryId: _categoryId!,
              startsAt: startsAt,
              endsAt: endsAt,
              locationText: _location.text.trim(),
              lat: _point?.latitude,
              lng: _point?.longitude,
              organizer: _organizer.text.trim(),
              sourceUrl: sourceUrl,
              sourceType: _sourceType,
              sourceAttribution: _sourceAttribution.text.trim(),
              posterUrls: posterUrls,
            ),
          );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _done = true;
      });
    } on EventContributionException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      await showAppErrorSheet(context, message: e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final categories = ref.watch(eventCategoriesProvider).value ?? const [];

    if (_done) {
      return _SuccessView(
        onBack: () => context.canPop() ? context.pop() : context.go('/explore'),
      );
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Usulkan acara'),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: _busy ? null : _submit,
            child: Text(_busy ? 'Mengirim...' : 'Kirim usulan'),
          ),
        ),
      ),
      child: ListView(
        // Forui sudah beri gutter lewat `childPad` - jangan tambah
        // padding horizontal lagi (bikin konten dobel inset).
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        children: [
          Text(
            'Ceritakan acaranya. Usulan akan ditinjau dulu sebelum tayang ke publik.',
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          FTextField(
            control: FTextFieldControl.managed(controller: _name),
            label: const Text('Nama acara'),
            hint: 'Nama acara',
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _description),
            label: const Text('Deskripsi'),
            hint: 'Ceritakan singkat acaranya',
            maxLines: 4,
          ),
          const Gap(12),
          _CategoryField(
            categories: categories,
            selectedId: _categoryId,
            onPick: (id) => setState(() => _categoryId = id),
          ),
          const Gap(12),
          FTileGroup(
            label: const Text('Jadwal'),
            children: [
              _scheduleTile(
                icon: FLucideIcons.calendar,
                title: 'Tanggal mulai',
                value: _dateLabel(_startDate),
                placeholder: 'Pilih tanggal',
                onPress: () async {
                  final picked = await _pickDate(
                    context,
                    title: 'Tanggal mulai',
                    initial: _startDate,
                  );
                  if (picked == null || !mounted) return;
                  setState(() {
                    _startDate = picked;
                    // Acara satu hari paling umum - isi otomatis.
                    final end = _endDate;
                    if (end == null || end.isBefore(picked)) {
                      _endDate = picked;
                    }
                  });
                },
              ),
              _scheduleTile(
                icon: FLucideIcons.clock,
                title: 'Jam mulai',
                value: _startTime?.toString(),
                placeholder: 'Pilih jam',
                onPress: () async {
                  final picked = await _pickTime(
                    context,
                    title: 'Jam mulai',
                    initial: _startTime ?? const FTime(8),
                  );
                  if (picked == null || !mounted) return;
                  setState(() => _startTime = picked);
                },
              ),
              _scheduleTile(
                icon: FLucideIcons.calendar,
                title: 'Tanggal selesai',
                value: _dateLabel(_endDate),
                placeholder: 'Pilih tanggal',
                onPress: () async {
                  final picked = await _pickDate(
                    context,
                    title: 'Tanggal selesai',
                    initial: _endDate ?? _startDate,
                    start: _startDate,
                  );
                  if (picked == null || !mounted) return;
                  setState(() => _endDate = picked);
                },
              ),
              _scheduleTile(
                icon: FLucideIcons.clock,
                title: 'Jam selesai',
                value: _endTime?.toString(),
                placeholder: 'Pilih jam',
                onPress: () async {
                  final picked = await _pickTime(
                    context,
                    title: 'Jam selesai',
                    initial: _endTime ?? _startTime ?? const FTime(17),
                  );
                  if (picked == null || !mounted) return;
                  setState(() => _endTime = picked);
                },
              ),
            ],
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _location),
            label: const Text('Lokasi'),
            hint: 'Nama tempat atau alamat acara',
          ),
          const Gap(12),
          Text(
            'Ketuk peta untuk memilih koordinat. Opsional.',
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(8),
          GestureDetector(
            onTap: _openMap,
            child: AbsorbPointer(
              child: SizedBox(height: 220, child: _PinMap(point: _point)),
            ),
          ),
          if (_point != null) ...[
            const Gap(6),
            Text(
              '${_point!.latitude.toStringAsFixed(6)}, ${_point!.longitude.toStringAsFixed(6)}',
              style: theme.typography.body.xs.copyWith(
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
          const Gap(12),
          Text(
            'Poster acara',
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
        Text(
          'Bisa lebih dari satu foto. Gambar pertama jadi sampul.',
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
          const Gap(8),
          // Poster - field kanonik (pola form usul kata): sheet kamera/galeri,
          // upload segera, thumbnail + status + hapus. Gambar pertama sampul.
          AttachmentImagesField(
            enabled: !_busy,
            maxImages: _maxPosters,
            maxSizeMb: 5,
            images: _posters,
            onChanged: (next) => setState(() => _posters = next),
            upload: (file, {required bool isPrimary}) async {
              try {
                final url = await ref
                    .read(eventContributionApiProvider)
                    .uploadPoster(file);
                return Either.right(
                  AttachmentUploadedImage(
                    url: url,
                    providerFileId: url,
                    isPrimary: isPrimary,
                  ),
                );
              } on EventContributionException catch (e) {
                return Either.left(
                  AttachmentUploadFailure(e.message, errorCode: e.code),
                );
              }
            },
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _organizer),
            label: const Text('Penyelenggara'),
            hint: 'Opsional',
          ),
          const Gap(20),
          Text(
            'Sumber resmi',
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(4),
          Text(
            'Kalau acaranya ada di Facebook, Instagram, atau website, tempel link-nya di sini.',
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _sourceUrl),
            label: const Text('Link sumber'),
            hint: 'https:// (opsional)',
          ),
          const Gap(12),
          _SourceTypeField(
            selected: _sourceType,
            onPick: (type) => setState(() => _sourceType = type),
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _sourceAttribution),
            label: const Text('Kredit penerbit'),
            hint: 'Opsional, mis. nama panitia',
          ),
        ],
      ),
    );
  }
}

class _PinMap extends StatefulWidget {
  const _PinMap({required this.point});

  final LatLng? point;

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
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Usulan acara'),
        prefixes: [FHeaderAction.back(onPress: onBack)],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.circleCheck,
                size: 44,
                color: theme.colors.primary,
              ),
              const Gap(12),
              Text(
                'Usulan kamu sudah terkirim',
                textAlign: TextAlign.center,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(8),
              Text(
                'Tim kami akan meninjaunya dulu. Kalau lolos, acaranya tayang di daftar acara.',
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(20),
              FButton(
                variant: FButtonVariant.outline,
                onPress: onBack,
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.categories,
    required this.selectedId,
    required this.onPick,
  });

  final List<EventCategoryRef> categories;
  final String? selectedId;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final selected = categories.where((c) => c.id == selectedId).firstOrNull;
    return FTile(
      title: const Text('Kategori'),
      subtitle: Text(selected?.name ?? 'Pilih kategori'),
      suffix: const Icon(FLucideIcons.chevronRight, size: 18),
      onPress: () => _pick(context),
    );
  }

  Future<void> _pick(BuildContext context) async {
    if (categories.isEmpty) return;
    final picked = await showOptionPickerSheet<String>(
      context,
      title: 'Pilih kategori acara',
      icon: FLucideIcons.listFilter,
      items: [
        for (final category in categories)
          OptionPickerItem(
            value: category.id,
            label: category.name,
            selected: category.id == selectedId,
          ),
      ],
    );
    if (picked != null) onPick(picked);
  }
}

class _SourceTypeField extends StatelessWidget {
  const _SourceTypeField({required this.selected, required this.onPick});

  final EventSourceType? selected;
  final ValueChanged<EventSourceType?> onPick;

  @override
  Widget build(BuildContext context) {
    final label = eventSourceTypeLabel(selected) ?? 'Pilih platform (opsional)';
    return FTile(
      title: const Text('Platform sumber'),
      subtitle: Text(label),
      suffix: const Icon(FLucideIcons.chevronRight, size: 18),
      onPress: () => _pick(context),
    );
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showOptionPickerSheet<EventSourceType?>(
      context,
      title: 'Platform sumber',
      icon: FLucideIcons.link,
      items: [
        OptionPickerItem(
          value: null,
          label: 'Tidak ada',
          detail: 'Acara tanpa tautan asal',
          selected: selected == null,
        ),
        for (final type in EventSourceType.values)
          OptionPickerItem(
            value: type,
            label: eventSourceTypeLabel(type) ?? type.name,
            selected: type == selected,
          ),
      ],
    );
    onPick(picked);
  }
}
