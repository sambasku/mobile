import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';

/// Field URL dengan tombol Tempel di dalam container field (suffix).
///
/// Tempel clipboard OS - lebih enak di HP daripada long-press field.
class PasteableUrlField extends StatelessWidget {
  const PasteableUrlField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.description,
    this.error,
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = false,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction = TextInputAction.next,
    this.onSubmit,
    this.onChanged,
  });

  final TextEditingController controller;
  final Widget? label;
  final String? hint;
  final Widget? description;
  final Widget? error;
  final bool enabled;
  final bool autofocus;
  final bool autocorrect;
  final int? maxLines;
  final int? minLines;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmit;
  final ValueChanged<TextEditingValue>? onChanged;

  Future<void> _paste(BuildContext context) async {
    if (!enabled) return;
    final l10n = AppLocalizations.of(context);
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (!context.mounted) return;
    if (text.isEmpty) {
      showFToast(
        context: context,
        title: Text(l10n.commonClipboardEmpty),
      );
      return;
    }
    controller
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    onChanged?.call(controller.value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FTextField(
      control: FTextFieldControl.managed(
        controller: controller,
        onChange: onChanged,
      ),
      label: label,
      hint: hint,
      description: description,
      error: error,
      enabled: enabled,
      autofocus: autofocus,
      autocorrect: autocorrect,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: TextInputType.url,
      textInputAction: textInputAction,
      onSubmit: onSubmit,
      suffixBuilder: (context, style, variants) {
        final disabled =
            !enabled || variants.contains(FTextFieldVariant.disabled);
        return Padding(
          padding: style.clearButtonPadding,
          child: FButton.icon(
            style: style.clearButtonStyle,
            onPress: disabled ? null : () => _paste(context),
            child: Icon(
              FLucideIcons.clipboardPaste,
              semanticLabel: l10n.commonPaste,
            ),
          ),
        );
      },
    );
  }
}
