import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

/// Bingkai area kiri karya (sampul / poster / thumb daftar).
class KaryaMediaFrame extends StatelessWidget {
  const KaryaMediaFrame({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.secondary,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: theme.colors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 1),
          child: child,
        ),
      ),
    );
  }
}
