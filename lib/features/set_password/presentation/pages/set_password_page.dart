import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../linked_accounts/presentation/providers/linked_accounts_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../providers/set_password_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Buat password pertama untuk akun OAuth. Dua kolom, bukti provider
/// ulang, lalu logout karena semua refresh token dicabut.
class SetPasswordPage extends HookConsumerWidget {
  const SetPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setPasswordProvider);
    final links = ref.watch(linkedAccountsProvider);
    final username = ref.watch(authStatusProvider).value?.username;
    final newPassword = useTextEditingController();
    final confirmPassword = useTextEditingController();
    final selected = useState<String?>(null);
    useListenable(newPassword);
    useListenable(confirmPassword);

    final providers = <String>[
      if (links.googleLinked) 'google',
      if (links.githubLinked) 'github',
    ];

    useEffect(() {
      if (providers.length == 1 && selected.value != providers.first) {
        selected.value = providers.first;
      }
      return null;
    }, [providers.join(',')]);

    ref.listen(setPasswordProvider.select((s) => s.successMessage), (
      _,
      next,
    ) async {
      if (next == null || !context.mounted) return;
      final loginWith =
          ref.read(setPasswordProvider).loginWith ?? username ?? '';
      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        barrierColor: Colors.black54,
        builder: (sheetContext) => Padding(
          padding: MediaQuery.of(sheetContext).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FTileGroup(
                children: [
                  FTile(
                    title: Text(
                      AppLocalizations.of(sheetContext).passwordCreated,
                    ),
                    subtitle: Text(
                      loginWith.isEmpty
                          ? next
                          : AppLocalizations.of(
                              sheetContext,
                            ).passwordCreatedBody(loginWith),
                    ),
                  ),
                  FTile(
                    title: const Text(''),
                    suffix: FButton(
                      onPress: () async {
                        Navigator.of(sheetContext).pop();
                        await ref.read(authStatusProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      },
                      child: Text(
                        AppLocalizations.of(sheetContext).passwordRelogin,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });

    ref.listen(setPasswordProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(setPasswordProvider.notifier).clearError();
        }
      });
    });

    final newPasswordValid =
        newPassword.text.length >= 8 &&
        newPassword.text.contains(RegExp(r'[a-zA-Z]')) &&
        newPassword.text.contains(RegExp(r'[0-9]'));
    final canSubmit =
        !state.isSubmitting &&
        selected.value != null &&
        newPasswordValid &&
        confirmPassword.text == newPassword.text;

    void submit() => ref
        .read(setPasswordProvider.notifier)
        .submit(
          provider: selected.value!,
          newPassword: newPassword.text,
          confirmPassword: confirmPassword.text,
        );

    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.passwordCreateTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: links.isLoading
          ? const Center(child: FCircularProgress())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (username != null && username.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.passwordCreateHint(username),
                    ),
                  ),
                if (providers.length > 1) ...[
                  FTileGroup(
                    label: Text(l10n.passwordVerifyAccount),
                    children: [
                      for (final provider in providers)
                        FTile(
                          title: Text(_providerLabel(l10n, provider)),
                          suffix: selected.value == provider
                              ? const Icon(FLucideIcons.check, size: 18)
                              : null,
                          onPress: () => selected.value = provider,
                        ),
                    ],
                  ),
                  const Gap(12),
                ],
                FTextField.password(
                  control: .managed(controller: newPassword),
                  enabled: !state.isSubmitting,
                  label: Text(l10n.passwordNewLabel),
                  hint: l10n.authPasswordHint,
                  textInputAction: .next,
                ),
                const Gap(12),
                FTextField.password(
                  control: .managed(controller: confirmPassword),
                  enabled: !state.isSubmitting,
                  label: Text(l10n.passwordConfirmNewLabel),
                  textInputAction: .done,
                  onSubmit: canSubmit ? (_) => submit() : null,
                ),
                const Gap(16),
                FButton(
                  onPress: canSubmit ? submit : null,
                  prefix: state.isSubmitting ? const FCircularProgress() : null,
                  child: Text(
                    state.isSubmitting ? l10n.authSubmitting : l10n.passwordSave,
                  ),
                ),
              ],
            ),
    );
  }
}

String _providerLabel(AppLocalizations l10n, String provider) {
  return switch (provider) {
    'google' => l10n.providerGoogle,
    'facebook' => l10n.providerFacebook,
    'github' => l10n.providerGithub,
    _ => provider,
  };
}
