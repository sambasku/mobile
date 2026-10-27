import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/locale_controller.dart';
import '../../../../l10n/app_localizations.dart';

/// Picker bahasa di Pengaturan. Daftar dari registry [AppLocale], bukan
/// hardcode di widget (kontrak MOBILE-I18N Section 8.3).
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final current = ref.watch(localeControllerProvider);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.languagePickerTitle),
        prefixes: [FHeaderAction.back(onPress: context.pop)],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
        children: [
          FTileGroup(
            children: [
              for (final locale in AppLocale.all)
                FTile(
                  title: Text(locale.label),
                  suffix: locale == current
                      ? const Icon(FLucideIcons.check, size: 18)
                      : null,
                  onPress: () => ref
                      .read(localeControllerProvider.notifier)
                      .set(locale),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
            child: Text(
              l10n.languagePickerNote,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
