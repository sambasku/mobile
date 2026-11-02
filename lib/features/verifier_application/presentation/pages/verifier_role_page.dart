import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';

/// Halaman penjelasan peran verifikator (statis, tanpa API).
class VerifierRolePage extends StatelessWidget {
  const VerifierRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.verifierApplicationRoleTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/verifier-application'),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
        children: [
          Text(
            l10n.verifierApplicationRoleIntro,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
              height: 1.4,
            ),
          ),
          const Gap(20),
          _RoleBlock(
            title: l10n.verifierApplicationWhatIsTitle,
            body: l10n.verifierApplicationWhatIsBody,
          ),
          const Gap(16),
          _RoleBlock(
            title: l10n.verifierApplicationWhatDoTitle,
            body: l10n.verifierApplicationWhatDoBody,
          ),
          const Gap(16),
          _RoleBlock(
            title: l10n.verifierApplicationUnchangedTitle,
            body: l10n.verifierApplicationUnchangedBody,
          ),
          const Gap(16),
          _RoleBlock(
            title: l10n.verifierApplicationDataTitle,
            body: l10n.verifierApplicationDataBody,
          ),
          const Gap(16),
          _RoleBlock(
            title: l10n.verifierApplicationAfterTitle,
            body: l10n.verifierApplicationAfterBody,
          ),
        ],
      ),
    );
  }
}

class _RoleBlock extends StatelessWidget {
  const _RoleBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const Gap(4),
        Text(
          body,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
