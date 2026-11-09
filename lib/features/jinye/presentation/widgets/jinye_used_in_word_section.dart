import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/jinye_providers.dart';
import '../../domain/jinye_models.dart';
import '../../jinye_router.dart';

/// Section "Dipakai di Jinye" di detail lemma (Phase 7).
class JinyeUsedInWordSection extends ConsumerWidget {
  const JinyeUsedInWordSection({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final async = ref.watch(jinyeByWordProvider(wordId));

    return async.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Gap(20),
            Text(
              l10n.jinyeUsedInWordTitle,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Gap(8),
            FTileGroup(
              children: [
                for (final item in items)
                  FTile(
                    title: Text(_preview(item, l10n)),
                    subtitle: Text(
                      item.displayName?.trim().isNotEmpty == true
                          ? item.displayName!
                          : (item.username ?? '-'),
                    ),
                    onPress: () =>
                        context.push(JinyeRouter.detailPath(item.id)),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  static String _preview(JinyeItem item, AppLocalizations l10n) {
    if (item.isQuote) {
      final q = item.quoteBody!.trim();
      return q.length <= 80 ? q : '${q.substring(0, 80)}…';
    }
    final body = item.body.trim();
    if (body.isNotEmpty) {
      return body.length <= 80 ? body : '${body.substring(0, 80)}…';
    }
    if (item.hasAudio) return l10n.jinyePreviewVoiceOnly;
    if (item.hasDisplayableImages) return l10n.jinyePreviewPhotoOnly;
    return l10n.jinyePreviewEmpty;
  }
}
