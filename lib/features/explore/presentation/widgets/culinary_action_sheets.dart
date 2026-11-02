import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/culinary_contribution_api.dart';
import '../culinary_labels.dart';
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


/// Aksi kuliner (usul edit, lapor) wajib akun. True = user belum masuk.
Future<bool> culinaryNeedsAuth(BuildContext context, WidgetRef ref) async {
  if (ref.read(authStatusProvider).value?.isAuth == true) return false;
  final l10n = AppLocalizations.of(context);
  await showAppErrorSheet(
    context,
    title: l10n.culinaryLoginTitle,
    message: l10n.exploreActionsLoginBody,
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
      title: AppLocalizations.of(context).usahaReportTitle,
      icon: FLucideIcons.flag,
      subtitle: isPlace
          ? AppLocalizations.of(context).exploreReasonSheetPlaceSubtitle
          : AppLocalizations.of(context).exploreReasonSheetCuisineSubtitle,
      items: [
        for (final code in culinaryReportReasons)
          OptionPickerItem(
            value: code,
            label: culinaryReportReasonLabel(
              AppLocalizations.of(context),
              code,
            ),
          ),
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
        title: AppLocalizations.of(context).exploreEditNoChangeTitle,
        message: AppLocalizations.of(context).exploreEditNoChangeBody,
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
      final l10n = AppLocalizations.of(context);
      await showAppErrorSheet(
        context,
        title: l10n.exploreEditSent,
        message: l10n.exploreEditSentBody,
      );
    } on CulinaryException catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        title: AppLocalizations.of(context).exploreEditFailed,
        message: e.message,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                    ? l10n.exploreEditPlaceTitle
                    : l10n.exploreEditCuisineTitle,
                style: theme.typography.body.lg.copyWith(fontWeight: .w700),
              ),
              const Gap(4),
              Text(
                l10n.exploreEditIntro,
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
                          target.isPlace
                              ? l10n.exploreEditPlaceNameLabel
                              : l10n.exploreEditCuisineNameLabel,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const Gap(10),
                      FTextField(
                        control: FTextFieldControl.managed(
                          controller: _description,
                        ),
                        label: Text(l10n.exploreEditDescriptionLabel),
                        maxLines: 3,
                      ),
                      const Gap(10),
                      if (target.isPlace)
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: _address,
                          ),
                          label: Text(l10n.exploreEditAddressLabel),
                          maxLines: 2,
                        )
                      else
                        FTextField(
                          control: FTextFieldControl.managed(
                            controller: _ingredients,
                          ),
                          label: Text(l10n.exploreEditIngredientsLabel),
                          hint: l10n.exploreEditIngredientsHint,
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
                    : Text(l10n.exploreEditSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
