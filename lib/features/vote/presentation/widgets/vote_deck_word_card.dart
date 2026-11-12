import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/gestures/swipe_exempt.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../dictionary/presentation/utils/pronunciation_format.dart';
import '../../domain/entities/vote_deck_item.dart';

/// Isi kartu deck (0101: per makna): lemma + definisi makna yang dinilai +
/// konteks "makna ke-N". Tap kartu / footer membuka detail kata induk
/// (semua makna, komentar) - pemilik navigasi ada di section, bukan sini.
class VoteDeckWordCard extends ConsumerWidget {
  const VoteDeckWordCard({
    super.key,
    required this.item,
    this.onOpenDetail,
    this.onWordClassTap,
    this.onAddWrittenPronunciation,
    this.onRecordPronunciation,
  });

  final VoteDeckItem item;

  /// Buka halaman detail kata (komentar, riwayat, …). Null = tanpa link.
  final VoidCallback? onOpenDetail;

  /// Shortcut: bottom sheet kelas → suggest-edit langsung. Null = chip diam.
  final VoidCallback? onWordClassTap;

  /// #260: tulis IPA bila kosong. Null = tanpa CTA.
  final VoidCallback? onAddWrittenPronunciation;

  /// #260: rekam audio bila belum ada. Null = tanpa CTA.
  final VoidCallback? onRecordPronunciation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VoteDeckMeaningFace(
      lemma: item.lemma,
      sense: item.sense,
      wordTypeLabel: item.wordTypeLabel,
      wordClassLabel: item.wordClassLabel,
      orderIndex: item.orderIndex,
      meaningCount: item.meaningCount,
      pronunciationValue: item.pronunciationValue,
      hasAudio: item.hasAudio,
      onOpenDetail: onOpenDetail,
      onWordClassTap: onWordClassTap,
      onAddWrittenPronunciation: onAddWrittenPronunciation,
      onRecordPronunciation: onRecordPronunciation,
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
    this.pronunciationValue,
    this.hasAudio = false,
    this.onOpenDetail,
    this.onLockedTap,
    this.onWordClassTap,
    this.onAddWrittenPronunciation,
    this.onRecordPronunciation,
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

  /// IPA tertulis kata; null = belum ada (#260).
  final String? pronunciationValue;

  /// Ada audio lemma (#260).
  final bool hasAudio;

  /// Login: tap lemma → detail kata induk. Null = lemma diam.
  final VoidCallback? onOpenDetail;

  /// Tamu: tap jenis membuka login. Null = label diam.
  final VoidCallback? onLockedTap;

  /// Login: tap kelas → picker + submit usulan. Null = badge read-only.
  final VoidCallback? onWordClassTap;

  /// #260: tulis IPA. Null = tanpa CTA.
  final VoidCallback? onAddWrittenPronunciation;

  /// #260: rekam audio. Null = tanpa CTA.
  final VoidCallback? onRecordPronunciation;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final ipa = pronunciationDisplay(pronunciationValue);
    final showPronCtas =
        onAddWrittenPronunciation != null || onRecordPronunciation != null;
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
          if (onOpenDetail != null)
            SwipeExemptRegion(
              child: FTappable(
                onPress: onOpenDetail,
                child: Semantics(
                  button: true,
                  label: l10n.voteDeckOpenDetail,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          lemma,
                          style: theme.typography.body.xl.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Gap(4),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: 18,
                        color: theme.colors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Text(
              lemma,
              style: theme.typography.body.xl.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          if (ipa.isNotEmpty) ...[
            const Gap(4),
            Text(
              ipa,
              textAlign: TextAlign.center,
              style: GoogleFonts.charisSil(
                fontSize: theme.typography.body.sm.fontSize,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                height: 1.3,
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
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
          if (showPronCtas) ...[
            const Gap(10),
            SwipeExemptRegion(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (onAddWrittenPronunciation != null)
                    FButton(
                      variant: FButtonVariant.ghost,
                      size: FButtonSizeVariant.sm,
                      onPress: onAddWrittenPronunciation,
                      prefix: const Icon(FLucideIcons.type, size: 14),
                      child: Text(l10n.dictAddPronunciation),
                    ),
                  if (onRecordPronunciation != null)
                    FButton(
                      variant: FButtonVariant.ghost,
                      size: FButtonSizeVariant.sm,
                      onPress: onRecordPronunciation,
                      prefix: const Icon(FLucideIcons.mic, size: 14),
                      child: Text(l10n.dictRecordPronunciation),
                    ),
                ],
              ),
            ),
          ],
          // Tamu: tile terkunci (tap = login).
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
          ] else if (onWordClassTap != null) ...[
            // Login: chip solid (bukan tile/tombol) → picker + POST suggest-edit.
            const Gap(12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                SwipeExemptRegion(
                  child: FTappable(
                    onPress: onWordClassTap,
                    child: Semantics(
                      button: true,
                      label: l10n.voteDeckWordClass,
                      child: FBadge.raw(
                        variant: FBadgeVariant.secondary,
                        builder: (context, style) {
                          final label = wordClassLabel.isEmpty
                              ? l10n.voteDeckWordClassUnset
                              : wordClassLabel;
                          final textStyle = style.labelTextStyle;
                          return Padding(
                            padding: style.padding,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(label, style: textStyle),
                                const Gap(2),
                                Icon(
                                  FLucideIcons.chevronDown,
                                  size: 12,
                                  color: textStyle.color,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (wordTypeLabel != 'Kata')
                  FBadge(
                    variant: FBadgeVariant.outline,
                    child: Text(wordTypeLabel),
                  ),
              ],
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
