import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/error_bottom_sheet.dart';
import '../../../shared/widgets/option_picker_sheet.dart';
import '../../explore/domain/entities/region.dart';
import '../../explore/presentation/providers/regions_providers.dart';
import '../data/layanan_api.dart';
import '../layanan_router.dart';
import 'layanan_providers.dart';

class _PhoneDraft {
  _PhoneDraft()
      : phone = TextEditingController(),
        note = TextEditingController(),
        whatsapp = TextEditingController();

  final TextEditingController phone;
  final TextEditingController note;
  final TextEditingController whatsapp;

  void dispose() {
    phone.dispose();
    note.dispose();
    whatsapp.dispose();
  }
}

class LayananContributePage extends ConsumerStatefulWidget {
  const LayananContributePage({
    super.key,
    this.regionId,
    this.layananId,
    this.category,
  });

  final String? regionId;
  final String? layananId;
  final String? category;

  @override
  ConsumerState<LayananContributePage> createState() =>
      _LayananContributePageState();
}

class _LayananContributePageState extends ConsumerState<LayananContributePage> {
  static const _maxPhones = 5;

  final _name = TextEditingController();
  final _logoUrl = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();
  final _phones = <_PhoneDraft>[_PhoneDraft()];
  late String _category;
  String? _regionId;
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _category = widget.category == 'fire' ? 'fire' : 'ambulance';
    _regionId = widget.regionId;
  }

  @override
  void dispose() {
    _name.dispose();
    _logoUrl.dispose();
    _address.dispose();
    _note.dispose();
    for (final row in _phones) {
      row.dispose();
    }
    super.dispose();
  }

  void _addPhone() {
    if (_phones.length >= _maxPhones) return;
    setState(() => _phones.add(_PhoneDraft()));
  }

  void _removePhone(int index) {
    if (_phones.length <= 1) return;
    setState(() {
      _phones.removeAt(index).dispose();
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final phones = <Map<String, String?>>[];
    for (final row in _phones) {
      final phone = row.phone.text.trim();
      if (phone.length < 8) continue;
      phones.add({
        'phone': phone,
        if (row.note.text.trim().isNotEmpty) 'note': row.note.text.trim(),
        if (row.whatsapp.text.trim().isNotEmpty)
          'whatsapp': row.whatsapp.text.trim(),
      });
    }
    if (_name.text.trim().length < 3 || phones.isEmpty || _regionId == null) {
      await showAppErrorSheet(context, message: l10n.layananFormInvalid);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(layananApiProvider).submit({
        'kind': widget.layananId == null ? 'new' : 'edit',
        if (widget.layananId != null) 'layanan_id': widget.layananId,
        'category': _category,
        'name': _name.text.trim(),
        'phones': phones,
        'region_id': _regionId,
        if (_logoUrl.text.trim().isNotEmpty) 'logo_url': _logoUrl.text.trim(),
        if (_address.text.trim().isNotEmpty) 'address_text': _address.text.trim(),
        if (_note.text.trim().isNotEmpty) 'note': _note.text.trim(),
      });
      if (!mounted) return;
      context.pushReplacement(LayananRouter.proposals.path);
    } catch (error) {
      if (!mounted) return;
      final message = layananErrorMessage(error);
      await showAppErrorSheet(
        context,
        message: message.isEmpty ? l10n.layananLoadFailed : message,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kecamatan = ref.watch(regionsKecamatanProvider);
    final regions = kecamatan.value ?? const <Region>[];
    final regionName = regions.cast<Region?>().firstWhere(
      (r) => r!.id == _regionId,
      orElse: () => null,
    )?.name;
    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.layananPropose),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: _busy ? null : _submit,
            prefix: _busy ? const FCircularProgress() : null,
            child: Text(_busy ? l10n.layananSending : l10n.layananSubmit),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          FTileGroup(
            children: [
              FTile(
                title: Text(
                  _category == 'fire' ? l10n.layananFire : l10n.layananAmbulance,
                ),
                subtitle: Text(l10n.layananCategory),
                onPress: () async {
                  final picked = await showOptionPickerSheet<String>(
                    context,
                    title: l10n.layananCategory,
                    items: [
                      OptionPickerItem(
                        value: 'ambulance',
                        label: l10n.layananAmbulance,
                        selected: _category == 'ambulance',
                      ),
                      OptionPickerItem(
                        value: 'fire',
                        label: l10n.layananFire,
                        selected: _category == 'fire',
                      ),
                    ],
                  );
                  if (picked != null) setState(() => _category = picked);
                },
              ),
              FTile(
                title: Text(regionName ?? l10n.layananPickKecamatan),
                subtitle: Text(l10n.layananKecamatan),
                onPress: () async {
                  final picked = await showOptionPickerSheet<String>(
                    context,
                    title: l10n.layananPickKecamatan,
                    searchable: true,
                    searchHint: l10n.layananPickKecamatan,
                    items: [
                      for (final region in regions)
                        OptionPickerItem(
                          value: region.id,
                          label: region.name,
                          selected: region.id == _regionId,
                        ),
                    ],
                  );
                  if (picked != null) setState(() => _regionId = picked);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          FTextField(
            control: FTextFieldControl.managed(controller: _name),
            label: Text(l10n.layananName),
          ),
          const SizedBox(height: 12),
          FTextField(
            control: FTextFieldControl.managed(controller: _logoUrl),
            label: Text(l10n.layananLogoUrl),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _phones.length; i++) ...[
            FTileGroup(
              label: Text('${l10n.layananPhone} ${i + 1}'),
              children: [
                if (_phones.length > 1)
                  FTile(
                    title: Text(l10n.layananRemovePhone),
                    onPress: () => _removePhone(i),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            FTextField(
              control: FTextFieldControl.managed(controller: _phones[i].phone),
              label: Text(l10n.layananPhone),
            ),
            const SizedBox(height: 8),
            FTextField(
              control: FTextFieldControl.managed(controller: _phones[i].note),
              label: Text(l10n.layananPhoneNote),
              description: Text(l10n.layananPhoneNoteHint),
            ),
            const SizedBox(height: 8),
            FTextField(
              control: FTextFieldControl.managed(
                controller: _phones[i].whatsapp,
              ),
              label: Text(l10n.layananWhatsapp),
            ),
            const SizedBox(height: 12),
          ],
          if (_phones.length < _maxPhones)
            FButton(
              variant: FButtonVariant.outline,
              onPress: _addPhone,
              child: Text(l10n.layananAddPhone),
            ),
          const SizedBox(height: 12),
          FTextField(
            control: FTextFieldControl.managed(controller: _address),
            label: Text(l10n.layananAddress),
          ),
          const SizedBox(height: 12),
          FTextField(
            control: FTextFieldControl.managed(controller: _note),
            label: Text(l10n.layananNote),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
