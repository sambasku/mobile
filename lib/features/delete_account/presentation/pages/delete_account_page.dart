import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../providers/delete_account_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Profil → Hapus akun. Sukses mengosongkan sesi lokal karena server
/// sudah mencabut refresh token dan token perangkat.
class DeleteAccountPage extends HookConsumerWidget {
  const DeleteAccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deleteAccountProvider);
    final password = useTextEditingController();
    final confirmation = useTextEditingController();
    useListenable(password);
    useListenable(confirmation);

    ref.listen(deleteAccountProvider.select((s) => s.successMessage), (_, next) async {
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
                      AppLocalizations.of(sheetContext).deleteAccountDone,
                    ),
                    subtitle: Text(next),
                  ),
                  FTile(
                    title: const Text(''),
                    suffix: FButton(
                      onPress: () async {
                        Navigator.of(sheetContext).pop();
                        await ref.read(authStatusProvider.notifier).logout();
                        if (context.mounted) context.go('/');
                      },
                      child: Text(
                        AppLocalizations.of(sheetContext).commonClose,
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

    ref.listen(deleteAccountProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(deleteAccountProvider.notifier).clearError();
        }
      });
    });

    final canSubmit = confirmation.text == 'HAPUS' && !state.isSubmitting;

    void submit() => ref.read(deleteAccountProvider.notifier).submit(
          password: password.text,
          confirmation: confirmation.text,
        );

    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.deleteAccountTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Text(
            l10n.deleteAccountBody,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          FTextField.password(
            control: .managed(controller: password),
            enabled: !state.isSubmitting,
            label: Text(l10n.deleteAccountPasswordLabel),
            hint: l10n.deleteAccountPasswordHint,
            textInputAction: .next,
          ),
          const Gap(12),
          FTextField(
            control: .managed(controller: confirmation),
            enabled: !state.isSubmitting,
            label: Text(l10n.deleteAccountTypeToConfirm),
            textInputAction: .done,
            onSubmit: canSubmit ? (_) => submit() : null,
          ),
          const Gap(16),
          FButton(
            variant: .destructive,
            onPress: canSubmit ? submit : null,
            prefix: state.isSubmitting ? const FCircularProgress() : null,
            child: Text(
              state.isSubmitting
                  ? l10n.deleteAccountDeleting
                  : l10n.deleteAccountTitle,
            ),
          ),
        ],
      ),
    );
  }
}
