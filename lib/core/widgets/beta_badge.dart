import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Label kecil "BETA" warna destructive. Toggle lewat `F.isBeta`.
class BetaBadge extends StatelessWidget {
  const BetaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.destructive,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          'BETA',
          style: context.theme.typography.xs.copyWith(
            fontSize: 9,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: colors.destructiveForeground,
          ),
        ),
      ),
    );
  }
}
