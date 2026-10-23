import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

/// Dua toggle independen (bukan radio): Terjemahan / Penjelasan arti.
/// Keduanya boleh aktif sekaligus; keduanya mati = belum memilih.
class KnowledgeToggles extends StatelessWidget {
  const KnowledgeToggles({
    super.key,
    required this.wantDefinition,
    required this.wantPadanan,
    required this.onDefinitionChanged,
    required this.onPadananChanged,
  });

  final bool wantDefinition;
  final bool wantPadanan;
  final ValueChanged<bool> onDefinitionChanged;
  final ValueChanged<bool> onPadananChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: KnowledgeToggleChip(
            label: 'Terjemahan',
            selected: wantPadanan,
            onTap: () => onPadananChanged(!wantPadanan),
          ),
        ),
        const Gap(10),
        Expanded(
          child: KnowledgeToggleChip(
            label: 'Penjelasan arti',
            selected: wantDefinition,
            onTap: () => onDefinitionChanged(!wantDefinition),
          ),
        ),
      ],
    );
  }
}

/// Opsi bergaya checklist: kotak centang kiri + label, lebar penuh.
class KnowledgeToggleChip extends StatelessWidget {
  const KnowledgeToggleChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final borderColor = selected ? theme.colors.primary : theme.colors.border;
    final bg = selected
        ? theme.colors.primary.withValues(alpha: 0.08)
        : theme.colors.background;
    final labelColor =
        selected ? theme.colors.primary : theme.colors.foreground;
    final markBg = selected ? theme.colors.primary : theme.colors.background;
    final markBorder =
        selected ? theme.colors.primary : theme.colors.mutedForeground;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: markBg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: markBorder, width: 1.5),
              ),
              child: selected
                  ? Icon(
                      FLucideIcons.check,
                      size: 12,
                      color: theme.colors.primaryForeground,
                    )
                  : null,
            ),
            const Gap(10),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: labelColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String knowledgeHint({required bool wantDefinition, required bool wantPadanan}) {
  if (!wantDefinition && !wantPadanan) {
    return 'Centang Penjelasan arti dan/atau Terjemahan. Form makna muncul setelah itu.';
  }
  if (wantDefinition && wantPadanan) {
    return 'Isi terjemahan dan penjelasan arti.';
  }
  if (wantDefinition) {
    return 'Isi uraian makna. Terjemahan bisa dilengkapi nanti.';
  }
  return 'Isi terjemahan saja. Penjelasan arti bisa dilengkapi nanti.';
}
