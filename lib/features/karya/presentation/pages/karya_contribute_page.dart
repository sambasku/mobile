import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../data/karya_api.dart';
import '../../domain/karya.dart';
import '../../karya_router.dart';
import '../karya_providers.dart';

class _CreditDraft {
  _CreditDraft()
      : name = TextEditingController(),
        role = 'vocal';

  final TextEditingController name;
  String role;

  void dispose() => name.dispose();
}

class _SambasDraft {
  _SambasDraft()
      : note = TextEditingController(),
        type = 'theme';

  final TextEditingController note;
  String type;

  void dispose() => note.dispose();
}

class _AccessDraft {
  _AccessDraft()
      : label = TextEditingController(),
        url = TextEditingController(),
        kind = 'official';

  final TextEditingController label;
  final TextEditingController url;
  String kind;

  void dispose() {
    label.dispose();
    url.dispose();
  }
}

class KaryaContributePage extends ConsumerStatefulWidget {
  const KaryaContributePage({
    super.key,
    this.karyaId,
    this.slug,
  });

  final String? karyaId;
  final String? slug;

  @override
  ConsumerState<KaryaContributePage> createState() =>
      _KaryaContributePageState();
}

class _KaryaContributePageState extends ConsumerState<KaryaContributePage> {
  final _title = TextEditingController();
  final _year = TextEditingController();
  final _description = TextEditingController();
  String? _kind;
  final _credits = <_CreditDraft>[_CreditDraft()];
  final _sambas = <_SambasDraft>[_SambasDraft()];
  final _access = <_AccessDraft>[];
  var _busy = false;
  var _prefilled = false;

  bool get _isEdit => widget.karyaId != null && widget.karyaId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _kind = 'music';
    final credit = _credits.first;
    credit.role = 'vocal';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final authed = ref.read(authStatusProvider).value?.isAuth ?? false;
      if (authed) return;
      await context.push('/login');
      if (!mounted) return;
      if (!(ref.read(authStatusProvider).value?.isAuth ?? false)) {
        context.pop();
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _year.dispose();
    _description.dispose();
    for (final row in _credits) {
      row.dispose();
    }
    for (final row in _sambas) {
      row.dispose();
    }
    for (final row in _access) {
      row.dispose();
    }
    super.dispose();
  }

  void _prefillFrom(KaryaEntry entry) {
    if (_prefilled) return;
    _prefilled = true;
    _title.text = entry.title;
    _year.text = '${entry.year}';
    _kind = entry.kind;
    if ((entry.description ?? '').isNotEmpty) {
      _description.text = entry.description!;
    }
    for (final row in _credits) {
      row.dispose();
    }
    for (final row in _sambas) {
      row.dispose();
    }
  for (final row in _access) {
      row.dispose();
    }
    _credits
      ..clear()
      ..addAll(
        entry.credits.map((c) {
          final d = _CreditDraft()..role = c.role;
          d.name.text = c.nameText;
          return d;
        }),
      );
    if (_credits.isEmpty) _credits.add(_CreditDraft());
    _sambas
      ..clear()
      ..addAll(
        entry.sambasConnections.map((s) {
          final d = _SambasDraft()..type = s.type;
          d.note.text = s.note;
          return d;
        }),
      );
    if (_sambas.isEmpty) _sambas.add(_SambasDraft());
    _access
      ..clear()
      ..addAll(
        entry.accessLinks.map((l) {
          final d = _AccessDraft()
            ..kind = l.kind
            ..label.text = l.label
            ..url.text = l.url;
          return d;
        }),
      );
  }

  void _addCredit() {
    final draft = _CreditDraft();
    draft.role = _kind == 'film' ? 'director' : 'vocal';
    setState(() => _credits.add(draft));
  }

  void _addSambas() => setState(() => _sambas.add(_SambasDraft()));

