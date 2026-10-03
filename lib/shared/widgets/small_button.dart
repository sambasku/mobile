import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Tombol kecil (FButton xs) untuk area sempit: header kartu, baris aksi.
class SmallButton extends StatelessWidget {
  const SmallButton({
    super.key,
    required this.label,
    required this.onPress,
    this.variant = FButtonVariant.outline,
    this.prefixIcon,
  });

  final String label;
  final VoidCallback? onPress;
  final FButtonVariant variant;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return FButton(
      variant: variant,
      size: FButtonSizeVariant.xs,
      onPress: onPress,
      prefix: prefixIcon == null ? null : Icon(prefixIcon),
      child: Text(label),
    );
  }
}
