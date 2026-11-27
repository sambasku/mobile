import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cover_hero.dart';
import '../../../../shared/widgets/profile_hero_shell.dart';
import '../../../../shared/widgets/profile_identity_header.dart';
import '../../../user_profile/presentation/widgets/profile_activity_section.dart'
    show OverlapAboveBox, ProfileBarClearanceHeader;
import '../widgets/meaning_vote_row.dart';
import '../widgets/periksa_kata_card_shell.dart';
import '../widgets/periksa_meaning_blurb.dart';
import '../widgets/periksa_vote_rail.dart';
import '../widgets/periksa_vote_split_panel.dart';

/// Panduan Periksa Kata: hero full-bleed ala halaman Komunitas, artikel
/// redaksi yang utuh tanpa teks terpotong, dan simulasi voting interaktif.
///
/// Simulasi murni lokal (tanpa API). Kartu contoh memakai komponen asli
/// Periksa Kata supaya tampilannya sama dengan feed.
class PeriksaKataGuidePage extends StatefulWidget {
  const PeriksaKataGuidePage({super.key});

  @override
  State<PeriksaKataGuidePage> createState() => _PeriksaKataGuidePageState();
}

enum _SimStatus { waiting, verified, rejected }

class _PeriksaKataGuidePageState extends State<PeriksaKataGuidePage> {
  /// Suara contoh. Ambang sama dengan backend (net dan jumlah pemilih).
  int _agree = 0;
  int _disagree = 0;

  /// Vote "kamu" di simulasi: 1 setuju, -1 tidak setuju, null belum vote.
  int? _mine;

  int get _voters => _agree + _disagree;
  int get _net => _agree - _disagree;

  _SimStatus get _status {
    if (_voters < kVotingWargaNetThreshold) return _SimStatus.waiting;
    if (_net >= kVotingWargaNetThreshold) return _SimStatus.verified;
    if (_net <= -kVotingWargaNetThreshold) return _SimStatus.rejected;
    return _SimStatus.waiting;
  }

  void _count(int value, int delta) {
    if (value == 1) {
      _agree += delta;
    } else {
      _disagree += delta;
    }
  }

  /// Sama seperti vote asli: arah sama = batal, arah lain = ganti.
  void _toggleMine(int value) {
    setState(() {
      final previous = _mine;
      if (previous != null) _count(previous, -1);
      if (previous == value) {
        _mine = null;
        return;
      }
      _count(value, 1);
      _mine = value;
    });
  }

  void _addWarga(int value) => setState(() => _count(value, 1));

  void _reset() {
    setState(() {
      _agree = 0;
      _disagree = 0;
      _mine = null;
    });
  }

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

    final statusText = switch (_status) {
      _SimStatus.verified => l10n.periksaKataGuideSimVerified,
      _SimStatus.rejected => l10n.periksaKataGuideSimRejected,
      _SimStatus.waiting => l10n.periksaKataGuideSimWaiting(
        _voters,
        kVotingWargaNetThreshold,
        _net,
      ),
    };
    final statusColor = switch (_status) {
      _SimStatus.verified => const Color(0xFF16A34A),
      _SimStatus.rejected => const Color(0xFFDC2626),
      _SimStatus.waiting => theme.colors.mutedForeground,
    };

