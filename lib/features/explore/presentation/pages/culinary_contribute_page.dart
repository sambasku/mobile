import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/culinary_contribution_api.dart';
import '../providers/cuisine_providers.dart';

enum CulinaryContributeMode { cuisine, place, link }

/// Lisensi baku foto warga (PRD kuliner): foto yang diunggah dari app
/// otomatis CC BY-SA 4.0 dan diatribusikan ke akun pengunggah.
const _ccBySa = 'CC BY-SA 4.0';

/// Form usulan kuliner. Tiga mode dalam satu layar supaya warga tidak
/// bingung memilih alur:
/// - [CulinaryContributeMode.cuisine] kuliner baru (boleh anonim)
/// - [CulinaryContributeMode.place] tempat/penjual baru (boleh anonim)
/// - [CulinaryContributeMode.link] tandai "tempat X jual kuliner Y" (wajib akun)
class CulinaryContributePage extends ConsumerStatefulWidget {
  const CulinaryContributePage({super.key, required this.mode});

  final CulinaryContributeMode mode;

  @override
  ConsumerState<CulinaryContributePage> createState() =>
      _CulinaryContributePageState();
}

class _CulinaryContributePageState
    extends ConsumerState<CulinaryContributePage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _ingredients = TextEditingController();
  final _address = TextEditingController();
  final _locationHint = TextEditingController();
  /// Slug tidak ditampilkan ke user - dipilih lewat nama, slug dikirim diam-diam.
  String? _cuisineSlug;
  String? _placeSlug;
  List<AttachmentImageSlot> _images = const [];
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [
      _name,
      _description,
      _ingredients,
      _address,
      _locationHint,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _warn(String message) {
    showAppErrorSheet(context, title: 'Lengkapi dulu ya', message: message);
  }

  String get _title => switch (widget.mode) {
    CulinaryContributeMode.cuisine => 'Usul kuliner',
    CulinaryContributeMode.place => 'Usul tempat',
    CulinaryContributeMode.link => 'Tandai penjual',
  };

  Future<void> _submit() async {
    final api = ref.read(culinaryContributionApiProvider);
    if (widget.mode == CulinaryContributeMode.link) {
      final cuisine = _cuisineSlug;
      final place = _placeSlug;
      if (cuisine == null || place == null) {
        _warn('Pilih kuliner dan tempatnya dulu ya.');
        return;
      }
      setState(() => _submitting = true);
      try {
        await api.submitLink(cuisineSlug: cuisine, placeSlug: place);
        if (!mounted) return;
        await _done();
      } on CulinaryException catch (e) {
        if (!mounted) return;
        await showAppErrorSheet(
          context,
          title: 'Usulan gagal',
          message: e.message,
        );
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
      return;
    }

    final name = _name.text.trim();
    if (name.length < 3) {
      _warn('Nama minimal 3 huruf ya.');
      return;
    }

    // Upload sudah berjalan di AttachmentImagesField (pola form usul kata);
    // submit hanya memakai URL slot siap.
    if (_images.any((s) => s.uploading)) {
      showFToast(context: context, title: const Text('Tunggu upload foto selesai'));
      return;
    }
    if (_images.any((s) => s.error)) {
      showFToast(
        context: context,
        title: const Text('Hapus foto yang gagal diunggah dulu'),
        variant: FToastVariant.destructive,
      );
      return;
    }
    final imageUrl = _images
        .where((s) => s.isReady && s.uploaded != null)
        .firstOrNull
        ?.uploaded!
        .url;
    setState(() => _submitting = true);
    try {
      // Atribusi otomatis: pemilik = nama tampilan akun (login) atau
      // "Warga SambasKu" (anonim), lisensi selalu CC BY-SA 4.0 (PRD kuliner).
      final auth = ref.read(authStatusProvider).value;
      final owner = (auth?.displayName ?? '').trim().isNotEmpty
          ? auth!.displayName!.trim()
          : auth?.username?.trim() ?? '';
      final images = imageUrl == null || imageUrl.isEmpty
          ? const <Map<String, dynamic>>[]
          : [
              {
                'url': imageUrl,
                'is_main': true,
                'attribution': {
                  'name': owner.isNotEmpty ? owner : 'Warga SambasKu',
                  'license': _ccBySa,
                },
              },
            ];

      if (widget.mode == CulinaryContributeMode.cuisine) {
        await api.submitNewCuisine(
          name: name,
          description: _description.text,
          ingredients: _ingredients.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
          images: images,
        );
      } else {
        await api.submitNewPlace(
          name: name,
          description: _description.text,
          addressText: _address.text,
          locationHint: _locationHint.text,
        );
      }
      if (!mounted) return;
      await _done();
    } on CulinaryException catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        title: 'Usulan gagal',
        message: e.message,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _done() async {
    await showAppErrorSheet(
      context,
      title: 'Usulan terkirim',
      message:
          'Admin akan meninjau dulu. Terima kasih sudah bantu lengkapi data kuliner Sambas.',
    );
    if (!mounted) return;
    context.canPop() ? context.pop() : context.go('/explore/cuisine');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isLink = widget.mode == CulinaryContributeMode.link;
    final isCuisine = widget.mode == CulinaryContributeMode.cuisine;
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(_title),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go('/explore/cuisine'),
          ),
        ],
      ),
      // Tombol kiri di footer (pola event_contribute_page) supaya seragam.
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
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        children: [
          Text(
            isLink
                ? 'Bantu hubungkan kuliner dengan tempat yang menjualnya. Wajib masuk dulu.'
                : 'Isi yang kamu tahu saja. Nama wajib, sisanya boleh menyusul - admin bisa melengkapi.',
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          if (isLink) ...[
            // Slug tidak ditampilkan: user pilih dari nama, slug dikirim
            // diam-diam ke API (kontrak wire tetap slug).
            // ponytail: pilihan dibatasi halaman pertama katalog (client-side
            // search). Ganti filter server (`q`) kalau katalog membesar.
            FSelect<String>.search(
              items: {
                for (final c in ref.watch(cuisineProvider).value ?? [])
                  c.name: c.slug,
              },
              label: const Text('Kuliner'),
              hint: 'Cari kuliner',
              control: FSelectControl.managed(
                initial: _cuisineSlug,
                onChange: (value) => setState(() => _cuisineSlug = value),
              ),
            ),
            const Gap(10),
            FSelect<String>.search(
              items: {
                for (final p
                    in ref.watch(culinaryPlacesProvider()).value?.items ?? [])
                  p.name: p.slug,
              },
              label: const Text('Tempat/penjual'),
              hint: 'Cari tempat',
              control: FSelectControl.managed(
                initial: _placeSlug,
                onChange: (value) => setState(() => _placeSlug = value),
              ),
            ),
          ] else ...[
            FTextField(
              control: FTextFieldControl.managed(controller: _name),
              label: Text(isCuisine ? 'Nama kuliner' : 'Nama tempat'),
              hint: isCuisine ? 'Nama kuliner' : 'Nama tempat atau penjual',
              textCapitalization: TextCapitalization.words,
            ),
            const Gap(10),
            FTextField(
              control: FTextFieldControl.managed(controller: _description),
              label: const Text('Deskripsi (opsional)'),
              maxLines: 4,
            ),
            const Gap(10),
            if (isCuisine)
              FTextField(
                control: FTextFieldControl.managed(controller: _ingredients),
                label: const Text('Bahan (opsional)'),
                hint: 'Pisahkan dengan koma',
                maxLines: 2,
              )
            else ...[
              FTextField(
                control: FTextFieldControl.managed(controller: _address),
                label: const Text('Alamat (opsional)'),
                hint: 'Jalan, nomor, patokan',
                maxLines: 2,
              ),
              const Gap(10),
              FTextField(
                control: FTextFieldControl.managed(controller: _locationHint),
                label: const Text('Patokan lokasi (opsional)'),
                hint: 'Depan pasar, sebelah masjid',
              ),
            ],
          if (isCuisine) ...[
            const Gap(16),
            // Foto opsional - field kanonik (pola form usul kata): sheet
            // kamera/galeri, upload segera, thumbnail + status + hapus.
            AttachmentImagesField(
              enabled: !_submitting,
              maxImages: 1,
              maxSizeMb: 5,
              images: _images,
              onChanged: (next) => setState(() => _images = next),
              upload: (file, {required bool isPrimary}) async {
                try {
                  final url = await ref
                      .read(culinaryContributionApiProvider)
                      .uploadImage(file);
                  return Either.right(
                    AttachmentUploadedImage(
                      url: url,
                      providerFileId: url,
                      isPrimary: isPrimary,
                    ),
                  );
                } on CulinaryException catch (e) {
                  return Either.left(
                    AttachmentUploadFailure(e.message, errorCode: e.code),
                  );
                }
              },
            ),
            // Foto dari app otomatis CC BY-SA atas nama pengunggah -
            // tidak perlu form atribusi manual (PRD kuliner).
            if (_images.isNotEmpty) ...[
              const Gap(8),
              Text(
                'Foto akan diatribusikan ke namamu dengan lisensi $_ccBySa.',
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ],
          ],
        ],
      ),
    );
  }
}
