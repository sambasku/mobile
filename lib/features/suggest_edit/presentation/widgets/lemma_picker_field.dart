import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import 'lemma_csv.dart';
import 'lemma_search_picker_sheet.dart';

/// Field relasi lemma: chip terpilih + bottomsheet cari (#265).
///
/// Lemma baru yang belum di kamus tetap bisa lewat opsi "pakai sebagai
/// lemma baru" di dalam sheet.
class LemmaPickerField extends ConsumerStatefulWidget {
  const LemmaPickerField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.error,
    this.excludeLemmas = const {},
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Widget? error;

  /// Lemma yang tidak boleh dipilih lagi (diri sendiri / sudah dipilih di
  /// field lain).
  final Set<String> excludeLemmas;

  @override
  ConsumerState<LemmaPickerField> createState() => _LemmaPickerFieldState();
}

class _LemmaPickerFieldState extends ConsumerState<LemmaPickerField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCtrl);
  }

  @override
  void didUpdateWidget(covariant LemmaPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onCtrl);
      widget.controller.addListener(_onCtrl);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCtrl);
    super.dispose();
  }

  void _onCtrl() {
    if (mounted) setState(() {});
  }

  List<String> get _selected => parseLemmaCsv(widget.controller.text);

  Future<void> _openPicker() async {
    final picked = await showLemmaSearchPickerSheet(
      context,
      title: widget.label,
      excludeLemmas: {
        ...widget.excludeLemmas,
        ..._selected,
      },
    );
    if (!mounted || picked == null) return;
    widget.controller.text = appendLemmaCsv(widget.controller.text, picked);
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
  }

  void _remove(String lemma) {
    widget.controller.text = removeLemmaCsv(widget.controller.text, lemma);
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final selected = _selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(4),
        Text(
          widget.hint,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
            fontSize: 12,
          ),
        ),
        const Gap(8),
        if (selected.isNotEmpty) ...[
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final lemma in selected)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _remove(lemma),
                    borderRadius: BorderRadius.circular(8),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(lemma, style: theme.typography.body.sm),
                          const Gap(4),
                          Icon(
                            FLucideIcons.x,
                            size: 14,
                            color: theme.colors.mutedForeground,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(8),
        ],
        FButton(
          variant: FButtonVariant.outline,
          onPress: _openPicker,
          prefix: const Icon(FLucideIcons.search),
          child: Text(
            selected.isEmpty
                ? l10n.lemmaPickerPickButton
                : l10n.lemmaPickerAddAnother,
          ),
        ),
        if (widget.error != null) ...[
          const Gap(6),
          widget.error!,
        ],
      ],
    );
  }
}
