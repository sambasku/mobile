import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/locale_controller.dart';
import '../../../../core/widgets/brand_logo.dart';
import '../../../../l10n/app_localizations.dart';
import '../../onboarding_router.dart';

/// Slide 0 onboarding: user wajib memilih bahasa antarmuka sebelum masuk
/// pengalaman kamus (kontrak MOBILE-I18N Section 7). Tap item = pilih +
/// lanjut; tidak ada auto-set dari locale OS.
class OnboardingLanguagePage extends ConsumerWidget {
  const OnboardingLanguagePage({
    super.key,
    this.onDone = OnboardingRouter.goOnboarding,
  });

  final void Function(BuildContext context) onDone;

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    AppLocale locale,
  ) async {
    await ref
        .read(localeControllerProvider.notifier)
        .set(locale, source: 'first_launch');
    if (context.mounted) onDone(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final current = ref.watch(localeControllerProvider);

    return FScaffold(
      childPad: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(40),
              const Center(child: BrandMark(size: 140)),
              const Gap(24),
              Text(
                l10n.onboardingLanguageTitle,
                style: theme.typography.body.xl.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const Gap(14),
              Text(
                l10n.onboardingLanguageBody,
                style: theme.typography.body.md.copyWith(
                  color: theme.colors.mutedForeground,
                  height: 1.45,
                ),
              ),
              const Gap(24),
              for (final locale in AppLocale.all) ...[
                FButton(
                  variant: locale == current
                      ? FButtonVariant.primary
                      : FButtonVariant.outline,
                  onPress: () => _choose(context, ref, locale),
                  child: Text(locale.label),
                ),
                const Gap(10),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
