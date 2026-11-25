import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../dictionary/domain/entities/word_detail.dart';
import '../../karya_router.dart';

/// Section "Muncul di karya" di detail lemma (G5).
class KaryaUsedInWordSection extends StatelessWidget {
  const KaryaUsedInWordSection({super.key, required this.appearances});

  final List<WordAppearsInKarya> appearances;

  @override
  Widget build(BuildContext context) {
    if (appearances.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(20),
        Text(
          l10n.karyaAppearsInWordTitle,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
        const Gap(8),
        FTileGroup(
          children: [
            for (final row in appearances)
              FTile(
                title: Text(row.karyaTitle),
                subtitle: Text(_snippetPreview(row.snippet)),
                onPress: () => context.push(KaryaRouter.detailPath(row.karyaSlug)),
              ),
          ],
        ),
      ],
    );
  }

  static String _snippetPreview(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '-';
    return t.length <= 100 ? t : '${t.substring(0, 100)}…';
  }
}