import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../auth_router.dart';
import '../../otp_code.dart';
import '../otp_code_formatter.dart';
import '../providers/auth_verify_providers.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';

const _resendCooldown = Duration(minutes: 2);

String _formatCooldown(int seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

class VerifyEmailPage extends HookConsumerWidget {
  const VerifyEmailPage({
    super.key,
    required this.email,
    this.startCooldown = false,
  });

  final String email;
  final bool startCooldown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authVerifyProvider);
    final code = useState('');
    final remaining = useState(startCooldown ? _resendCooldown.inSeconds : 0);

    // Provider autoDispose + ValueKey(email) di router sudah state baru per email.
    // Jangan invalidate di sini: useEffect flutter_hooks jalan sinkron saat build.
    useEffect(() {
      if (remaining.value <= 0) return null;
      final timer = Timer(const Duration(seconds: 1), () {
        remaining.value = remaining.value - 1;
      });
      return timer.cancel;
    }, [remaining.value]);

    // Jangan tendang ke home hanya karena sesi user lama masih isAuth.
    // Hanya OTP email ini yang sukses yang boleh masuk.
    ref.listen(authVerifyProvider.select((s) => s.session), (_, next) {
      if (next != null) context.go('/');
    });

    ref.listen(authVerifyProvider.select((s) => s.resendMessage), (_, next) {
      if (next == null || !context.mounted) return;
      remaining.value = _resendCooldown.inSeconds;
      showFToast(context: context, title: Text(next));
    });

    ref.listen(authVerifyProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      final code = ref.read(authVerifyProvider).errorCode;
      if (code == 'RATE_LIMITED') {
        remaining.value = _resendCooldown.inSeconds;
        showFToast(context: context, title: Text(next));
        ref.read(authVerifyProvider.notifier).clearError();
        return;
      }
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(authVerifyProvider.notifier).clearError();
        }
      });
    });

    final digits = code.value;
    final canSubmit =
        email.contains('@') &&
        digits.length == otpCodeLength &&
        !state.isSubmitting;
    final canResend =
        remaining.value == 0 &&
        !state.isSubmitting &&
        !state.isResending &&
        email.isNotEmpty;
    final theme = context.theme;

    void submit() => ref
        .read(authVerifyProvider.notifier)
        .submit(email: email, code: digits);

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Verifikasi email'),
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
                'Masukkan kode 6 karakter',
                textAlign: .center,
                style: theme.typography.xl.copyWith(
                  fontWeight: .w600,
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(8),
              Text(
                email.isEmpty
                    ? 'Email tidak ada. Kembali ke daftar atau masuk.'
                    : 'Kode dikirim ke $email (berlaku 10 menit).',
                textAlign: .center,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(24),
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
                enabled: !state.isSubmitting && email.isNotEmpty,
                label: const Center(child: Text('Kode OTP')),
                autofocus: email.isNotEmpty,
                keyboardType: .text,
                textCapitalization: .characters,
                textInputAction: .done,
                inputFormatters: const [OtpCodeAlphanumericFormatter()],
                onSubmit: canSubmit ? (_) => submit() : null,
              ),
              const Gap(16),
              FButton(
                onPress: canSubmit ? submit : null,
                prefix: state.isSubmitting ? const FCircularProgress() : null,
                child: Text(
                  state.isSubmitting ? 'Memproses...' : 'Verifikasi',
                ),
              ),
              const Gap(8),
              FButton(
                variant: .ghost,
                onPress: canResend
                    ? () => ref
                          .read(authVerifyProvider.notifier)
                          .resend(email: email)
                    : null,
                prefix: state.isResending ? const FCircularProgress() : null,
                child: Text(
                  state.isResending
                      ? 'Mengirim...'
                      : remaining.value > 0
                      ? 'Kirim ulang kode (${_formatCooldown(remaining.value)})'
                      : 'Kirim ulang kode',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
