import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

/// Kolom terjemahan dengan ikon buku KBBI menempel di pojok kanan atas.
///
/// Teks membungkus sampai 4 baris. Ikon tetap di pojok atas karena
/// InputDecorator menaruh suffix di tengah tinggi kotak.
class KbbiTranslationField extends StatelessWidget {
  const KbbiTranslationField({
    super.key,
    required this.controller,
    required this.onOpenKbbi,
    this.enabled = true,
    this.label,
    this.hint,
    this.description,
    this.error,
    this.textInputAction,
  });

  final TextEditingController controller;
  final VoidCallback onOpenKbbi;
  final bool enabled;
  final Widget? label;
  final String? hint;
  final Widget? description;
  final Widget? error;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return FTextField(
      control: FTextFieldControl.managed(controller: controller),
      enabled: enabled,
      minLines: 1,
      maxLines: 4,
      keyboardType: TextInputType.text,
      textAlignVertical: TextAlignVertical.top,
      textInputAction: textInputAction,
      label: label,
      hint: hint,
      description: description,
      error: error,
      style: FTextFieldStyleDelta.delta(
        contentPadding: EdgeInsetsGeometryDelta.value(
          const EdgeInsetsDirectional.fromSTEB(10, 9, 44, 9),
        ),
        constraints: const BoxConstraints(minHeight: 44),
      ),
      builder: (context, style, _, field) => Stack(
        children: [
          field,
          PositionedDirectional(
            top: 0,
            end: 0,
            child: ExcludeSemantics(
              // SemanticsNode tombol di suffix Forui bisa ber-rect terbalik
              // (duobaseio/forui#1160). Makna tombol ada di description.
              child: Padding(
                padding: style.clearButtonPadding,
                child: FButton.icon(
                  style: style.clearButtonStyle,
                  onPress: enabled ? onOpenKbbi : null,
                  child: const Icon(FLucideIcons.bookOpen),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
