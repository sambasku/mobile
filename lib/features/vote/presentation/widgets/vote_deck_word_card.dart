import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/gestures/swipe_exempt.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/vote_deck_item.dart';

/// Isi kartu deck (0101: per makna): lemma + definisi makna yang dinilai +
/// konteks "makna ke-N". Tap kartu / footer membuka detail kata induk
/// (semua makna, komentar) - pemilik navigasi ada di section, bukan sini.
class VoteDeckWordCard extends ConsumerWidget {
  const VoteDeckWordCard({super.key, required this.item, this.onOpenDetail});

  final VoteDeckItem item;

  /// Buka halaman detail kata (komentar, riwayat, …). Null = tanpa link.
  final VoidCallback? onOpenDetail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VoteDeckMeaningFace(
      lemma: item.lemma,
      sense: item.sense,
      wordTypeLabel: item.wordTypeLabel,
      wordClassLabel: item.wordClassLabel,
      orderIndex: item.orderIndex,
      meaningCount: item.meaningCount,
    );
  }
}

/// Tampilan ringkas kartu (lemma, definisi makna ini, jenis kata):
/// deck login, guest deck, dan fallback.
class VoteDeckMeaningFace extends StatelessWidget {
  const VoteDeckMeaningFace({
    super.key,
    required this.lemma,
    required this.sense,
    required this.wordTypeLabel,
    this.wordClassLabel = '',
    this.orderIndex = 1,
    this.meaningCount = 1,
    this.onLockedTap,
  });

  final String lemma;

  /// Definisi makna yang dinilai (bukan makna pertama kata).
  final String? sense;

  /// Label jenis entri ("Kata", "Idiom", ...).
  final String wordTypeLabel;

  /// Label kelas kata makna ini ("Kata Benda", "Umum"). Kosong = belum ada.
  final String wordClassLabel;

  /// 1-based; label "Makna ke-N" hanya muncul bila kata punya >1 makna.
  final int orderIndex;

  /// Jumlah makna published kata ini.
  final int meaningCount;

  /// Tamu: tap jenis membuka login. Null = label diam.
  final VoidCallback? onLockedTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (meaningCount > 1) ...[
            Text(
              'Makna ke-$orderIndex dari $meaningCount',
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(6),
          ],
          Text(
            lemma,
            style: theme.typography.body.xl.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          if (sense != null && sense!.trim().isNotEmpty) ...[
            const Gap(10),
            Text(
              sense!,
              style: theme.typography.body.md.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          // Tamu: tile terkunci (tap = login). User login: chip read-only.
          if (onLockedTap != null) ...[
            const Gap(12),
            SwipeExemptRegion(
              child: FTileGroup(
                children: [
                  FTile(
                    title: Text(l10n.voteEntryType),
                    details: Text(wordTypeLabel),
                    suffix: Icon(
                      FLucideIcons.chevronRight,
                      color: theme.colors.mutedForeground,
                    ),
                    onPress: onLockedTap,
                  ),
                ],
              ),
            ),
          ] else if (wordClassLabel.isNotEmpty || wordTypeLabel != 'Kata') ...[
            const Gap(12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                if (wordClassLabel.isNotEmpty)
                  FBadge(
                    variant: FBadgeVariant.secondary,
                    child: Text(wordClassLabel),
                  ),
                if (wordTypeLabel != 'Kata')
                  FBadge(
                    variant: FBadgeVariant.outline,
                    child: Text(wordTypeLabel),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
