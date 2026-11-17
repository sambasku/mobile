import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Coming soon: Papan Peringkat Mingguan (slot tetap slide 2).
class BalehoWeeklyLeaderboardPage extends StatelessWidget {
  const BalehoWeeklyLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.balehoWeeklyLeaderboardTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/baleho'),
          ),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FLucideIcons.trophy,
                size: 48,
                color: theme.colors.primary,
              ),
              const Gap(16),
              FBadge(
                variant: FBadgeVariant.outline,
                child: Text(l10n.exploreComingSoon),
              ),
              const Gap(12),
              Text(
                l10n.balehoWeeklyLeaderboardTitle,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                l10n.balehoWeeklyLeaderboardComingSoonBody,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
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
