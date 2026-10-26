import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../explore/domain/entities/region.dart';
import '../../../explore/presentation/pages/place_pin_picker_page.dart';
import '../../../explore/presentation/providers/regions_providers.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../providers/usaha_providers.dart';

/// Form usulan usaha baru. Boleh anonim - minimum nama + kecamatan.
class UsahaContributePage extends ConsumerStatefulWidget {
  const UsahaContributePage({super.key});

  @override
  ConsumerState<UsahaContributePage> createState() =>
      _UsahaContributePageState();
}

class _UsahaContributePageState extends ConsumerState<UsahaContributePage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _website = TextEditingController();
  final _social = TextEditingController();

  String? _categoryId;
  String? _categoryName;
  UsahaKind _kind = UsahaKind.product;
  Region? _kecamatan;
  Region? _desa;
  LatLng? _point;
  List<AttachmentImageSlot> _cover = const [];
  bool _wantsClaim = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _address.dispose();
    _phone.dispose();
    _website.dispose();
    _social.dispose();
    super.dispose();
  }

  void _warn(String message) {
    showAppErrorSheet(context, title: 'Lengkapi dulu ya', message: message);
  }

  Future<void> _pickCategory() async {
    // Tunggu kategori selesai load (ref.read(.value) bisa null kalau
    // provider belum resolve - list jadi kosong padahal data ada).
    final categories = await ref.read(usahaCategoriesProvider.future);
    if (!mounted) return;
    final picked = await showOptionPickerSheet<UsahaCategoryRef>(
      context,
      title: 'Pilih kategori usaha',
      icon: FLucideIcons.tags,
      searchable: true,
      searchHint: 'Cari kategori',
      items: [
        for (final c in categories)
          OptionPickerItem(
            value: c,
            label: c.name,
            selected: c.id == _categoryId,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() {
      _categoryId = picked.id;
      _categoryName = picked.name;
    });
  }

  Future<void> _pickKind() async {
    final picked = await showOptionPickerSheet<UsahaKind>(
      context,
      title: 'Jenis usaha',
      icon: FLucideIcons.store,
      items: [
        for (final kind in UsahaKind.values)
          OptionPickerItem(
            value: kind,
            label: usahaKindLabel(kind),
            selected: kind == _kind,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() => _kind = picked);
  }

  Future<void> _pickKecamatan() async {
    // Tunggu regions selesai load (ref.read(.value) bisa null kalau belum
    // pernah buka explore - list jadi kosong padahal data ada).
    final regionsAsync = await ref.read(regionsProvider.future);
    final regions = regionsAsync ?? const <Region>[];
    if (!mounted) return;
    final picked = await showOptionPickerSheet<Region>(
      context,
      title: 'Pilih kecamatan',
      icon: FLucideIcons.mapPin,
      searchable: true,
      searchHint: 'Cari kecamatan',
      items: [
        for (final r in regions.where((r) => r.type == RegionType.kecamatan))
          OptionPickerItem(
            value: r,
            label: r.name,
            selected: r.id == _kecamatan?.id,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() {
      _kecamatan = picked;
      _desa = null;
    });
  }

  Future<void> _pickDesa() async {
    final kecamatan = _kecamatan;
    if (kecamatan == null) {
      _warn('Pilih kecamatan dulu ya.');
      return;
    }
    // Tunggu regions selesai load (ref.read(.value) bisa null kalau belum
    // pernah buka explore - list jadi kosong padahal data ada).
    final regionsAsync = await ref.read(regionsProvider.future);
    final regions = regionsAsync ?? const <Region>[];
    if (!mounted) return;
    final picked = await showOptionPickerSheet<Region>(
      context,
      title: 'Pilih desa',
      icon: FLucideIcons.mapPin,
      searchable: true,
      searchHint: 'Cari desa',
      items: [
        for (final r in regions.where(
          (r) => r.type == RegionType.desa && r.parentId == kecamatan.id,
        ))
          OptionPickerItem(
            value: r,
            label: r.name,
            selected: r.id == _desa?.id,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() => _desa = picked);
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

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.length < 3) {
      _warn('Nama usaha minimal 3 huruf ya.');
      return;
    }
    final kecamatan = _kecamatan;
    if (kecamatan == null) {
      _warn('Pilih kecamatan lokasi usaha dulu.');
      return;
    }
    // Foto utama diunggah segera oleh AttachmentImagesField; guard supaya
    // cover yang masih upload/gagal tidak didrop diam-diam saat submit.
    if (_cover.any((s) => s.uploading)) {
      showFToast(
        context: context,
        title: const Text('Tunggu upload foto selesai'),
      );
      return;
    }
    if (_cover.any((s) => s.error)) {
      showFToast(
        context: context,
        title: const Text('Hapus foto yang gagal diunggah dulu'),
        variant: FToastVariant.destructive,
      );
      return;
    }
    setState(() => _submitting = true);
    final api = ref.read(usahaContributionApiProvider);
    // Submit hanya memakai URL hasil upload (upload-then-submit).
    final coverUrl = _cover.isNotEmpty && _cover.first.isReady
        ? _cover.first.uploaded?.url
        : null;
    try {
      await api.submit(
        UsahaContributionDraft(
          name: name,
          regionId: kecamatan.id,
          description: _description.text.trim(),
          categoryId: _categoryId,
          kind: _kind,
          villageId: _desa?.id,
          addressText: _address.text.trim(),
          lat: _point?.latitude,
          lng: _point?.longitude,
          phone: _phone.text.trim(),
          website: _website.text.trim(),
          socialUrl: _social.text.trim(),
          coverUrl: coverUrl,
          wantsClaim: _wantsClaim,
        ),
      );
      if (!mounted) return;
      final goProposals = await showModalBottomSheet<bool>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (ctx) => SafeArea(
          top: false,
          child: FTileGroup(
            children: [
              FTile(
                title: const Text('Usulan terkirim'),
                subtitle: const Text(
                  'Admin akan meninjau dulu. Statusnya bisa kamu pantau di Usulan saya.',
                ),
              ),
              FTile(
                title: const Text('Lihat usulan saya'),
                onPress: () => Navigator.pop(ctx, true),
              ),
              FTile(
                title: const Text('Kembali ke daftar usaha'),
                onPress: () => Navigator.pop(ctx, false),
              ),
            ],
          ),
        ),
      );
      if (!mounted) return;
      if (goProposals == true) {
        context.pushReplacement(UsahaRouter.proposals.path);
      } else {
        context.go(UsahaRouter.list.path);
      }
    } on UsahaException catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: e.message,
        title: 'Usulan gagal',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Usulkan usaha'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(UsahaRouter.list.path),
          ),
        ],
      ),
      // Tombol kirim di footer (seragam dengan form usulan lain).
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: _submitting ? null : _submit,
            child: _submitting
                ? const FCircularProgress(size: .sm)
                : const Text('Kirim usulan'),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          Text(
            'Isi yang kamu tahu saja. Nama dan kecamatan wajib, sisanya boleh menyusul - admin bisa melengkapi.',
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          FTextField(
            control: FTextFieldControl.managed(controller: _name),
            label: const Text('Nama usaha'),
            hint: 'Nama usaha atau jasa',
            textCapitalization: TextCapitalization.words,
          ),
          const Gap(10),
          FTextField(
            control: FTextFieldControl.managed(controller: _description),
            label: const Text('Deskripsi (opsional)'),
            hint: 'Apa yang dijual atau jasa yang ditawarkan',
            maxLines: 4,
          ),
          const Gap(16),
          FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.tags, size: 18),
                title: const Text('Kategori'),
                subtitle: Text(_categoryName ?? 'Belum dipilih'),
                onPress: _pickCategory,
              ),
              FTile(
                prefix: const Icon(FLucideIcons.store, size: 18),
                title: const Text('Jenis'),
                subtitle: Text(usahaKindLabel(_kind)),
                onPress: _pickKind,
              ),
              FTile(
                prefix: const Icon(FLucideIcons.mapPin, size: 18),
                title: const Text('Kecamatan'),
                subtitle: Text(_kecamatan?.name ?? 'Wajib dipilih'),
                onPress: _pickKecamatan,
              ),
              FTile(
                prefix: const Icon(FLucideIcons.signpost, size: 18),
                title: const Text('Desa (opsional)'),
                subtitle: Text(_desa?.name ?? 'Belum dipilih'),
                onPress: _pickDesa,
              ),
            ],
          ),
          const Gap(10),
          FTextField(
            control: FTextFieldControl.managed(controller: _address),
            label: const Text('Alamat atau petunjuk lokasi (opsional)'),
            hint: 'Jalan, nomor, atau patokan',
            maxLines: 2,
          ),
          const Gap(10),
          FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.mapPinned, size: 18),
                title: const Text('Tandai di peta (opsional)'),
                subtitle: Text(
                  _point == null
                      ? 'Bantu pengunjung menemukan lokasi'
                      : '${_point!.latitude.toStringAsFixed(5)}, ${_point!.longitude.toStringAsFixed(5)}',
                ),
                onPress: _openMap,
              ),
            ],
          ),
          const Gap(16),
          Text(
            'Kontak (opsional)',
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          // Satu nomor untuk telepon + WhatsApp; backend mengisi whatsapp
          // dari phone (lihat toNewPayload di usaha-contribution.controller).
          FTextField(
            control: FTextFieldControl.managed(controller: _phone),
            label: const Text('No. HP'),
            hint: '0812xxxxxxx',
            keyboardType: TextInputType.phone,
          ),
          const Gap(10),
          FTextField(
            control: FTextFieldControl.managed(controller: _website),
            label: const Text('Website (https)'),
            hint: 'https://...',
            keyboardType: TextInputType.url,
          ),
          const Gap(10),
          FTextField(
            control: FTextFieldControl.managed(controller: _social),
            label: const Text('Media sosial (https)'),
            hint: 'https://instagram.com/...',
            keyboardType: TextInputType.url,
          ),
        const Gap(16),
        FTileGroup(
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.keyRound, size: 18),
              title: const Text('Ini usaha saya'),
                subtitle: const Text(
                  'Kami buatkan klaim pengelolaan, supaya kamu bisa usul perubahan.',
                ),
                suffix: FSwitch(
                  semanticsLabel: 'Ini usaha saya',
                  value: _wantsClaim,
                  onChange: (value) => setState(() => _wantsClaim = value),
                ),
              ),
            ],
          ),
          const Gap(12),
          // Panel foto seragam dengan form usul kata / diskusi
          // (AttachmentImagesField kanonik: sheet kamera/galeri, upload
          // segera, thumbnail + status upload + hapus di pojok).
          AttachmentImagesField(
            enabled: !_submitting,
            maxImages: 1,
            maxSizeMb: 5,
            images: _cover,
            onChanged: (next) => setState(() => _cover = next),
            upload: (file, {required bool isPrimary}) async {
              try {
                final url = await ref
                    .read(usahaContributionApiProvider)
                    .uploadImage(file);
                return Either.right(
                  AttachmentUploadedImage(
                    url: url,
                    providerFileId: url,
                    isPrimary: true,
                  ),
                );
              } on UsahaException catch (e) {
                return Either.left(AttachmentUploadFailure(e.message));
              }
            },
          ),
        ],
      ),
    );
  }
}

