import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../providers/delete_account_providers.dart';

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

    ref.listen(deleteAccountProvider.select((s) => s.successMessage), (_, next) {
      if (next == null) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Akun dihapus'),
          content: Text(next),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(authStatusProvider.notifier).logout();
                if (context.mounted) context.go('/');
              },
              child: const Text('Tutup'),
            ),
          ],
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

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Hapus akun'),
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
            'Nama, email, nomor HP, kata sandi, foto profil, sesi, dan token '
            'notifikasi akan dihapus. Entri kamus yang sudah tayang tetap ada '
            'tanpa namamu.',
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          FTextField.password(
            control: .managed(controller: password),
            enabled: !state.isSubmitting,
            label: const Text('Kata sandi'),
            hint: 'Kosongkan jika akun masuk lewat Google',
            textInputAction: .next,
          ),
          const Gap(12),
          FTextField(
            control: .managed(controller: confirmation),
            enabled: !state.isSubmitting,
            label: const Text('Ketik HAPUS'),
            textInputAction: .done,
            onSubmit: canSubmit ? (_) => submit() : null,
          ),
          const Gap(16),
          FButton(
            variant: .destructive,
            onPress: canSubmit ? submit : null,
            prefix: state.isSubmitting ? const FCircularProgress() : null,
            child: Text(state.isSubmitting ? 'Menghapus...' : 'Hapus akun'),
          ),
        ],
      ),
    );
  }
}
