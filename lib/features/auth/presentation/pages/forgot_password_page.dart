import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_forgot_providers.dart';
import '../../domain/failures/auth_failure.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/info_bottom_sheet.dart';

/// Minta kode reset 6 karakter 0-9A-Z. Response API selalu sama (anti-enumeration).
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

    ref.listen(authForgotProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      // Akun OAuth: info, bukan error - reset password memang tidak
      // bisa diproses, user perlu tahu harus lewat provider.
      final code = ref.read(authForgotProvider).errorCode;
      if (code == AuthFailure.oauthAccount) {
        showAppInfoSheet(
          context,
          message: next,
          title: AppLocalizations.of(context).authOauthAccountTitle,
        ).whenComplete(() {
          if (context.mounted) {
            ref.read(authForgotProvider.notifier).clearError();
          }
        });
        return;
      }
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(authForgotProvider.notifier).clearError();
        }
      });
    });

    final canSubmit = email.text.contains('@') && !state.isSubmitting;
    final theme = context.theme;

    void submit() =>
        ref.read(authForgotProvider.notifier).submit(email: email.text);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(AppLocalizations.of(context).authForgotTitle),
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
                AppLocalizations.of(context).authResetTitle,
                textAlign: .center,
                style: theme.typography.body.xl.copyWith(
                  fontWeight: .w600,
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(8),
              Text(
                AppLocalizations.of(context).authForgotBody,
                textAlign: .center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(24),
              FTextField.email(
                control: .managed(controller: email),
                enabled: !state.isSubmitting,
                label: Text(AppLocalizations.of(context).authEmailLabel),
                textInputAction: .done,
                onSubmit: canSubmit ? (_) => submit() : null,
              ),
              const Gap(16),
              FButton(
                onPress: canSubmit ? submit : null,
                prefix: state.isSubmitting ? const FCircularProgress() : null,
                child: Text(
                  state.isSubmitting
                      ? AppLocalizations.of(context).authSending
                      : AppLocalizations.of(context).authSendCode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
