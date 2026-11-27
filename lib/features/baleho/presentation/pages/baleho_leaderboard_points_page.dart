import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/format_number.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cover_hero.dart';
import '../../../../shared/widgets/profile_hero_shell.dart';
import '../../../../shared/widgets/profile_identity_header.dart';
import '../../../user_profile/presentation/widgets/profile_activity_section.dart'
    show OverlapAboveBox, ProfileBarClearanceHeader;
import '../../domain/baleho_models.dart';

/// Penjelasan cara dapat poin papan peringkat mingguan.
///
/// Angka poin harus sama dengan konstanta `LEADERBOARD_*` di
/// `api/src/modules/leaderboard/domain/utils/iso-week.ts`.
///
/// Susunan halaman mengikuti panduan Periksa Kata: hero ilustrasi full-bleed
/// dan kartu redaksi supaya teks panjang tidak terpotong.
class BalehoLeaderboardPointsPage extends StatelessWidget {
  const BalehoLeaderboardPointsPage({super.key});

  static const createPoints = 5;
  static const editPoints = 3;
  static const approvedPoints = 2;
  static const verifyPoints = 2;

  /// Angka contoh simulasi (5+2+3+4); harus selaras dengan teks ARB.
  static const _exampleVerifyCount = 2;
  static int get _exampleFromSubmissions =>
      createPoints + approvedPoints + editPoints;
  static int get _exampleFromVerify => verifyPoints * _exampleVerifyCount;
  static int get _exampleTotal => _exampleFromSubmissions + _exampleFromVerify;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final padding = MediaQuery.paddingOf(context);
    final coverHeight = ProfileIdentityHeader.coverHeightOf(
      ProfileHeaderVariant.compact,
      MediaQuery.sizeOf(context).width,
    );
    final barOffset = padding.top + ProfileHeroShell.barHeight;
    final bodyStyle = theme.typography.body.sm.copyWith(
      color: theme.colors.foreground.withValues(alpha: 0.9),
      height: 1.55,
    );
    final mutedStyle = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
      height: 1.5,
    );
    final sectionStyle = theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.3,
    );
    final pointsStyle = theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w800,
      color: theme.colors.primary,
    );

    return FScaffold(
      childPad: false,
      child: ProfileHeroShell(
        showBack: true,
        onBack: () => context.canPop()
            ? context.pop()
            : context.go(BalehoBoard.weeklyLeaderboardPath),
        backLabel: l10n.commonBack,
        coverHeight: coverHeight,
        title: l10n.balehoPointsGuideTitle,
        compactActions: true,
        scrollView: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: ProfileBarClearanceHeader(height: barOffset),
            ),
            SliverToBoxAdapter(
              child: OverlapAboveBox(
                overlap: barOffset,
                child: CoverHero(
                  asset: 'assets/images/baleho_points_hero.webp',
                  title: l10n.balehoPointsGuideHeroTitle,
                  subtitle: l10n.balehoPointsGuideHeroBody,
                  semanticLabel: l10n.balehoPointsGuideHeroSemantics,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 28 + padding.bottom),
              sliver: SliverList.list(
                children: [
                  Text(l10n.balehoPointsGuideIntro, style: bodyStyle),
                  const Gap(24),
                  Text(l10n.balehoPointsGuideTableTitle, style: sectionStyle),
                  const Gap(10),
                  _EditorialCard(
                    children: [
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.filePlus,
                          size: 20,
                          color: theme.colors.primary,
                        ),
                        title: l10n.balehoPointsGuideCreateTitle,
                        body: l10n.balehoPointsGuideCreateWhen,
                        trailing: Text(
                          l10n.balehoPointsGuidePoints(createPoints),
                          style: pointsStyle,
                        ),
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.pencilLine,
                          size: 20,
                          color: theme.colors.primary,
                        ),
                        title: l10n.balehoPointsGuideEditTitle,
                        body: l10n.balehoPointsGuideEditWhen,
                        trailing: Text(
                          l10n.balehoPointsGuidePoints(editPoints),
                          style: pointsStyle,
                        ),
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.circleCheck,
                          size: 20,
                          color: theme.colors.primary,
                        ),
                        title: l10n.balehoPointsGuideApprovedTitle,
                        body: l10n.balehoPointsGuideApprovedWhen,
                        trailing: Text(
                          l10n.balehoPointsGuidePoints(approvedPoints),
                          style: pointsStyle,
                        ),
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.shieldCheck,
                          size: 20,
                          color: theme.colors.primary,
                        ),
                        title: l10n.balehoPointsGuideVerifyTitle,
                        body: l10n.balehoPointsGuideVerifyWhen,
                        trailing: Text(
                          l10n.balehoPointsGuidePoints(verifyPoints),
                          style: pointsStyle,
                        ),
                      ),
                    ],
                  ),
                  const Gap(24),
                  Text(l10n.balehoPointsGuideFairTitle, style: sectionStyle),
                  const Gap(10),
                  _EditorialCard(
                    children: [
                      _EditorialItem(
                        leading: const Icon(
                          FLucideIcons.circleX,
                          size: 20,
                          color: Color(0xFFDC2626),
                        ),
                        title: l10n.balehoPointsGuideRuleRejected,
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.badgeCheck,
                          size: 20,
                          color: theme.colors.primary,
                        ),
                        title: l10n.balehoPointsGuideRuleBonus,
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.userX,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                        title: l10n.balehoPointsGuideRuleSelfVerify,
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.ban,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                        title: l10n.balehoPointsGuideRuleExcluded,
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.timer,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                        title: l10n.balehoPointsGuideRuleReset,
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.share2,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                        title: l10n.balehoPointsGuideRuleShare,
                      ),
                    ],
                  ),
                  const Gap(24),
                  Text(l10n.balehoPointsGuideExampleTitle, style: sectionStyle),
                  const Gap(6),
                  Text(l10n.balehoPointsGuideExampleIntro, style: mutedStyle),
                  const Gap(12),
                  _EditorialCard(
                    children: [
                      _EditorialItem(
                        leading: const _StepBadge(step: 1),
                        title: l10n.balehoPointsGuideExampleLine1,
                        body: l10n.balehoPointsGuideExampleLine1Detail,
                        trailing: Text(
                          l10n.balehoPointsGuidePoints(createPoints),
                          style: pointsStyle,
                        ),
                      ),
                      _EditorialItem(
                        leading: const _StepBadge(step: 2),
                        title: l10n.balehoPointsGuideExampleLine2,
                        body: l10n.balehoPointsGuideExampleLine2Detail,
                        trailing: Text(
                          l10n.balehoPointsGuidePoints(approvedPoints),
                          style: pointsStyle,
                        ),
                      ),
                      _EditorialItem(
                        leading: const _StepBadge(step: 3),
                        title: l10n.balehoPointsGuideExampleLine3,
                        body: l10n.balehoPointsGuideExampleLine3Detail,
                        trailing: Text(
                          l10n.balehoPointsGuidePoints(editPoints),
                          style: pointsStyle,
                        ),
                      ),
                      _EditorialItem(
                        leading: const _StepBadge(step: 4),
                        title: l10n.balehoPointsGuideExampleLine4,
                        body: l10n.balehoPointsGuideExampleLine4Detail,
                        trailing: Text(
                          l10n.balehoPointsGuidePoints(_exampleFromVerify),
                          style: pointsStyle,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  _EditorialCard(
                    children: [
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.calculator,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                        title: l10n.balehoPointsGuideExampleSubtotalWords(
                          formatRibuan(_exampleFromSubmissions),
                        ),
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.calculator,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                        title: l10n.balehoPointsGuideExampleSubtotalVerify(
                          formatRibuan(_exampleFromVerify),
                          _exampleVerifyCount,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            FLucideIcons.trophy,
                            size: 20,
                            color: theme.colors.primary,
                          ),
                          const Gap(12),
                          Expanded(
                            child: Text(
                              l10n.balehoPointsGuideExampleTotalLabel,
                              style: theme.typography.body.md.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const Gap(8),
                          Text(
                            l10n.balehoPointsGuideExampleTotal(
                              formatRibuan(_exampleTotal),
                            ),
                            style: pointsStyle.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialCard extends StatelessWidget {
  const _EditorialCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: FDivider(
                  style: FDividerStyleDelta.delta(
                    padding: EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _EditorialItem extends StatelessWidget {
  const _EditorialItem({
    required this.leading,
    required this.title,
    this.body,
    this.trailing,
  });

  final Widget leading;
  final String title;
  final String? body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: leading),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
                if (body != null) ...[
                  const Gap(4),
                  Text(
                    body!,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const Gap(8), trailing!],
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colors.primary.withValues(alpha: 0.12),
      ),
      child: Text(
        '$step',
        style: theme.typography.body.xs.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colors.primary,
        ),
      ),
    );
  }
}
