import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/error_bottom_sheet.dart';
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

  /// Tanggal (UTC midnight) + jam hasil pilihan pengguna.
  DateTime? _startDate;
  FTime? _startTime;
  DateTime? _endDate;
  FTime? _endTime;

  var _busy = false;
  var _done = false;
  String? _hint;

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

  Future<void> _submit() async {
    final startsAt = _startsAt;
    final endsAt = _endsAt;
    if (_name.text.trim().isEmpty) {
      setState(() => _hint = 'Nama acara wajib diisi.');
      return;
    }
    if (_description.text.trim().isEmpty) {
      setState(() => _hint = 'Ceritakan singkat acaranya.');
      return;
    }
    if (_categoryId == null) {
      setState(() => _hint = 'Pilih kategori acara dulu.');
      return;
    }
    if (startsAt == null || _startDate == null || _startTime == null) {
      setState(() => _hint = 'Tentukan waktu mulai.');
      return;
    }
    if (endsAt == null || _endDate == null || _endTime == null) {
      setState(() => _hint = 'Tentukan waktu selesai.');
      return;
    }
    if (endsAt.isBefore(startsAt)) {
      setState(() => _hint = 'Waktu selesai tidak boleh sebelum waktu mulai.');
      return;
    }
    if (_location.text.trim().isEmpty) {
      setState(() => _hint = 'Tuliskan lokasi acaranya.');
      return;
    }
    final sourceUrl = _sourceUrl.text.trim();
    if (sourceUrl.isNotEmpty && !sourceUrl.startsWith('https://')) {
      setState(() => _hint = 'Link sumber harus diawali https://');
      return;
    }

    setState(() {
      _busy = true;
      _hint = null;
    });
    try {
      await ref.read(eventContributionApiProvider).submit(
        EventContributionDraft(
          name: _name.text.trim(),
          description: _description.text.trim(),
          categoryId: _categoryId!,
          startsAt: startsAt,
          endsAt: endsAt,
          locationText: _location.text.trim(),
          organizer: _organizer.text.trim(),
          sourceUrl: sourceUrl,
          sourceType: _sourceType,
          sourceAttribution: _sourceAttribution.text.trim(),
        ),
      );
      if (!mounted) return;
      setState(() {
        _busy = false;
        _done = true;
      });
    } on EventContributionException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _hint = e.message;
      });
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
      child: Column(
        children: [
          Expanded(
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
                  hint: 'Contoh: Pawai Blocks Keywords 2026',
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
                FDateField.calendar(
                  selectionControl: FDateSelectionControl.liftedSingle(
                    value: _startDate,
                    onChange: (value) => setState(() => _startDate = value),
                  ),
                  label: const Text('Tanggal mulai'),
                  hint: 'Pilih tanggal',
                ),
                const Gap(12),
                FTimeField.picker(
                  control: FTimeFieldControl.lifted(
                    time: _startTime,
                    onChange: (value) => setState(() => _startTime = value),
                  ),
                  label: const Text('Jam mulai'),
                  hint: 'Pilih jam',
                ),
                const Gap(12),
                FDateField.calendar(
                  selectionControl: FDateSelectionControl.liftedSingle(
                    value: _endDate,
                    onChange: (value) => setState(() => _endDate = value),
                  ),
                  label: const Text('Tanggal selesai'),
                  hint: 'Pilih tanggal',
                ),
                const Gap(12),
                FTimeField.picker(
                  control: FTimeFieldControl.lifted(
                    time: _endTime,
                    onChange: (value) => setState(() => _endTime = value),
                  ),
                  label: const Text('Jam selesai'),
                  hint: 'Pilih jam',
                ),
                const Gap(12),
                FTextField(
                  control: FTextFieldControl.managed(controller: _location),
                  label: const Text('Lokasi'),
                  hint: 'Nama tempat atau alamat acara',
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
                  control: FTextFieldControl.managed(
                    controller: _sourceAttribution,
                  ),
                  label: const Text('Kredit penerbit'),
                  hint: 'Opsional, mis. nama panitia',
                ),
                if (_hint != null) ...[
                  const Gap(12),
                  Text(
                    _hint!,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.destructive,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: FButton(
              onPress: _busy ? null : _submit,
              child: Text(_busy ? 'Mengirim...' : 'Kirim usulan'),
            ),
          ),
        ],
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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          children: [
            for (final category in categories)
              FTile(
                title: Text(category.name),
                suffix: category.id == selectedId
                    ? const Icon(FLucideIcons.check, size: 18)
                    : null,
                onPress: () {
                  onPick(category.id);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
          children: [
            FTile(
              title: const Text('Tidak ada'),
              onPress: () {
                onPick(null);
                Navigator.of(sheetContext).pop();
              },
            ),
            for (final type in EventSourceType.values)
              FTile(
                title: Text(eventSourceTypeLabel(type) ?? type.name),
                suffix: type == selected
                    ? const Icon(FLucideIcons.check, size: 18)
                    : null,
                onPress: () {
                  onPick(type);
                  Navigator.of(sheetContext).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}
