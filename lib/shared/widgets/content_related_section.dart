import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';
import '../models/content_related_link.dart';
import '../utils/content_related_nav.dart';

/// Section kartu tautan lintas fitur (detail artikel / lemma / eksplorasi).
class ContentRelatedSection extends StatelessWidget {
  const ContentRelatedSection({
    super.key,
    required this.items,
    this.title,
    this.filterKinds,
  });

  final List<ContentRelatedLink> items;
  final String? title;

  /// Kalau diisi, hanya tampilkan kind ini (mis. artikel di detail lemma).
  final Set<String>? filterKinds;

  @override
  Widget build(BuildContext context) {
    final filtered = filterKinds == null
        ? items
        : items.where((e) => filterKinds!.contains(e.kind)).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(24),
        Text(
          title ?? l10n.contentRelatedSection,
          style: theme.typography.display.sm.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(8),
        FTileGroup(
          children: [
            for (final row in filtered)
              FTile(
                title: Text(row.title),
                subtitle: Text(contentRelatedKindLabel(l10n, row.kind)),
                suffix: Icon(
                  FLucideIcons.chevronRight,
                  size: 16,
                  color: theme.colors.mutedForeground,
                ),
                onPress: () => openContentRelatedLink(context, row),
              ),
          ],
        ),
      ],
    );
  }
}
