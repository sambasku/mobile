import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/feature_flags.dart';
import '../../../../core/i18n/locale_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../about/about_router.dart';
import '../../../profile/presentation/widgets/appearance_tiles.dart';
import '../../../report_bug/report_bug_router.dart';
import '../../settings_router.dart';
import 'notification_prefs_section.dart';

/// Pengaturan aplikasi: preferensi non-identitas (bahasa, tampilan,
/// dukungan, tentang). Guest dan user login sama-sama boleh masuk
/// (kontrak MOBILE-I18N Section 8.2).
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeControllerProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.settingsTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
        children: [
          if (FeatureFlags.multiLanguageEnabled) ...[
            FTileGroup(
              label: Text(l10n.settingsGroupLanguage),
              children: [
                FTile(
                  prefix: const Icon(FLucideIcons.languages, size: 18),
                  title: Text(l10n.settingsLanguageTile),
                  subtitle: Text(locale.label),
                  suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                  onPress: () => context.push(SettingsRouter.language.path),
                ),
              ],
            ),
            const Gap(8),
          ],
          FTileGroup(
            label: Text(l10n.settingsGroupAppearance),
            children: [
              themeModeTile(ref),
              paletteTile(ref),
              fontScaleTile(ref),
            ],
          ),
          const Gap(8),
          const NotificationPrefsSection(),
          FTileGroup(
            label: Text(l10n.settingsGroupSupport),
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.flag, size: 18),
                title: Text(l10n.settingsReportBug),
                suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                onPress: () => context.push(ReportBugRouter.reportBug.path),
              ),
            ],
          ),
          const Gap(8),
          FTileGroup(
            label: Text(l10n.settingsGroupAbout),
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.info, size: 18),
                title: Text(l10n.settingsAboutApp),
                suffix: const Icon(FLucideIcons.chevronRight, size: 16),
                onPress: () => context.push(AboutRouter.about.path),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
