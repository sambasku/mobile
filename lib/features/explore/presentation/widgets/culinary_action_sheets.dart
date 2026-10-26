import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/culinary_contribution_api.dart';
import '../providers/cuisine_providers.dart';

/// Target usul perbaikan: kuliner (`cuisine_edit`) atau tempat (`place_edit`).
class CulinaryEditTarget {
  const CulinaryEditTarget.cuisine({
    required this.id,
    required this.name,
    required this.description,
    this.ingredients = const [],
  }) : isPlace = false,
       addressText = null;

  const CulinaryEditTarget.place({
    required this.id,
    required this.name,
    required this.description,
    this.addressText,
  }) : isPlace = true,
       ingredients = const [];

  final String id;
  final bool isPlace;
  final String name;
  final String description;
  final String? addressText;
  final List<String> ingredients;
}

/// Alasan laporan - sama dengan `CULINARY_REPORT_REASONS` di API.
const culinaryReportReasons = {
  'closed': 'Tempat sudah tutup',
  'wrong_location': 'Lokasi tidak sesuai',
  'invalid_contact': 'Kontak tidak valid',
  'misleading': 'Informasi menyesatkan',
  'duplicate': 'Dugaan duplikat',
  'abuse': 'Dugaan pelanggaran',
};

/// Aksi kuliner (usul edit, lapor) wajib akun. True = user belum masuk.
Future<bool> culinaryNeedsAuth(BuildContext context, WidgetRef ref) async {
  if (ref.read(authStatusProvider).value?.isAuth == true) return false;
  await showAppErrorSheet(
    context,
    title: 'Masuk dulu ya',
    message:
        'Usul perbaikan dan laporan butuh akun supaya bisa ditindak lanjuti.',
  );
  return true;
}

/// Form usul perbaikan data kuliner/tempat. Hanya field yang benar-benar
/// berubah yang dikirim - server memakai field-lock per bidang.
Future<void> showCulinaryEditSheet(
  BuildContext context,
  WidgetRef ref, {
  required CulinaryEditTarget target,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  useRootNavigator: true,
  builder: (_) => _EditSheet(target: target),
);

/// Pilih alasan laporan (tanpa API call - pemanggil yang kirim).
Future<String?> showCulinaryReasonSheet(
  BuildContext context, {
  required bool isPlace,
}) => showOptionPickerSheet<String>(
  context,
  title: 'Laporkan masalah',
  icon: FLucideIcons.flag,
  subtitle: isPlace
      ? 'Apa yang salah dengan info tempat ini?'
      : 'Apa yang salah dengan info kuliner ini?',
  items: [
    for (final entry in culinaryReportReasons.entries)
      OptionPickerItem(value: entry.key, label: entry.value),
  ],
);

/// Selisih nilai form vs data awal. Hanya field berubah yang masuk `payload`
/// dan `fields` - server menolak usulan tanpa perubahan (`EMPTY_CHANGE`) dan
/// field-lock membandingkan daftar ini.
({Map<String, dynamic> payload, List<String> fields}) culinaryEditDiff({
  required CulinaryEditTarget target,
  required String name,
  required String description,
  String address = '',
  String ingredients = '',
}) {
  final payload = <String, dynamic>{};
  final fields = <String>[];

  void add(String key, String next, String prev) {
    if (next.trim() == prev.trim()) return;
    payload[key] = next.trim();
    fields.add(key);
  }

  add('name', name, target.name);
  add('description', description, target.description);
  if (target.isPlace) {
    add('addressText', address, target.addressText ?? '');
  } else {
    final next = ingredients
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (next.join('|') != target.ingredients.join('|')) {
      payload['ingredients'] = next;
      fields.add('ingredients');
    }
  }
  return (payload: payload, fields: fields);
}

class _EditSheet extends ConsumerStatefulWidget {
  const _EditSheet({required this.target});

  final CulinaryEditTarget target;

  @override
  ConsumerState<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<_EditSheet> {
  late final _name = TextEditingController(text: widget.target.name);
  late final _description = TextEditingController(
    text: widget.target.description,
  );
  late final _address = TextEditingController(
    text: widget.target.addressText ?? '',
  );
  late final _ingredients = TextEditingController(
    text: widget.target.ingredients.join(', '),
  );
  var _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _address.dispose();
    _ingredients.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final target = widget.target;
    final diff = culinaryEditDiff(
      target: target,
      name: _name.text,
      description: _description.text,
      address: _address.text,
      ingredients: _ingredients.text,
    );
    final payload = diff.payload;
    final fields = diff.fields;

    if (fields.isEmpty) {
      await showAppErrorSheet(
        context,
        title: 'Belum ada perubahan',
        message: 'Ubah minimal satu isian dulu ya.',
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .submitChange(
            kind: target.isPlace ? 'place_edit' : 'cuisine_edit',
            cuisineId: target.isPlace ? null : target.id,
            placeId: target.isPlace ? target.id : null,
            payload: payload,
            fields: fields,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      await showAppErrorSheet(
        context,
        title: 'Usulan terkirim',
        message:
            'Admin akan meninjau dulu. Perubahan tayang setelah disetujui.',
      );
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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final target = widget.target;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                target.isPlace
                    ? 'Usul perbaikan data tempat'
                    : 'Usul perbaikan data kuliner',
                style: theme.typography.body.lg.copyWith(fontWeight: .w700),
              ),
              const Gap(4),
              Text(
                'Isi yang kamu tahu saja. Tim admin yang memutuskan.',
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FTextField(
                        control: FTextFieldControl.managed(controller: _name),
                        label: Text(
                          target.isPlace ? 'Nama tempat' : 'Nama kuliner',
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const Gap(10),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: _description,
                        ),
                        label: const Text('Deskripsi'),
                        maxLines: 3,
                      ),
                      const Gap(10),
                      if (target.isPlace)
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: _address,
                          ),
                          label: const Text('Alamat'),
                          maxLines: 2,
                        )
                      else
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: _ingredients,
                          ),
                          label: const Text('Bahan'),
                          hint: 'Pisahkan dengan koma',
                          maxLines: 2,
                        ),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              FButton(
                onPress: _submitting ? null : _submit,
                child: _submitting
                    ? const FCircularProgress(size: .sm)
                    : const Text('Kirim usulan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
