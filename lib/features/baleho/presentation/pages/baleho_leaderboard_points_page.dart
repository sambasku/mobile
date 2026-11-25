import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/baleho_models.dart';

/// Penjelasan cara dapat poin papan peringkat mingguan.
///
/// Angka poin harus sama dengan konstanta `LEADERBOARD_*` di
/// `api/src/modules/leaderboard/domain/utils/iso-week.ts`.
class BalehoLeaderboardPointsPage extends StatelessWidget {
  const BalehoLeaderboardPointsPage({super.key});

  static const createPoints = 5;
  static const editPoints = 3;
  static const approvedPoints = 2;
  static const verifyPoints = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final mutedStyle = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final sectionStyle = theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w700,
    );
    final pointsStyle = theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colors.primary,
    );

    FTile pointRow(IconData icon, String title, String when, int points) {
      return FTile(
        prefix: Icon(icon, size: 18, color: theme.colors.primary),
        title: Text(title),
        subtitle: Text(when),
        suffix: Text(l10n.balehoPointsGuidePoints(points), style: pointsStyle),
      );
    }

    FTile ruleRow(IconData icon, String text) {
      return FTile(
        prefix: Icon(icon, size: 18, color: theme.colors.mutedForeground),
        title: Text(text, maxLines: 4),
      );
    }

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.balehoPointsGuideTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(BalehoBoard.weeklyLeaderboardPath),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
        children: [
          Text(l10n.balehoPointsGuideIntro, style: mutedStyle),
          const Gap(16),
          Text(l10n.balehoPointsGuideTableTitle, style: sectionStyle),
          const Gap(8),
          FTileGroup(
            children: [
              pointRow(
                FLucideIcons.filePlus,
                l10n.balehoPointsGuideCreateTitle,
                l10n.balehoPointsGuideCreateWhen,
                createPoints,
              ),
              pointRow(
                FLucideIcons.pencilLine,
                l10n.balehoPointsGuideEditTitle,
                l10n.balehoPointsGuideEditWhen,
                editPoints,
              ),
              pointRow(
                FLucideIcons.circleCheck,
                l10n.balehoPointsGuideApprovedTitle,
                l10n.balehoPointsGuideApprovedWhen,
                approvedPoints,
              ),
              pointRow(
                FLucideIcons.shieldCheck,
                l10n.balehoPointsGuideVerifyTitle,
                l10n.balehoPointsGuideVerifyWhen,
                verifyPoints,
              ),
            ],
          ),
          const Gap(20),
          Text(l10n.balehoPointsGuideFairTitle, style: sectionStyle),
          const Gap(8),
          FTileGroup(
            children: [
              ruleRow(FLucideIcons.circleX, l10n.balehoPointsGuideRuleRejected),
              ruleRow(FLucideIcons.badgeCheck, l10n.balehoPointsGuideRuleBonus),
              ruleRow(FLucideIcons.userX, l10n.balehoPointsGuideRuleSelfVerify),
              ruleRow(FLucideIcons.ban, l10n.balehoPointsGuideRuleExcluded),
              ruleRow(FLucideIcons.timer, l10n.balehoPointsGuideRuleReset),
              ruleRow(FLucideIcons.share2, l10n.balehoPointsGuideRuleShare),
            ],
          ),
          const Gap(20),
          Text(l10n.balehoPointsGuideExampleTitle, style: sectionStyle),
          const Gap(8),
          FTileGroup(
            children: [
              FTile(
                prefix: Icon(
                  FLucideIcons.calculator,
                  size: 18,
                  color: theme.colors.primary,
                ),
                title: Text(l10n.balehoPointsGuideExampleBody, maxLines: 4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
