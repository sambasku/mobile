import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// List compact gaya panel Analitik (`kpi_cards.dart`): satu kartu luar
/// (background + border 1px + radius 10), baris label/subtitle kiri + nilai/
/// aksi kanan, dipisah divider 1px `colors.border`. Tanpa dekorasi tambahan.
///
/// Pakai bersama [CompactRow] di dalam `ListView`/`PagedListView`.
class CompactListCard extends StatelessWidget {
  const CompactListCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.theme.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Bingkai list scrollable: kartu border + radius + clip, anak scroll bebas.
/// Buat membungkus `ListView`/`PagedListView` penuh tanpa kehilangan border.
class CompactListFrame extends StatelessWidget {
  const CompactListFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.colors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.theme.colors.border),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(9), child: child),
    );
  }
}

/// Divider 1px antar baris compact.
class CompactDivider extends StatelessWidget {
  const CompactDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.theme.colors.border),
      child: const SizedBox(height: 1, width: double.infinity),
    );
  }
}

/// Satu baris list compact: [title] + [subtitle] kiri, [trailing] kanan.
/// Seluruh baris bisa di-tap bila [onTap] diberikan.
class CompactRow extends StatelessWidget {
  const CompactRow({
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.leading,
    this.trailing,
    this.onTap,
    this.subtitleColor,
    this.titleColor,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Subtitle custom (rich text). Menang atas [subtitle].
  final Widget? subtitleWidget;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? subtitleColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final effectiveSubtitle =
        subtitleWidget ??
        (subtitle != null
            ? Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.xs.copyWith(
                  color: subtitleColor ?? theme.colors.mutedForeground,
                ),
              )
            : null);
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (leading case final leading?) ...[
            leading,
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                ?effectiveSubtitle,
              ],
            ),
          ),
          if (trailing case final trailing?) ...[
            const SizedBox(width: 12),
            trailing,
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: row,
    );
  }
}
