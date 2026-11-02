import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth_router.dart';
import '../../otp_code.dart';
import '../otp_code_formatter.dart';
import '../providers/auth_forgot_providers.dart';
import '../providers/auth_reset_providers.dart';
import '../../domain/failures/auth_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/info_bottom_sheet.dart';

const _resendCooldown = Duration(minutes: 2);

String _formatCooldown(int seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Atur password baru di aplikasi: kode email + password.
/// Cadangan: token dari tautan (`?token=`).
class ResetPasswordPage extends HookConsumerWidget {
  const ResetPasswordPage({
    super.key,
    this.email = '',
    this.initialToken = '',
    this.startCooldown = false,
  });

  final String email;
  final String initialToken;
  final bool startCooldown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authResetProvider);
    final forgot = ref.watch(authForgotProvider);
    final code = useState('');
    final newPassword = useTextEditingController();
    final confirmPassword = useTextEditingController();
    useListenable(newPassword);
    useListenable(confirmPassword);
    final remaining = useState(startCooldown ? _resendCooldown.inSeconds : 0);
    final hasTokenFromLink = initialToken.isNotEmpty;

    useEffect(() {
      if (remaining.value <= 0) return null;
      final timer = Timer(const Duration(seconds: 1), () {
        remaining.value = remaining.value - 1;
      });
      return timer.cancel;
    }, [remaining.value]);

    ref.listen(authForgotProvider.select((s) => s.successMessage), (_, next) {
      if (next == null || !context.mounted) return;
      remaining.value = _resendCooldown.inSeconds;
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).authResetCodeSent),
      );
    });

    ref.listen(authResetProvider.select((s) => s.successMessage), (
      _,
      next,
    ) async {
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
                    title: Text(AppLocalizations.of(context).authResetSuccess),
                    subtitle: Text(next),
                  ),
                  FTile(
                    title: const Text(''),
                    suffix: FButton(
                      onPress: () {
                        Navigator.of(sheetContext).pop();
                        context.go(AuthRouter.login.path);
                      },
                      child: Text(
                        AppLocalizations.of(sheetContext).authLoginAction,
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

    ref.listen(authResetProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(authResetProvider.notifier).clearError();
        }
      });
    });

    ref.listen(authForgotProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      // Akun OAuth: info, bukan error (lihat forgot_password_page).
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

    final digits = code.value;
    final newPasswordValid =
        newPassword.text.length >= 8 &&
        newPassword.text.contains(RegExp(r'[a-zA-Z]')) &&
        newPassword.text.contains(RegExp(r'[0-9]'));
    final canSubmit =
        newPasswordValid &&
        confirmPassword.text == newPassword.text &&
        !state.isSubmitting &&
        (hasTokenFromLink ||
            (email.contains('@') && digits.length == otpCodeLength));
    final canResend =
        !hasTokenFromLink &&
        remaining.value == 0 &&
        !state.isSubmitting &&
        !forgot.isSubmitting &&
        email.contains('@');
    final theme = context.theme;

    void submit() => ref
        .read(authResetProvider.notifier)
        .submit(
          token: hasTokenFromLink ? initialToken : null,
          email: hasTokenFromLink ? null : email,
          code: hasTokenFromLink ? null : digits,
          newPassword: newPassword.text,
          confirmPassword: confirmPassword.text,
        );

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(AppLocalizations.of(context).authNewPasswordTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(AuthRouter.forgotPassword.path),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Text(
            hasTokenFromLink
                ? AppLocalizations.of(context).authResetLinkBody
                : email.contains('@')
                ? AppLocalizations.of(context).authResetCodeBody(email)
                : AppLocalizations.of(context).authResetAskCode,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          if (!hasTokenFromLink) ...[
            FOtpField(
              control: .managed(
                children: otpFieldChildren,
                onChange: (value) {
                  code.value = normalizeOtpInput(value.text);
                },
              ),
              style: otpFieldStyle(),
              builder: (context, style, variants, child) =>
                  Center(child: child),
              enabled: !state.isSubmitting && email.contains('@'),
              label: Center(
                child: Text(AppLocalizations.of(context).authResetCodeLabel),
              ),
              autofocus: email.contains('@'),
              keyboardType: .text,
              textCapitalization: .characters,
              textInputAction: .next,
              inputFormatters: const [OtpCodeAlphanumericFormatter()],
            ),
            const Gap(12),
          ],
          FTextField.password(
            control: .managed(controller: newPassword),
            enabled: !state.isSubmitting,
            label: Text(AppLocalizations.of(context).authNewPasswordTitle),
            hint: AppLocalizations.of(context).authPasswordHint,
            textInputAction: .next,
          ),
          const Gap(12),
          FTextField.password(
            control: .managed(controller: confirmPassword),
            enabled: !state.isSubmitting,
            label: Text(AppLocalizations.of(context).authConfirmNewPassword),
            textInputAction: .done,
            onSubmit: canSubmit ? (_) => submit() : null,
          ),
          const Gap(16),
          FButton(
            onPress: canSubmit ? submit : null,
            prefix: state.isSubmitting ? const FCircularProgress() : null,
            child: Text(
              state.isSubmitting
                  ? AppLocalizations.of(context).authSubmitting
                  : AppLocalizations.of(context).authSavePassword,
            ),
          ),
          if (!hasTokenFromLink) ...[
            const Gap(8),
            FButton(
              variant: .ghost,
              onPress: canResend
                  ? () => ref
                        .read(authForgotProvider.notifier)
                        .submit(email: email)
                  : null,
              prefix: forgot.isSubmitting ? const FCircularProgress() : null,
              child: Text(
                forgot.isSubmitting
                    ? AppLocalizations.of(context).authSending
                    : remaining.value > 0
                    ? AppLocalizations.of(context).authResendCodeCountdown(
                        _formatCooldown(remaining.value),
                      )
                    : AppLocalizations.of(context).authResendCode,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
