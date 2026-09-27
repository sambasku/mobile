import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth_router.dart';
import '../providers/auth_forgot_providers.dart';

/// Minta kode reset 8 karakter 0-9A-Z. Response API selalu sama (anti-enumeration).
class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authForgotProvider);
    final email = useTextEditingController();
    useListenable(email);

    ref.listen(authForgotProvider.select((s) => s.successMessage), (_, next) {
      if (next == null || !context.mounted) return;
      context.go(
        '${AuthRouter.resetPassword.path}?email=${Uri.encodeComponent(email.text.trim())}&cooldown=1',
      );
    });

    final canSubmit = email.text.contains('@') && !state.isSubmitting;
    final theme = context.theme;

    void submit() =>
        ref.read(authForgotProvider.notifier).submit(email: email.text);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Lupa password'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(AuthRouter.login.path),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Text(
                'Atur ulang password',
                textAlign: .center,
                style: theme.typography.xl.copyWith(
                  fontWeight: .w600,
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(8),
              Text(
                'Masukkan email akun. Kalau terdaftar, kami kirim kode 8 karakter 0-9A-Z ke email.',
                textAlign: .center,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(24),
              FTextField.email(
                control: .managed(controller: email),
                enabled: !state.isSubmitting,
                label: const Text('Email'),
                textInputAction: .done,
                onSubmit: canSubmit ? (_) => submit() : null,
              ),
              if (state.errorMessage != null) ...[
                const Gap(12),
                FAlert(
                  variant: .destructive,
                  title: Text(state.errorMessage!),
                ),
              ],
              const Gap(16),
              FButton(
                onPress: canSubmit ? submit : null,
                prefix: state.isSubmitting ? const FCircularProgress() : null,
                child: Text(
                  state.isSubmitting ? 'Mengirim...' : 'Kirim kode reset',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
