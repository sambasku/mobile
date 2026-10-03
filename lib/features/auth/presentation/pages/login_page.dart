import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/widgets/brand_logo.dart';
import '../../../about/about_router.dart';
import '../../../report_bug/report_bug_router.dart';
import '../../auth_router.dart';
import '../../domain/failures/auth_failure.dart';
import '../providers/auth_login_providers.dart';
import '../providers/auth_status_providers.dart';
import '../models/auth_pending_action.dart';
import '../widgets/facebook_auth_button.dart';
import '../widgets/github_auth_button.dart';
import '../widgets/google_auth_button.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';

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

    final busy = state.isSubmitting;
    final emailLoading = state.pendingAction == AuthPendingAction.email;
    final googleLoading = state.pendingAction == AuthPendingAction.google;
    final facebookLoading = state.pendingAction == AuthPendingAction.facebook;
    final githubLoading = state.pendingAction == AuthPendingAction.github;

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
          title: Text(
            ref.read(authLoginProvider).errorMessage ?? 'Coba lagi nanti',
          ),
        );
        ref.read(authLoginProvider.notifier).clearError();
        return;
      }
      if (code == AuthFailure.googleSignInCanceled ||
          code == AuthFailure.facebookSignInCanceled ||
          code == AuthFailure.githubSignInCanceled) {
        showFToast(context: context, title: const Text('Masuk dibatalkan'));
        ref.read(authLoginProvider.notifier).acknowledgeSocialCancel();
      }
    });

    ref.listen(authLoginProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      final code = ref.read(authLoginProvider).errorCode;
      if (code == 'RATE_LIMITED' ||
          code == AuthFailure.googleSignInCanceled ||
          code == AuthFailure.facebookSignInCanceled ||
          code == AuthFailure.githubSignInCanceled) {
        return;
      }
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(authLoginProvider.notifier).clearError();
        }
      });
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
        !busy;

    void submit() => ref
        .read(authLoginProvider.notifier)
        .submit(email: email.text, password: password.text);

    return FScaffold(
      childPad: true,
      header: FHeader(
        title: const SizedBox.shrink(),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.info),
            onPress: busy
                ? null
                : () => context.push(AboutRouter.about.path),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
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
                    'Masuk dengan akunmu agar peran Verifikator aktif.',
                  ),
                ),
                const Gap(16),
              ],
              FTextField.email(
                control: .managed(controller: email),
                enabled: !busy,
                label: const Text('Email'),
              ),
              const Gap(12),
              FTextField.password(
                control: .managed(controller: password),
                enabled: !busy,
                label: const Text('Password'),
                textInputAction: .done,
                onSubmit: canSubmit ? (_) => submit() : null,
              ),
              const Gap(4),
              Align(
                alignment: Alignment.centerRight,
                child: FButton(
                  variant: .ghost,
                  onPress: busy
                      ? null
                      : () => context.go(AuthRouter.forgotPassword.path),
                  child: const Text('Lupa password?'),
                ),
              ),
              const Gap(16),
              FButton(
                onPress: canSubmit ? submit : null,
                prefix: emailLoading ? const FCircularProgress() : null,
                child: Text(emailLoading ? 'Memproses...' : 'Masuk'),
              ),
              if ((ref.watch(googleAuthEnabledProvider) &&
                      !state.googleUnavailable) ||
                  (ref.watch(githubAuthEnabledProvider) &&
                      !state.githubUnavailable) ||
                  (ref.watch(facebookAuthEnabledProvider) &&
                      !state.facebookUnavailable)) ...[
                const Gap(16),
                const GoogleAuthDivider(),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (ref.watch(googleAuthEnabledProvider) &&
                        !state.googleUnavailable)
                      GoogleAuthButton(
                        isLoading: googleLoading,
                        onPress: busy
                            ? null
                            : () => ref
                                  .read(authLoginProvider.notifier)
                                  .submitGoogle(),
                      ),
                    if (ref.watch(googleAuthEnabledProvider) &&
                        !state.googleUnavailable &&
                        ref.watch(githubAuthEnabledProvider) &&
                        !state.githubUnavailable)
                      const Gap(12),
                    if (ref.watch(githubAuthEnabledProvider) &&
                        !state.githubUnavailable)
                      GithubAuthButton(
                        isLoading: githubLoading,
                        onPress: busy
                            ? null
                            : () => ref
                                  .read(authLoginProvider.notifier)
                                  .submitGithub(),
                      ),
                  ],
                ),
                if (ref.watch(facebookAuthEnabledProvider) &&
                    !state.facebookUnavailable) ...[
                  const Gap(16),
                  FacebookAuthButton(
                    label: 'Masuk dengan Facebook',
                    isLoading: facebookLoading,
                    onPress: busy
                        ? null
                        : () => ref
                              .read(authLoginProvider.notifier)
                              .submitFacebook(),
                  ),
                ],
              ],
              const Gap(16),
              Center(
                child: Column(
                  spacing: 3,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: busy
                          ? null
                          : () => context.go('/register'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text.rich(
                          TextSpan(
                            style: context.theme.typography.sm.copyWith(
                              color: context.theme.colors.foreground,
                            ),
                            children: const [
                              TextSpan(text: 'Belum punya akun? '),
                              TextSpan(
                                text: 'Daftar',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: busy ? null : () => context.go('/'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Lanjut tanpa akun (Anonim)',
                          style: context.theme.typography.xs.copyWith(
                            color: context.theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: busy
                          ? null
                          : () => context.push(ReportBugRouter.reportBug.path),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Laporkan masalah',
                          style: context.theme.typography.xs.copyWith(
                            color: context.theme.colors.destructive,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                  'Cek email kamu untuk kode OTP 6 karakter 0-9A-Z, verifikasi dulu sebelum masuk.',
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
