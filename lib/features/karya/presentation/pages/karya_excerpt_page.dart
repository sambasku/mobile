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
import '../../karya_router.dart';
import '../karya_providers.dart';

/// Batas fair_quote - selaras API (`KARYA_EXCERPT_FAIR_QUOTE_*`).
const _fairQuoteMaxLines = 4;
const _fairQuoteMaxChars = 500;

class KaryaExcerptPage extends ConsumerStatefulWidget {
  const KaryaExcerptPage({
    super.key,
    required this.karyaId,
    this.slug,
    this.karyaKind,
  });

  final String karyaId;
  final String? slug;
  final String? karyaKind;

  @override
  ConsumerState<KaryaExcerptPage> createState() => _KaryaExcerptPageState();
}

class _KaryaExcerptPageState extends ConsumerState<KaryaExcerptPage> {
  final _text = TextEditingController();
  final _rightsNote = TextEditingController();
  final _sourceUrl = TextEditingController();
  final _startLabel = TextEditingController();
  final _endLabel = TextEditingController();
  late String _excerptKind;
  String _rightsStatus = 'fair_quote';
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _excerptKind =
        widget.karyaKind == 'film' ? 'dialogue' : 'lyrics';
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
    _text.dispose();
    _rightsNote.dispose();
    _sourceUrl.dispose();
    _startLabel.dispose();
    _endLabel.dispose();
    super.dispose();
  }

  bool _exceedsFairQuote(String text) {
    final trimmed = text.trim();
    if (trimmed.length > _fairQuoteMaxChars) return true;
    final lines = trimmed
        .split(RegExp(r'\r?\n'))
        .where((l) => l.trim().isNotEmpty)
        .length;
    return lines > _fairQuoteMaxLines;
  }

  bool _isFullTextRights(String status) =>
      status == 'permission' ||
      status == 'licensed' ||
      status == 'public_domain';

  String? _clientValidate(AppLocalizations l10n) {
    final text = _text.text.trim();
    if (text.isEmpty) return l10n.karyaExcerptTextRequired;
    if (_rightsStatus == 'unknown') return l10n.karyaExcerptRightsUnknown;
    final over = _exceedsFairQuote(text);
    if (_rightsStatus == 'fair_quote' && over) {
      return l10n.karyaExcerptFairQuoteTooLong;
    }
    if (over && !_isFullTextRights(_rightsStatus)) {
      return l10n.karyaExcerptFullRequiresA2;
    }
    if (_isFullTextRights(_rightsStatus) &&
        _rightsNote.text.trim().isEmpty) {
      return l10n.karyaExcerptRightsNoteRequired;
    }
    final url = _sourceUrl.text.trim();
    if (url.isNotEmpty) {
      final uri = Uri.tryParse(url);
      if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
        return l10n.karyaExcerptSourceUrlInvalid;
      }
    }
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final err = _clientValidate(l10n);
    if (err != null) {
      await showAppErrorSheet(context, message: err);
      return;
    }
    setState(() => _busy = true);
    try {
      final source = _sourceUrl.text.trim();
      final start = _startLabel.text.trim();
      final end = _endLabel.text.trim();
      final note = _rightsNote.text.trim();
      await ref.read(karyaApiProvider).submit({
        'kind': 'excerpt',
        'karya_id': widget.karyaId,
        'payload': {
          'kind': _excerptKind,
          'text': _text.text.trim(),
          'rights_status': _rightsStatus,
          if (note.isNotEmpty) 'rights_note': note,
          if (source.isNotEmpty) 'source_url': source,
          if (start.isNotEmpty) 'start_label': start,
          if (end.isNotEmpty) 'end_label': end,
        },
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
  }

  List<OptionPickerItem<String>> _kindOptions(AppLocalizations l10n) => [
        OptionPickerItem(value: 'lyrics', label: l10n.karyaExcerptKindLyrics),
        OptionPickerItem(
          value: 'dialogue',
          label: l10n.karyaExcerptKindDialogue,
        ),
        OptionPickerItem(
          value: 'book_quote',
          label: l10n.karyaExcerptKindBookQuote,
        ),
        OptionPickerItem(value: 'other', label: l10n.karyaExcerptKindOther),
      ];

  List<OptionPickerItem<String>> _rightsOptions(AppLocalizations l10n) => [
        OptionPickerItem(
          value: 'fair_quote',
          label: l10n.karyaExcerptRightsFairQuote,
        ),
        OptionPickerItem(
          value: 'permission',
          label: l10n.karyaExcerptRightsPermission,
        ),
        OptionPickerItem(
          value: 'licensed',
          label: l10n.karyaExcerptRightsLicensed,
        ),
        OptionPickerItem(
          value: 'public_domain',
          label: l10n.karyaExcerptRightsPublicDomain,
        ),
      ];

  String _kindLabel(AppLocalizations l10n, String value) {
    for (final o in _kindOptions(l10n)) {
      if (o.value == value) return o.label;
    }
    return value;
  }

  String _rightsLabel(AppLocalizations l10n, String value) {
    for (final o in _rightsOptions(l10n)) {
      if (o.value == value) return o.label;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final showRightsNote = _isFullTextRights(_rightsStatus);

    if (widget.karyaId.isEmpty) {
      return FScaffold(
        header: FHeader.nested(
          title: Text(l10n.karyaProposeExcerpt),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: Center(child: Text(l10n.karyaNotFound)),
      );
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.karyaProposeExcerpt),
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
          Text(
            l10n.karyaExcerptHint,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.4,
            ),
          ),
          const Gap(16),
          FTileGroup(
            children: [
              FTile(
                title: Text(l10n.karyaExcerptKind),
                subtitle: Text(_kindLabel(l10n, _excerptKind)),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                onPress: () async {
                  final picked = await showOptionPickerSheet<String>(
                    context,
                    title: l10n.karyaExcerptKind,
                    items: _kindOptions(l10n),
                  );
                  if (picked == null || !mounted) return;
                  setState(() => _excerptKind = picked);
                },
              ),
              FTile(
                title: Text(l10n.karyaExcerptRights),
                subtitle: Text(_rightsLabel(l10n, _rightsStatus)),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                onPress: () async {
                  final picked = await showOptionPickerSheet<String>(
                    context,
                    title: l10n.karyaExcerptRights,
                    items: _rightsOptions(l10n),
                  );
                  if (picked == null || !mounted) return;
                  setState(() => _rightsStatus = picked);
                },
              ),
            ],
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _text),
            label: Text(l10n.karyaExcerptText),
            description: Text(l10n.karyaExcerptTextHint),
            maxLines: 8,
            minLines: 4,
          ),
          if (showRightsNote) ...[
            const Gap(12),
            FTextField(
              control: FTextFieldControl.managed(controller: _rightsNote),
              label: Text(l10n.karyaExcerptRightsNote),
              description: Text(l10n.karyaExcerptRightsNoteHint),
              maxLines: 3,
              minLines: 2,
            ),
          ],
          const Gap(12),
          PasteableUrlField(
            controller: _sourceUrl,
            label: Text(l10n.karyaExcerptSourceUrl),
            description: Text(l10n.karyaExcerptSourceUrlHint),
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _startLabel),
            label: Text(l10n.karyaExcerptStartLabel),
            description: Text(l10n.karyaExcerptStartLabelHint),
          ),
          const Gap(12),
          FTextField(
            control: FTextFieldControl.managed(controller: _endLabel),
            label: Text(l10n.karyaExcerptEndLabel),
            description: Text(l10n.karyaExcerptEndLabelHint),
          ),
        ],
      ),
    );
  }
}
