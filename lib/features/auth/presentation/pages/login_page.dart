import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../auth_router.dart';
import '../../domain/failures/auth_failure.dart';
import '../providers/auth_login_providers.dart';
import '../providers/auth_status_providers.dart';
import '../widgets/facebook_auth_button.dart';
import '../widgets/google_auth_button.dart';

/// Halaman login (email + password). Google/Facebook: tombol di bawah Masuk.
class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authLoginProvider);
    final authStatus = ref.watch(authStatusProvider);
    final status = authStatus.value;
    // Jangan anggap "sudah login" saat logout masih berjalan - kalau tidak,
    // layar cuma spinner lalu redirect HOME tanpa form masuk.
    final alreadyAuth =
        (status?.isAuth ?? false) && !(status?.isLoggingOut ?? false);
    final fromVerifierRelogin =
        GoRouterState.of(context).uri.queryParameters['relogin'] == '1';
    final email = useTextEditingController();
    final password = useTextEditingController();
    final logoLoaded = useState(false);
    useListenable(email);
    useListenable(password);

    // Sudah login → jangan tampilkan form; redirect (router juga jaga)
    ref.listen(authStatusProvider, (_, next) {
      final nextStatus = next.value;
      if (nextStatus == null) return;
      if (nextStatus.isLoggingOut) return;
      if (nextStatus.isAuth && context.mounted) context.go('/');
    });

    // pindah ke HOME begitu sesi tersimpan
    ref.listen(authLoginProvider.select((s) => s.session), (_, next) {
      if (next != null) context.go('/');
    });

    ref.listen(authLoginProvider.select((s) => s.errorCode), (_, code) {
      if (!context.mounted || code == null) return;
      if (code == 'RATE_LIMITED') {
        showFToast(
          context: context,
          title: Text(state.errorMessage ?? 'Coba lagi nanti'),
        );
        return;
      }
      if (code == AuthFailure.googleSignInCanceled ||
          code == AuthFailure.facebookSignInCanceled) {
        showFToast(
          context: context,
          title: const Text('Masuk dibatalkan'),
        );
        ref.read(authLoginProvider.notifier).acknowledgeSocialCancel();
      }
    });

    ref.listen(authLoginProvider.select((s) => s.showUnverifiedSheet), (
      _,
      showSheet,
    ) {
      if (showSheet != true || !context.mounted) return;
      ref.read(authLoginProvider.notifier).acknowledgeUnverifiedSheet();
      _showEmailNotVerifiedSheet(context, email.text.trim());
    });

    if (alreadyAuth) {
      return const FScaffold(
        childPad: true,
        child: Center(child: FCircularProgress()),
      );
    }

    final canSubmit =
        email.text.contains('@') &&
        password.text.length >= 8 &&
        !state.isSubmitting;

    void submit() => ref
        .read(authLoginProvider.notifier)
        .submit(email: email.text, password: password.text);

    return FScaffold(
      childPad: true,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisAlignment: .center,
              crossAxisAlignment: .stretch,
              children: [
                Skeletonizer(
                  enabled: !logoLoaded.value,
                  child: Center(
                    child: BrandMark(
                      size: 148,
                      frameBuilder:
                          (context, child, frame, wasSynchronouslyLoaded) {
                            if ((wasSynchronouslyLoaded || frame != null) &&
                                !logoLoaded.value) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (context.mounted) logoLoaded.value = true;
                              });
                            }
                            return child;
                          },
                    ),
                  ),
                ),
                const Gap(24),
                if (fromVerifierRelogin) ...[
                  const FAlert(
                    title: Text('Masuk kembali'),
                    subtitle: Text(
                      'Masuk dengan akun Anda agar peran Verifikator aktif.',
                    ),
                  ),
                  const Gap(16),
                ],
                FTextField.email(
                  control: .managed(controller: email),
                  enabled: !state.isSubmitting,
                  label: const Text('Email'),
                ),
                const Gap(12),
                FTextField.password(
                  control: .managed(controller: password),
                  enabled: !state.isSubmitting,
                  label: const Text('Password'),
                  textInputAction: .done,
                  onSubmit: canSubmit ? (_) => submit() : null,
                ),
                const Gap(4),
                Align(
                  alignment: Alignment.centerRight,
                  child: FButton(
                    variant: .ghost,
                    onPress: state.isSubmitting
                        ? null
                        : () => context.go(AuthRouter.forgotPassword.path),
                    child: const Text('Lupa password?'),
                  ),
                ),
                if (state.errorMessage != null &&
                    state.errorCode != 'RATE_LIMITED' &&
                    state.errorCode != AuthFailure.googleSignInCanceled &&
                    state.errorCode != AuthFailure.facebookSignInCanceled) ...[
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
                  child: Text(state.isSubmitting ? 'Memproses...' : 'Masuk'),
                ),
                if ((ref.watch(googleAuthEnabledProvider) &&
                        !state.googleUnavailable) ||
                    (ref.watch(facebookAuthEnabledProvider) &&
                        !state.facebookUnavailable)) ...[
                  const Gap(16),
                  const GoogleAuthDivider(),
                  if (ref.watch(googleAuthEnabledProvider) &&
                      !state.googleUnavailable) ...[
                    const Gap(16),
                    GoogleAuthButton(
                      label: 'Masuk dengan Google',
                      isLoading: state.isSubmitting,
                      onPress: state.isSubmitting
                          ? null
                          : () => ref
                                .read(authLoginProvider.notifier)
                                .submitGoogle(),
                    ),
                  ],
                  if (ref.watch(facebookAuthEnabledProvider) &&
                      !state.facebookUnavailable) ...[
                    const Gap(16),
                    FacebookAuthButton(
                      label: 'Masuk dengan Facebook',
                      isLoading: state.isSubmitting,
                      onPress: state.isSubmitting
                          ? null
                          : () => ref
                                .read(authLoginProvider.notifier)
                                .submitFacebook(),
                    ),
                  ],
                ],
                const Gap(8),
                FButton(
                  variant: .ghost,
                  onPress: state.isSubmitting
                      ? null
                      : () => context.go('/register'),
                  child: const Text('Belum punya akun? Daftar'),
                ),
                const Gap(4),
                FButton(
                  variant: .ghost,
                  onPress: state.isSubmitting
                      ? null
                      : () => context.go('/'), // lanjut sebagai tamu
                  child: const Text('Lanjut tanpa login (tamu)'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showEmailNotVerifiedSheet(BuildContext context, String email) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      return Material(
        color: Theme.of(sheetContext).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Email belum diverifikasi',
                  style: theme.typography.lg.copyWith(fontWeight: .w600),
                ),
                const Gap(8),
                Text(
                  'Cek kotak masuk untuk kode OTP 8 karakter 0-9A-Z, lalu verifikasi sebelum masuk.',
                  style: theme.typography.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                const Gap(16),
                FButton(
                  onPress: () {
                    Navigator.of(sheetContext).pop();
                    context.go(
                      '${AuthRouter.verifyEmail.path}?email=${Uri.encodeComponent(email)}',
                    );
                  },
                  child: const Text('Verifikasi sekarang'),
                ),
                const Gap(8),
                FButton(
                  variant: .ghost,
                  onPress: () => Navigator.of(sheetContext).pop(),
                  child: const Text('Nanti saja'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