    return FScaffold(
      childPad: false,
      child: ProfileHeroShell(
        showBack: true,
        onBack: () => context.pop(),
        backLabel: l10n.commonBack,
        coverHeight: coverHeight,
        title: l10n.periksaKataGuideTitle,
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
                  asset: 'assets/images/periksa_kata_hero.webp',
                  title: l10n.periksaKataGuideHeroTitle,
                  subtitle: l10n.periksaKataGuideHeroBody,
                  semanticLabel: l10n.periksaKataGuideHeroSemantics,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 28 + padding.bottom),
              sliver: SliverList.list(
                children: [
                  Text(l10n.periksaKataGuideIntro, style: bodyStyle),
                  const Gap(24),
                  Text(l10n.periksaKataGuideStepsTitle, style: sectionStyle),
                  const Gap(10),
                  _EditorialCard(
                    children: [
                      _EditorialItem(
                        leading: const _StepBadge(step: 1),
                        title: l10n.periksaKataGuideStep1Title,
                        body: l10n.periksaKataGuideStep1Body,
                      ),
                      _EditorialItem(
                        leading: const _StepBadge(step: 2),
                        title: l10n.periksaKataGuideStep2Title,
                        body: l10n.periksaKataGuideStep2Body,
                      ),
                      _EditorialItem(
                        leading: const _StepBadge(step: 3),
                        title: l10n.periksaKataGuideStep3Title,
                        body: l10n.periksaKataGuideStep3Body,
                      ),
                    ],
                  ),
                  const Gap(24),
                  Text(l10n.periksaKataGuideRulesTitle, style: sectionStyle),
                  const Gap(10),
                  _EditorialCard(
                    children: [
                      _EditorialItem(
                        leading: const Icon(
                          FLucideIcons.circleCheck,
                          size: 20,
                          color: Color(0xFF16A34A),
                        ),
                        title: l10n.periksaKataGuideRuleVerifyTitle,
                        body: l10n.periksaKataGuideRuleVerifyBody,
                      ),
                      _EditorialItem(
                        leading: const Icon(
                          FLucideIcons.circleX,
                          size: 20,
                          color: Color(0xFFDC2626),
                        ),
                        title: l10n.periksaKataGuideRuleRejectTitle,
                        body: l10n.periksaKataGuideRuleRejectBody,
                      ),
                      _EditorialItem(
                        leading: Icon(
                          FLucideIcons.clock,
                          size: 20,
                          color: theme.colors.mutedForeground,
                        ),
                        title: l10n.periksaKataGuideRuleWaitTitle,
                        body: l10n.periksaKataGuideRuleWaitBody,
                      ),
                    ],
                  ),
                  const Gap(24),
                  Text(l10n.periksaKataGuideSimTitle, style: sectionStyle),
                  const Gap(6),
                  Text(l10n.periksaKataGuideSimBody, style: mutedStyle),
                  const Gap(12),
                  PeriksaKataCardShell(
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 6, 8, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PeriksaLemmaHeader(
                                lemma: l10n.periksaKataGuideSampleLemma,
                              ),
                              PeriksaMeaningBlurb(
                                translation:
                                    l10n.periksaKataGuideSampleTranslation,
                                definition:
                                    l10n.periksaKataGuideSampleDefinition,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                          child: VoteTrustProgress(
                            upvotes: _agree,
                            downvotes: _disagree,
                          ),
                        ),
                      ],
                    ),
                    voteRail: PeriksaVoteRail(
                      child: PeriksaVoteSplitPanel(
                        upvotes: _agree,
                        downvotes: _disagree,
                        myVote: _mine,
                        disagreeSemantics: l10n.periksaKataDisagree,
                        agreeSemantics: l10n.periksaKataAgree,
                        onVote: (value) async => _toggleMine(value),
                      ),
                    ),
                  ),
                  const Gap(12),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        statusText,
                        style: theme.typography.body.sm.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => _addWarga(1),
                        child: Text(l10n.periksaKataGuideSimAgree),
                      ),
                      FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => _addWarga(-1),
                        child: Text(l10n.periksaKataGuideSimDisagree),
                      ),
                      FButton(
                        variant: FButtonVariant.ghost,
                        onPress: _reset,
                        child: Text(l10n.periksaKataGuideSimReset),
                      ),
                    ],
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

/// Container kartu redaksi dengan pemisah tipis; seluruh teks membungkus utuh
/// (tidak terpotong 1 baris seperti FTile default).
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
    required this.body,
  });

  final Widget leading;
  final String title;
  final String body;

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
                const Gap(4),
                Text(
                  body,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
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
