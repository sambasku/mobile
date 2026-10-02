import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_status_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../providers/change_password_providers.dart';

/// Halaman ubah password (profil → menu "Ubah Password"). Sukses =
/// SEMUA session ter-revoke backend: tampilkan dialog lalu logout paksa
/// dan kembali ke /login (docs/api/10-api-ubah-password.md).
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

    // Sukses → dialog → logout paksa → login ulang dengan password baru
    ref.listen(changePasswordProvider.select((s) => s.successMessage), (_, next) {
      if (next == null) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Password berhasil diubah'),
          content: Text(next),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(authStatusProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              },
              child: const Text('Login ulang'),
            ),
          ],
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

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Ubah Password'),
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
            label: const Text('Password Lama'),
            textInputAction: .next,
          ),
          const Gap(12),
          FTextField.password(
            control: .managed(controller: newPassword),
            enabled: !state.isSubmitting,
            label: const Text('Password Baru'),
            hint: 'Minimal 8 karakter, huruf + angka',
            textInputAction: .next,
          ),
          const Gap(12),
          FTextField.password(
            control: .managed(controller: confirmPassword),
            enabled: !state.isSubmitting,
            label: const Text('Konfirmasi Password Baru'),
            textInputAction: .done,
            onSubmit: canSubmit ? (_) => submit() : null,
          ),
          const Gap(16),
          FButton(
            onPress: canSubmit ? submit : null,
            prefix: state.isSubmitting ? const FCircularProgress() : null,
            child: Text(state.isSubmitting ? 'Memproses...' : 'Simpan Password'),
          ),
          const Gap(8),
          Text(
            'Setelah password diganti, semua sesi (termasuk yang ini) diakhiri '
            'dan kamu diminta login ulang dengan password baru.',
            textAlign: .center,
            style: context.theme.typography.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