  void _addAccess() => setState(() => _access.add(_AccessDraft()));

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final kind = _kind;
    final year = int.tryParse(_year.text.trim());
    final title = _title.text.trim();
    final sambasRows = <Map<String, String>>[];
    for (final row in _sambas) {
      final note = row.note.text.trim();
      if (note.isEmpty) continue;
      sambasRows.add({'type': row.type, 'note': note});
    }
    final creditRows = <Map<String, String>>[];
    for (final row in _credits) {
      final name = row.name.text.trim();
      if (name.isEmpty) continue;
      creditRows.add({'role': row.role, 'name_text': name});
    }
    final accessRows = <Map<String, dynamic>>[];
    for (var i = 0; i < _access.length; i++) {
      final row = _access[i];
      final label = row.label.text.trim();
      final url = row.url.text.trim();
      if (label.isEmpty || url.isEmpty) continue;
      accessRows.add({
        'kind': row.kind,
        'label': label,
        'url': url,
        if (accessRows.isEmpty) 'is_primary': true,
      });
    }
    if (kind == null ||
        title.length < 2 ||
        year == null ||
        year < 1800 ||
        sambasRows.isEmpty ||
        creditRows.isEmpty) {
      await showAppErrorSheet(context, message: l10n.karyaFormInvalid);
      return;
    }
    setState(() => _busy = true);
    try {
      final payload = karyaPayloadWire(
        title: title,
        year: year,
        kind: kind,
        sambasConnections: sambasRows,
        credits: creditRows,
        accessLinks: accessRows,
        description: _description.text.trim(),
      );
      await ref.read(karyaApiProvider).submit({
        'kind': _isEdit ? 'edit' : 'new',
        if (_isEdit) 'karya_id': widget.karyaId,
        'payload': payload,
      });
      if (!mounted) return;
      if (_isEdit) {
        context.pop();
        showFToast(context: context, title: Text(l10n.karyaProposeSuccess));
      } else {
        context.pushReplacement(KaryaRouter.proposals.path);
      }
    } catch (error) {
      if (!mounted) return;
      final message = karyaErrorMessage(error);
      await showAppErrorSheet(
        context,
        message: message.isEmpty ? l10n.karyaLoadFailed : message,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  List<OptionPickerItem<String>> _kindOptions(AppLocalizations l10n) => [
        OptionPickerItem(value: 'music', label: l10n.karyaKindMusic),
        OptionPickerItem(value: 'film', label: l10n.karyaKindFilm),
      ];

  List<OptionPickerItem<String>> _creditRoles(AppLocalizations l10n) {
    if (_kind == 'film') {
      return [
        OptionPickerItem(value: 'director', label: l10n.karyaCreditRoleDirector),
        OptionPickerItem(value: 'cast', label: l10n.karyaCreditRoleCast),
        OptionPickerItem(value: 'writer', label: l10n.karyaCreditRoleWriter),
        OptionPickerItem(value: 'producer', label: l10n.karyaCreditRoleProducer),
        OptionPickerItem(
          value: 'cinematographer',
          label: l10n.karyaCreditRoleCinematographer,
        ),
        OptionPickerItem(value: 'composer', label: l10n.karyaCreditRoleComposer),
        OptionPickerItem(value: 'other', label: l10n.karyaCreditRoleOther),
      ];
    }
    return [
      OptionPickerItem(value: 'vocal', label: l10n.karyaCreditRoleVocal),
      OptionPickerItem(value: 'feat', label: l10n.karyaCreditRoleFeat),
      OptionPickerItem(
        value: 'songwriter',
        label: l10n.karyaCreditRoleSongwriter,
      ),
      OptionPickerItem(value: 'composer', label: l10n.karyaCreditRoleComposer),
      OptionPickerItem(value: 'producer', label: l10n.karyaCreditRoleProducer),
      OptionPickerItem(value: 'arranger', label: l10n.karyaCreditRoleArranger),
      OptionPickerItem(
        value: 'band_member',
        label: l10n.karyaCreditRoleBandMember,
      ),
      OptionPickerItem(value: 'other', label: l10n.karyaCreditRoleOther),
    ];
  }

  List<OptionPickerItem<String>> _sambasTypes(AppLocalizations l10n) => [
        OptionPickerItem(
          value: 'creator_origin',
          label: l10n.karyaSambasTypeCreatorOrigin,
        ),
        OptionPickerItem(value: 'language', label: l10n.karyaSambasTypeLanguage),
        OptionPickerItem(value: 'location', label: l10n.karyaSambasTypeLocation),
        OptionPickerItem(value: 'theme', label: l10n.karyaSambasTypeTheme),
        OptionPickerItem(value: 'other', label: l10n.karyaSambasTypeOther),
      ];

  List<OptionPickerItem<String>> _accessKinds(AppLocalizations l10n) => [
        OptionPickerItem(value: 'listen', label: l10n.karyaAccessKindListen),
        OptionPickerItem(value: 'watch', label: l10n.karyaAccessKindWatch),
        OptionPickerItem(value: 'buy', label: l10n.karyaAccessKindBuy),
        OptionPickerItem(value: 'read', label: l10n.karyaAccessKindRead),
        OptionPickerItem(value: 'stream', label: l10n.karyaAccessKindStream),
        OptionPickerItem(value: 'official', label: l10n.karyaAccessKindOfficial),
        OptionPickerItem(value: 'other', label: l10n.karyaAccessKindOther),
      ];

  String _roleLabel(AppLocalizations l10n, String role) {
    for (final item in _creditRoles(l10n)) {
      if (item.value == role) return item.label;
    }
    return role;
  }

  String _sambasLabel(AppLocalizations l10n, String type) {
    for (final item in _sambasTypes(l10n)) {
      if (item.value == type) return item.label;
    }
    return type;
  }

  String _accessLabel(AppLocalizations l10n, String kind) {
    for (final item in _accessKinds(l10n)) {
      if (item.value == kind) return item.label;
    }
    return kind;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slug = widget.slug;
    if (slug != null && slug.isNotEmpty) {
      final entryAsync = ref.watch(karyaBySlugProvider(slug));
      entryAsync.whenData((entry) {
        if (entry != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _prefillFrom(entry));
            }
          });
        }
      });
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(_isEdit ? l10n.karyaProposeEdit : l10n.karyaContribute),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: _busy ? null : _submit,
            prefix: _busy ? const FCircularProgress() : null,
            child: Text(
              _busy ? l10n.karyaContributeBusy : l10n.karyaContributeSubmit,
            ),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          if (!_isEdit)
            FTileGroup(
              children: [
                FTile(
                  title: Text(switch (_kind) {
                    'film' => l10n.karyaKindFilm,
                    'music' => l10n.karyaKindMusic,
                    _ => l10n.karyaFormPickKind,
                  }),
                  subtitle: Text(l10n.karyaFormKind),
                  onPress: () async {
                    final picked = await showOptionPickerSheet<String>(
                      context,
                      title: l10n.karyaFormKind,
                      items: _kindOptions(l10n),
                    );
                    if (picked == null || !mounted) return;
                    setState(() {
                      _kind = picked;
                      for (final row in _credits) {
                        row.role = picked == 'film' ? 'director' : 'vocal';
                      }
                    });
                  },
                ),
              ],
            ),
          if (!_isEdit) const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _title),
            label: Text(l10n.karyaFormTitle),
            description: Text(l10n.karyaFormTitleHint),
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _year),
            label: Text(l10n.karyaYear),
            description: Text(l10n.karyaFormYearHint),
            keyboardType: TextInputType.number,
          ),
          const Gap(12),
          Text(
            l10n.karyaSambasSection,
            style: context.theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          FTileGroup(
            children: [
              for (var i = 0; i < _sambas.length; i++) ...[
                FTile(
                  title: Text(_sambasLabel(l10n, _sambas[i].type)),
                  subtitle: Text(l10n.karyaSambasType),
                  onPress: () async {
                    final picked = await showOptionPickerSheet<String>(
                      context,
                      title: l10n.karyaSambasType,
                      items: _sambasTypes(l10n),
                    );
                    if (picked == null || !mounted) return;
                    setState(() => _sambas[i].type = picked);
                  },
                ),
              ],
              FTile(
                title: Text(l10n.karyaFormAddSambas),
                prefix: const Icon(FLucideIcons.plus, size: 18),
                onPress: _addSambas,
              ),
            ],
          ),
          for (var i = 0; i < _sambas.length; i++) ...[
            const Gap(8),
            FTextField(
              control: FTextFieldControl.managed(controller: _sambas[i].note),
              label: Text(l10n.karyaSambasNote),
              description: Text(l10n.karyaSambasNoteHint),
              maxLines: 3,
            ),
          ],
          const Gap(12),
          Text(
            l10n.karyaCredits,
            style: context.theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          FTileGroup(
            children: [
              for (var i = 0; i < _credits.length; i++) ...[
                FTile(
                  title: Text(_roleLabel(l10n, _credits[i].role)),
                  subtitle: Text(l10n.karyaFormCreditRole),
                  onPress: () async {
                    final picked = await showOptionPickerSheet<String>(
                      context,
                      title: l10n.karyaFormCreditRole,
                      items: _creditRoles(l10n),
                    );
                    if (picked == null || !mounted) return;
                    setState(() => _credits[i].role = picked);
                  },
                ),
              ],
              FTile(
                title: Text(l10n.karyaFormAddCredit),
                prefix: const Icon(FLucideIcons.plus, size: 18),
                onPress: _addCredit,
              ),
            ],
          ),
          for (var i = 0; i < _credits.length; i++) ...[
            const Gap(8),
            FTextField(
              control: FTextFieldControl.managed(controller: _credits[i].name),
              label: Text(l10n.karyaFormCreditName),
              description: Text(l10n.karyaFormCreditNameHint),
            ),
          ],
          const Gap(12),
          Text(
            l10n.karyaAccess,
            style: context.theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          FTileGroup(
            children: [
              for (var i = 0; i < _access.length; i++) ...[
                FTile(
                  title: Text(_accessLabel(l10n, _access[i].kind)),
                  subtitle: Text(l10n.karyaFormAccessKind),
                  onPress: () async {
                    final picked = await showOptionPickerSheet<String>(
                      context,
                      title: l10n.karyaFormAccessKind,
                      items: _accessKinds(l10n),
                    );
                    if (picked == null || !mounted) return;
                    setState(() => _access[i].kind = picked);
                  },
                ),
              ],
              FTile(
                title: Text(l10n.karyaFormAddAccess),
                prefix: const Icon(FLucideIcons.plus, size: 18),
                onPress: _addAccess,
              ),
            ],
          ),
          for (var i = 0; i < _access.length; i++) ...[
            const Gap(8),
            FTextField(
              control: FTextFieldControl.managed(controller: _access[i].label),
              label: Text(l10n.karyaFormAccessLabel),
              description: Text(l10n.karyaFormAccessLabelHint),
            ),
            const Gap(8),
            FTextField(
              control: FTextFieldControl.managed(controller: _access[i].url),
              label: Text(l10n.karyaFormAccessUrl),
              description: Text(l10n.karyaFormAccessUrlHint),
              keyboardType: TextInputType.url,
            ),
          ],
        ],
      ),
    );
  }
}