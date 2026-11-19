import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../../shared/widgets/pasteable_url_field.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
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
  String? kreatorId;

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
    this.prefillCreditName,
    this.prefillKind,
  });

  final String? karyaId;
  final String? slug;

  /// Prefill dari profil kreator (usul karya baru).
  final String? prefillCreditName;
  final String? prefillKind;

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

  Timer? _kreatorDebounce;
  var _kreatorLoading = false;
  List<KreatorSuggest> _kreatorHints = const [];

  bool get _isEdit => widget.karyaId != null && widget.karyaId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final prefillKind = widget.prefillKind;
    _kind = prefillKind == 'film' ? 'film' : 'music';
    final credit = _credits.first;
    // Film quick form: role generik `other` (channel / rumah produksi / pembuat).
    credit.role = _kind == 'film' ? 'other' : 'vocal';
    final prefillName = (widget.prefillCreditName ?? '').trim();
    if (prefillName.isNotEmpty) {
      credit.name.text = prefillName;
    }
    credit.name.addListener(_onCreditNameChanged);
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
    _kreatorDebounce?.cancel();
    if (_credits.isNotEmpty) {
      _credits.first.name.removeListener(_onCreditNameChanged);
    }
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

  void _onCreditNameChanged() {
    if (_isEdit || !mounted) return;
    final credit = _credits.first;
    // Ketik ulang = lepas pick kreator.
    if (credit.kreatorId != null) {
      credit.kreatorId = null;
    }
    _kreatorDebounce?.cancel();
    final q = credit.name.text.trim();
    if (q.length < 2) {
      setState(() {
        _kreatorHints = const [];
        _kreatorLoading = false;
      });
      return;
    }
    setState(() => _kreatorLoading = true);
    _kreatorDebounce = Timer(const Duration(milliseconds: 300), () async {
      final api = ref.read(karyaApiProvider);
      final items = await api.searchKreators(q);
      if (!mounted) return;
      if (_credits.first.name.text.trim() != q) return;
      setState(() {
        _kreatorHints = items;
        _kreatorLoading = false;
      });
    });
  }

  void _pickKreator(KreatorSuggest item) {
    final credit = _credits.first;
    credit.name.removeListener(_onCreditNameChanged);
    credit.name.text = item.displayName;
    credit.kreatorId = item.id;
    credit.name.addListener(_onCreditNameChanged);
    setState(() {
      _kreatorHints = const [];
      _kreatorLoading = false;
    });
  }

  void _prefillFrom(KaryaEntry entry) {
    if (_prefilled) return;
    _prefilled = true;
    _title.text = entry.title;
    _year.text = entry.year?.toString() ?? '';
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
          final d = _CreditDraft()
            ..role = c.role
            ..kreatorId = c.kreatorId;
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

  String? _clientValidateNew({
    required AppLocalizations l10n,
    required String? kind,
    required String title,
    required String creditName,
  }) {
    if (kind == null) return l10n.karyaFormKindRequired;
    if (title.length < 2) return l10n.karyaFormTitleRequired;
    if (creditName.length < 2) return l10n.karyaFormCreditNameRequired;
    return null;
  }

  String? _clientValidateEdit({
    required AppLocalizations l10n,
    required String? kind,
    required String title,
    required String yearRaw,
    required List<Map<String, String>> creditRows,
  }) {
    if (kind == null) return l10n.karyaFormKindRequired;
    if (title.length < 2) return l10n.karyaFormTitleRequired;
    if (yearRaw.isNotEmpty) {
      final year = int.tryParse(yearRaw);
      if (year == null || year < 1800 || year > 2100) {
        return l10n.karyaFormYearInvalid;
      }
    }
    if (creditRows.isEmpty) return l10n.karyaFormCreditRequired;
    final roles = creditRows.map((c) => c['role']).whereType<String>().toSet();
    if (kind == 'music' && !roles.contains('vocal')) {
      return l10n.karyaFormCreditVocalRequired;
    }
    // Film: cukup ≥1 kredit (role apa saja yang valid), termasuk other/producer.
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final kind = _kind;
    final title = _title.text.trim();

    if (!_isEdit) {
      final credit = _credits.first;
      final creditName = credit.name.text.trim();
      final clientError = _clientValidateNew(
        l10n: l10n,
        kind: kind,
        title: title,
        creditName: creditName,
      );
      if (clientError != null) {
        await showAppErrorSheet(context, message: clientError);
        return;
      }
      final safeKind = kind!;
      setState(() => _busy = true);
      try {
        final payload = karyaPayloadWire(
          title: title,
          kind: safeKind,
          credits: [
            {
              'role': safeKind == 'film' ? 'other' : 'vocal',
              'name_text': creditName,
              if ((credit.kreatorId ?? '').isNotEmpty)
                'kreator_id': credit.kreatorId!,
            },
          ],
        );
        await ref.read(karyaApiProvider).submit({
          'kind': 'new',
          'payload': payload,
        });
        if (!mounted) return;
        context.pushReplacement(KaryaRouter.proposals.path);
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
      return;
    }

    final yearRaw = _year.text.trim();
    final year = yearRaw.isEmpty ? null : int.tryParse(yearRaw);
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
      creditRows.add({
        'role': row.role,
        'name_text': name,
        if ((row.kreatorId ?? '').isNotEmpty) 'kreator_id': row.kreatorId!,
      });
    }
    final accessRows = <Map<String, dynamic>>[];
    for (final row in _access) {
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
    final clientError = _clientValidateEdit(
      l10n: l10n,
      kind: kind,
      title: title,
      yearRaw: yearRaw,
      creditRows: creditRows,
    );
    if (clientError != null) {
      await showAppErrorSheet(context, message: clientError);
      return;
    }
    final safeKind = kind!;
    setState(() => _busy = true);
    try {
      final payload = karyaPayloadWire(
        title: title,
        year: year,
        kind: safeKind,
        sambasConnections: sambasRows,
        credits: creditRows,
        accessLinks: accessRows,
        description: _description.text.trim(),
      );
      await ref.read(karyaApiProvider).submit({
        'kind': 'edit',
        'karya_id': widget.karyaId,
        'payload': payload,
      });
      if (!mounted) return;
      context.pop();
      showFToast(context: context, title: Text(l10n.karyaProposeSuccess));
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

    final headerTitle = _isEdit
        ? l10n.karyaProposeEdit
        : (_kind == 'film' ? l10n.karyaContributeFilm : l10n.karyaContributeMusic);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(headerTitle),
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
          if (_isEdit) ..._editFields(l10n) else ..._quickFields(l10n),
        ],
      ),
    );
  }

  List<Widget> _quickFields(AppLocalizations l10n) {
    final credit = _credits.first;
    final personLabel = _kind == 'film'
        ? l10n.karyaFormCreditNameFilm
        : l10n.karyaFormCreditNameMusic;
    final personHint = _kind == 'film'
        ? l10n.karyaFormCreditNameHintFilm
        : l10n.karyaFormCreditNameHintMusic;
    return [
      Text(
        l10n.karyaFormQuickHint,
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
      const Gap(12),
      FTextField(
        control: FTextFieldControl.managed(controller: _title),
        label: Text(l10n.karyaFormTitle),
        description: Text(
          _kind == 'film'
              ? l10n.karyaFormTitleHintFilm
              : l10n.karyaFormTitleHintMusic,
        ),
      ),
      const Gap(12),
      FTextField(
        control: FTextFieldControl.managed(controller: credit.name),
        label: Text(personLabel),
        description: Text(personHint),
      ),
      if (_kreatorLoading) ...[
        const Gap(8),
        const Align(
          alignment: Alignment.centerLeft,
          child: FCircularProgress(size: .sm),
        ),
      ],
      if (_kreatorHints.isNotEmpty) ...[
        const Gap(8),
        FTileGroup(
          children: [
            for (final item in _kreatorHints.take(8))
              FTile(
                title: Text(item.displayName),
                subtitle: Text(l10n.karyaFormKreatorSuggestPick),
                onPress: () => _pickKreator(item),
              ),
          ],
        ),
      ],
    ];
  }

  List<Widget> _editFields(AppLocalizations l10n) {
    return [
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
      const Gap(4),
      Text(
        _kind == 'film'
            ? l10n.karyaFormCreditHintFilm
            : l10n.karyaFormCreditHintMusic,
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
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
        PasteableUrlField(
          controller: _access[i].url,
          label: Text(l10n.karyaFormAccessUrl),
          description: Text(l10n.karyaFormAccessUrlHint),
        ),
      ],
    ];
  }
}
