import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

/// Baris hasil pencarian compact (pola sheet KBBI): teks utama + meta muted
/// + chevron. Dipakai Jinye/lemma picker/KBBI supaya densitas seragam.
class CompactSearchHitTile extends StatelessWidget {
  const CompactSearchHitTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.titleMaxLines = 2,
    this.titleBold = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final int titleMaxLines;

  /// Lemma picker: lemma sebagai judul tebal. KBBI: definisi regular.
  final bool titleBold;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final sub = subtitle?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: titleBold ? FontWeight.w600 : null,
                      ),
                      maxLines: titleMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (sub != null && sub.isNotEmpty) ...[
                      const Gap(4),
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Gap(8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
