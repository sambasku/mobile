import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../contribution/presentation/utils/invalidate_word_detail.dart';
import '../providers/pronunciation_providers.dart';
import '../utils/pronunciation_format.dart';

/// Sheet paste-first untuk menambah pelafalan tertulis (notation=ipa).
Future<bool?> showAddWrittenPronunciationSheet(
  BuildContext context, {
  required String wordId,
  required String lemma,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: _AddWrittenPronunciationSheet(wordId: wordId, lemma: lemma),
    ),
  );
}

class _AddWrittenPronunciationSheet extends ConsumerStatefulWidget {
  const _AddWrittenPronunciationSheet({
    required this.wordId,
    required this.lemma,
  });

  final String wordId;
  final String lemma;

  @override
  ConsumerState<_AddWrittenPronunciationSheet> createState() =>
      _AddWrittenPronunciationSheetState();
}

class _AddWrittenPronunciationSheetState
    extends ConsumerState<_AddWrittenPronunciationSheet> {
  final _ctrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final l10n = AppLocalizations.of(context);
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(l10n.dictPronunciationClipboardEmpty),
      );
      return;
    }
    final raw = pronunciationRaw(text);
    _ctrl
      ..text = raw
      ..selection = TextSelection.collapsed(offset: raw.length);
  }

  Future<void> _submit() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    final raw = pronunciationRaw(_ctrl.text);
    if (raw.isEmpty) {
      showFToast(
        context: context,
        title: Text(l10n.dictAddPronunciationEmpty),
        variant: FToastVariant.destructive,
      );
      return;
    }

    setState(() => _busy = true);
    final result = await ref
        .read(writtenPronunciationServiceProvider)
        .create(wordId: widget.wordId, value: raw);
    if (!mounted) return;

    await result.match(
      (failure) async {
        setState(() => _busy = false);
        await showAppErrorSheet(context, message: failure.message);
      },
      (_) async {
        await invalidateWordDetailCaches(ref, widget.wordId, widget.lemma);
        if (!mounted) return;
        showFToast(
          context: context,
          title: Text(l10n.dictAddPronunciationSuccess),
        );
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    // Daftarkan face Charis SIL (sama pola OTP Orbitron).
    final charis = GoogleFonts.charisSil();

    return Material(
      color: theme.colors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.dictAddPronunciationTitle,
                style: theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Gap(4),
              Text(
                l10n.dictAddPronunciationBody,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(12),
              Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  variant: FButtonVariant.outline,
                  onPress: _busy ? null : _paste,
                  prefix: const Icon(FLucideIcons.clipboardPaste, size: 14),
                  child: Text(l10n.dictAddPronunciationPaste),
                ),
              ),
              const Gap(10),
              FTextField(
                control: FTextFieldControl.managed(controller: _ctrl),
                hint: l10n.dictAddPronunciationHint,
                enabled: !_busy,
                style: .delta(
                  contentTextStyle: .delta([
                    .all(
                      .delta(
                        fontFamily: charis.fontFamily,
                        fontSize: theme.typography.body.md.fontSize,
                        height: 1.3,
                      ),
                    ),
                  ]),
                ),
              ),
              const Gap(16),
              FButton(
                onPress: _busy ? null : _submit,
                prefix: _busy ? const FCircularProgress() : null,
                child: Text(
                  _busy
                      ? l10n.dictAddPronunciationSaving
                      : l10n.dictAddPronunciationSubmit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
