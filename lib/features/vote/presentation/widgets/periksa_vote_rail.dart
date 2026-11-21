import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Kolom vote kanan - full bleed; isi (2 tombol) mengisi 100% area.
class PeriksaVoteRail extends StatelessWidget {
  const PeriksaVoteRail({
    super.key,
    required this.child,
    this.width = 100,
    this.cornerRadius = 10,
  });

  final Widget child;
  final double width;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radius = Radius.circular(cornerRadius);
    final outerRadius = BorderRadius.only(topRight: radius, bottomRight: radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: outerRadius,
        border: Border.all(color: theme.colors.border),
      ),
      child: ClipRRect(
        borderRadius: outerRadius,
        child: SizedBox(
          width: width,
          child: child,
        ),
      ),
    );
  }
}
