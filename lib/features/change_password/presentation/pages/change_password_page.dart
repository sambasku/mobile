import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_status_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../providers/change_password_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Halaman ubah password (profil → menu "Ubah Password"). Sukses =
/// SEMUA session ter-revoke backend: tampilkan dialog lalu logout paksa
/// dan kembali ke /login .
class ChangePasswordPage extends HookConsumerWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(changePasswordProvider);
    final oldPassword = useTextEditingController();
    final newPassword = useTextEditingController();
    final confirmPassword = useTextEditingController();
    useListenable(oldPassword);
    useListenable(newPassword);
    useListenable(confirmPassword);

    // Sukses → bottom sheet → logout paksa → login ulang dengan password baru
    ref.listen(changePasswordProvider.select((s) => s.successMessage), (_, next) async {
      if (next == null || !context.mounted) return;
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
                      AppLocalizations.of(sheetContext).passwordChangeSuccess,
                    ),
                    subtitle: Text(next),
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

    ref.listen(changePasswordProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(changePasswordProvider.notifier).clearError();
        }
      });
    });

    final newPasswordValid = newPassword.text.length >= 8 &&
        newPassword.text.contains(RegExp(r'[a-zA-Z]')) &&
        newPassword.text.contains(RegExp(r'[0-9]'));
    final canSubmit = oldPassword.text.isNotEmpty &&
        newPasswordValid &&
        confirmPassword.text == newPassword.text &&
        newPassword.text != oldPassword.text &&
        !state.isSubmitting;

    void submit() => ref.read(changePasswordProvider.notifier).submit(
          oldPassword: oldPassword.text,
          newPassword: newPassword.text,
          confirmPassword: confirmPassword.text,
        );

    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.passwordChangeTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          FTextField.password(
            control: .managed(controller: oldPassword),
            enabled: !state.isSubmitting,
            label: Text(l10n.passwordOldLabel),
            textInputAction: .next,
          ),
          const Gap(12),
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
          const Gap(8),
          Text(
            l10n.passwordChangeNote,
            textAlign: .center,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
