import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/state/local_form_draft_store.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/form_draft_reset_sheet.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
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

class _KaryaContributePageState extends ConsumerState<KaryaContributePage>
    with LocalDraftKeeper<_KaryaDraft> {
  final _title = TextEditingController();
  final _year = TextEditingController();
  final _description = TextEditingController();
  final _trailerUrl = TextEditingController();
  String? _kind;
  final _credits = <_CreditDraft>[_CreditDraft()];
  final _sambas = <_SambasDraft>[_SambasDraft()];
  final _access = <_AccessDraft>[];
  var _busy = false;
  var _prefilled = false;
  List<AttachmentImageSlot> _cover = const [];

  Timer? _kreatorDebounce;
  var _kreatorLoading = false;
  List<KreatorSuggest> _kreatorHints = const [];

  bool get _isEdit => widget.karyaId != null && widget.karyaId!.isNotEmpty;

  @override
  String get draftKey => 'karya:${widget.karyaId ?? widget.slug ?? 'new'}';

  @override
  bool get draftHasContent => captureDraft().hasContent;

  @override
  String get draftToken => [
    _title.text,
    _year.text,
    _description.text,
    _trailerUrl.text,
    _kind,
    for (final c in _credits)
      '${c.name.text}|${c.role}|${c.kreatorId}',
    for (final s in _sambas) '${s.note.text}|${s.type}',
    for (final a in _access) '${a.label.text}|${a.url.text}|${a.kind}',
    for (final image in _cover)
      '${image.id}|${image.localPath}|${image.uploaded?.url}',
  ].join('\u0001');

  @override
  _KaryaDraft captureDraft() => _KaryaDraft(
    title: _title.text,
    year: _year.text,
    description: _description.text,
    trailerUrl: _trailerUrl.text,
    kind: _kind,
    credits: [
      for (final c in _credits)
        _KaryaCreditRowDraft(
          name: c.name.text,
          role: c.role,
          kreatorId: c.kreatorId,
        ),
    ],
    sambas: [
      for (final s in _sambas)
        _KaryaSambasRowDraft(note: s.note.text, type: s.type),
    ],
    access: [
      for (final a in _access)
        _KaryaAccessRowDraft(
          label: a.label.text,
          url: a.url.text,
          kind: a.kind,
        ),
    ],
    cover: draftAttachmentSlots(_cover),
  );

  void _disposeDynamicRows() {
    for (final row in _credits) {
      row.dispose();
    }
    for (final row in _sambas) {
      row.dispose();
    }
    for (final row in _access) {
      row.dispose();
    }
    _credits.clear();
    _sambas.clear();
    _access.clear();
  }

  void _attachCreateCreditListener() {
    if (_isEdit || _credits.isEmpty) return;
    _credits.first.name.removeListener(_onCreditNameChanged);
    _credits.first.name.addListener(_onCreditNameChanged);
  }

  @override
  void restoreDraft(_KaryaDraft draft) {
    _title.text = draft.title;
    _year.text = draft.year;
    _description.text = draft.description;
    _trailerUrl.text = draft.trailerUrl;
    _kind = draft.kind;
    _disposeDynamicRows();
    _credits.addAll(
      draft.credits.map((c) {
        final d = _CreditDraft()
          ..role = c.role
          ..kreatorId = c.kreatorId;
        d.name.text = c.name;
        return d;
      }),
    );
    if (_credits.isEmpty) {
      _credits.add(_CreditDraft());
    }
    _sambas.addAll(
      draft.sambas.map((s) {
        final d = _SambasDraft()..type = s.type;
        d.note.text = s.note;
        return d;
      }),
    );
    if (_sambas.isEmpty) {
      _sambas.add(_SambasDraft());
    }
    _access.addAll(
      draft.access.map((a) {
        final d = _AccessDraft()
          ..kind = a.kind
          ..label.text = a.label
          ..url.text = a.url;
        return d;
      }),
    );
    _cover = draft.cover;
    _attachCreateCreditListener();
    if (_isEdit && draft.hasContent) {
      _prefilled = true;
    }
    _kreatorHints = const [];
    _kreatorLoading = false;
  }

  void _resetToCreateDefaults() {
    _title.clear();
    _year.clear();
    _description.clear();
    _trailerUrl.clear();
    if (_credits.isNotEmpty) {
      _credits.first.name.removeListener(_onCreditNameChanged);
    }
    _disposeDynamicRows();
    final prefillKind = widget.prefillKind;
    _kind = prefillKind == 'film' ? 'film' : 'music';
    final credit = _CreditDraft()
      ..role = _kind == 'film' ? 'other' : 'vocal';
    final prefillName = (widget.prefillCreditName ?? '').trim();
    if (prefillName.isNotEmpty) {
      credit.name.text = prefillName;
    }
    _credits.add(credit);
    _sambas.add(_SambasDraft());
    _cover = const [];
    _prefilled = false;
    _kreatorHints = const [];
    _kreatorLoading = false;
    _attachCreateCreditListener();
  }

  Future<void> _resetForm() async {
    if (!draftHasContent) return;
    final l10n = AppLocalizations.of(context);
    final ok = await confirmFormDraftReset(context, l10n);
    if (!ok || !mounted) return;

    if (_isEdit) {
      if (_credits.isNotEmpty) {
        _credits.first.name.removeListener(_onCreditNameChanged);
      }
      _disposeDynamicRows();
      _credits.add(_CreditDraft());
      _sambas.add(_SambasDraft());
      _title.clear();
      _year.clear();
      _description.clear();
      _trailerUrl.clear();
      _kind = null;
      _cover = const [];
      _prefilled = false;
      final slug = widget.slug;
      if (slug != null && slug.isNotEmpty) {
        final entry = ref.read(karyaBySlugProvider(slug)).value;
        if (entry != null) {
          setState(() => _prefillFrom(entry));
        }
      }
    } else {
      _resetToCreateDefaults();
    }

    abandonLocalDraft();
    if (mounted) setState(() {});
  }

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
    loadLocalDraft();
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
    flushLocalDraft();
    _kreatorDebounce?.cancel();
    if (_credits.isNotEmpty) {
      _credits.first.name.removeListener(_onCreditNameChanged);
    }
    _title.dispose();
    _trailerUrl.dispose();
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
    final trailer = entry.accessLinks.where((l) => l.kind == 'trailer').toList();
    _trailerUrl.text = trailer.isNotEmpty ? trailer.first.url : '';
    _access
      ..clear()
      ..addAll(
        entry.accessLinks.where((l) => l.kind != 'trailer').map((l) {
          final d = _AccessDraft()
            ..kind = l.kind
            ..label.text = l.label
            ..url.text = l.url;
          return d;
        }),
      );
    final existingCover = (entry.coverUrl ?? '').trim();
    _cover = existingCover.isEmpty
        ? const []
        : [
            AttachmentImageSlot(
              id: 'cover-existing',
              localPath: '',
              uploaded: AttachmentUploadedImage(
                url: existingCover,
                providerFileId: existingCover,
                isPrimary: true,
              ),
            ),
          ];
    sealDraftBaseline();
  }

  void _addCredit() {
    final draft = _CreditDraft();
    draft.role = _kind == 'film' ? 'director' : 'vocal';
    setState(() => _credits.add(draft));
  }

  void _addSambas() => setState(() => _sambas.add(_SambasDraft()));

  void _removeSambas(int index) {
    if (index < 0 || index >= _sambas.length || _sambas.length <= 1) return;
    setState(() {
      _sambas.removeAt(index).dispose();
    });
  }

  void _removeCredit(int index) {
    if (index < 0 || index >= _credits.length || _credits.length <= 1) return;
    setState(() {
      _credits.removeAt(index).dispose();
    });
  }

  void _addAccess() => setState(() => _access.add(_AccessDraft()));

  void _removeAccess(int index) {
    if (index < 0 || index >= _access.length) return;
    setState(() {
      _access.removeAt(index).dispose();
    });
  }

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


  String? _readyCoverUrl() {
    if (_cover.isEmpty) return null;
    final slot = _cover.first;
    if (!slot.isReady) return null;
    return slot.uploaded?.url;
  }

  bool _coverBlocksSubmit(AppLocalizations l10n) {
    if (_cover.any((s) => s.uploading)) {
      showFToast(context: context, title: Text(l10n.karyaFormWaitUpload));
      return true;
    }
    if (_cover.any((s) => s.error)) {
      showFToast(
        context: context,
        title: Text(l10n.karyaFormRemoveFailedPhoto),
        variant: FToastVariant.destructive,
      );
      return true;
    }
    return false;
  }

  Future<Either<AttachmentUploadFailure, AttachmentUploadedImage>> _uploadCover(
    File file, {
    required bool isPrimary,
  }) async {
    try {
      final url = await ref.read(karyaApiProvider).uploadCover(file);
      return Either.right(
        AttachmentUploadedImage(
          url: url,
          providerFileId: url,
          isPrimary: true,
        ),
      );
    } on KaryaException catch (e) {
      return Either.left(AttachmentUploadFailure(e.message));
    }
  }

  List<Widget> _coverField(AppLocalizations l10n) {
    final isFilm = _kind == 'film';
    return [
      Text(
        isFilm ? l10n.karyaFormCoverFilm : l10n.karyaFormCoverMusic,
        style: context.theme.typography.body.sm.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const Gap(4),
      Text(
        isFilm ? l10n.karyaFormCoverHintFilm : l10n.karyaFormCoverHintMusic,
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
      const Gap(8),
      AttachmentImagesField(
        enabled: !_busy,
        maxImages: 1,
        maxSizeMb: 5,
        images: _cover,
        onChanged: (next) => setState(() => _cover = next),
        upload: _uploadCover,
      ),
    ];
  }


  Map<String, dynamic>? _trailerAccessRow() {
    final url = _trailerUrl.text.trim();
    if (url.isEmpty) return null;
    return {
      'kind': 'trailer',
      'label': 'Trailer',
      'url': url,
      'is_primary': true,
    };
  }

  /// Gabung trailer form cepat ke daftar akses edit; trailer dari field
  /// menggantikan entry kind trailer lama (satu trailer utama).
  List<Map<String, dynamic>> _accessRowsWithTrailer(
    List<Map<String, dynamic>> rows,
  ) {
    final trailer = _trailerAccessRow();
    // Field kosong: biarkan baris kind trailer dari daftar tautan.
    if (trailer == null) return rows;
    final withoutTrailer = [
      for (final row in rows)
        if (row['kind'] != 'trailer') row,
    ];
    // Field terisi: ganti semua trailer lama, jadikan primary.
    final demoted = [
      for (final row in withoutTrailer)
        {
          ...row,
          if (row['is_primary'] == true) 'is_primary': false,
        },
    ];
    return [trailer, ...demoted];
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
      if (_coverBlocksSubmit(l10n)) return;
      final safeKind = kind!;
      setState(() => _busy = true);
      try {
        final trailer = safeKind == 'film' ? _trailerAccessRow() : null;
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
          coverUrl: _readyCoverUrl(),
          accessLinks: trailer == null ? const [] : [trailer],
        );
        await ref.read(karyaApiProvider).submit({
          'kind': 'new',
          'payload': payload,
        });
        commitLocalDraft();
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
    if (_coverBlocksSubmit(l10n)) return;
    final safeKind = kind!;
    setState(() => _busy = true);
    try {
      final payload = karyaPayloadWire(
        title: title,
        year: year,
        kind: safeKind,
        sambasConnections: sambasRows,
        credits: creditRows,
        accessLinks: safeKind == 'film'
            ? _accessRowsWithTrailer(accessRows)
            : [
                for (final row in accessRows)
                  if (row['kind'] != 'trailer') row,
              ],
        description: _description.text.trim(),
        coverUrl: _readyCoverUrl(),
      );
      await ref.read(karyaApiProvider).submit({
        'kind': 'edit',
        'karya_id': widget.karyaId,
        'payload': payload,
      });
      commitLocalDraft();
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
        if (_kind == 'film')
          OptionPickerItem(
            value: 'trailer',
            label: l10n.karyaAccessKindTrailer,
          ),
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
        suffixes: [
          if (draftHasContent)
            Tooltip(
              message: l10n.contributeFormResetTooltip,
              child: FHeaderAction(
                icon: const Icon(FLucideIcons.trash),
                onPress: _resetForm,
              ),
            ),
        ],
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
      ..._coverField(l10n),
      if (_kind == 'film') ...[
        const Gap(12),
        PasteableUrlField(
          controller: _trailerUrl,
          label: Text(l10n.karyaFormTrailerUrl),
          description: Text(l10n.karyaFormTrailerUrlHint),
        ),
      ],
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
      ..._coverField(l10n),
      if (_kind == 'film') ...[
        const Gap(12),
        PasteableUrlField(
          controller: _trailerUrl,
          label: Text(l10n.karyaFormTrailerUrl),
          description: Text(l10n.karyaFormTrailerUrlHint),
        ),
      ],
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
        style: context.theme.typography.body.sm.copyWith(
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
        if (_sambas.length > 1) ...[
          Align(
            alignment: Alignment.centerRight,
            child: FButton.icon(
              onPress: () => _removeSambas(i),
              child: Icon(
                FLucideIcons.trash,
                semanticLabel: l10n.karyaFormRemoveSambas,
              ),
            ),
          ),
          const Gap(4),
        ],
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
        style: context.theme.typography.body.sm.copyWith(
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
        if (_credits.length > 1) ...[
          Align(
            alignment: Alignment.centerRight,
            child: FButton.icon(
              onPress: () => _removeCredit(i),
              child: Icon(
                FLucideIcons.trash,
                semanticLabel: l10n.karyaFormRemoveCredit,
              ),
            ),
          ),
          const Gap(4),
        ],
        FTextField(
          control: FTextFieldControl.managed(controller: _credits[i].name),
          label: Text(l10n.karyaFormCreditName),
          description: Text(l10n.karyaFormCreditNameHint),
        ),
      ],
      const Gap(12),
      Text(
        l10n.karyaAccess,
        style: context.theme.typography.body.sm.copyWith(
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
        Align(
          alignment: Alignment.centerRight,
          child: FButton.icon(
            onPress: () => _removeAccess(i),
            child: Icon(
              FLucideIcons.trash,
              semanticLabel: l10n.karyaFormRemoveAccess,
            ),
          ),
        ),
        const Gap(4),
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

class _KaryaCreditRowDraft {
  const _KaryaCreditRowDraft({
    required this.name,
    required this.role,
    this.kreatorId,
  });

  final String name;
  final String role;
  final String? kreatorId;
}

class _KaryaSambasRowDraft {
  const _KaryaSambasRowDraft({required this.note, required this.type});

  final String note;
  final String type;
}

class _KaryaAccessRowDraft {
  const _KaryaAccessRowDraft({
    required this.label,
    required this.url,
    required this.kind,
  });

  final String label;
  final String url;
  final String kind;
}

class _KaryaDraft {
  const _KaryaDraft({
    required this.title,
    required this.year,
    required this.description,
    required this.trailerUrl,
    required this.kind,
    required this.credits,
    required this.sambas,
    required this.access,
    this.cover = const [],
  });

  final String title;
  final String year;
  final String description;
  final String trailerUrl;
  final String? kind;
  final List<_KaryaCreditRowDraft> credits;
  final List<_KaryaSambasRowDraft> sambas;
  final List<_KaryaAccessRowDraft> access;
  final List<AttachmentImageSlot> cover;

  bool get hasContent {
    if (title.trim().isNotEmpty ||
        year.trim().isNotEmpty ||
        description.trim().isNotEmpty ||
        trailerUrl.trim().isNotEmpty ||
        cover.isNotEmpty) {
      return true;
    }
    final creditFilled = credits.any((c) => c.name.trim().isNotEmpty);
    final sambasFilled = sambas.any((s) => s.note.trim().isNotEmpty);
    final accessFilled = access.any(
      (a) => a.label.trim().isNotEmpty || a.url.trim().isNotEmpty,
    );
    return creditFilled || sambasFilled || accessFilled;
  }
}
