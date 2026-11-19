import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';

/// Stub Phase 3: route ada supaya tile Kontribusi bisa push.
/// Feed + riwayat penuh di Phase 4.
class PeriksaKataPage extends StatelessWidget {
  const PeriksaKataPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.feedContributePeriksaKata),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.feedPeriksaKataStubBody,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
