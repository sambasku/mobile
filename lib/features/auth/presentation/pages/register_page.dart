import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../shared/utils/phone_country.dart';
import '../../../../shared/utils/phone_country_picker_sheet.dart';
import '../../../../shared/utils/phone_national_digits_formatter.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/phone_country_flag.dart';
import '../../auth_router.dart';
import '../../domain/failures/auth_failure.dart';
import '../providers/auth_login_providers.dart';
import '../providers/auth_register_providers.dart';
import '../providers/auth_status_providers.dart';
import '../models/auth_pending_action.dart';
import '../widgets/facebook_auth_button.dart';
import '../widgets/github_auth_button.dart';
import '../widgets/google_auth_button.dart';

/// Register: nama, email, HP opsional (country picker), password + consent legal.
/// Sukses → halaman OTP. Belum auto-login.
class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authRegisterProvider);
    final name = useTextEditingController();
    final email = useTextEditingController();
    final phone = useTextEditingController();
    final password = useTextEditingController();
    final confirmPassword = useTextEditingController();
    final phoneCountry = useState(kPhoneCountryId);
    final acceptedLegal = useState(false);
    final termsVersion = useState<String?>(null);
    final privacyVersion = useState<String?>(null);
    final legalLoadError = useState<String?>(null);
    useListenable(name);
    useListenable(email);
    useListenable(phone);
    useListenable(password);
    useListenable(confirmPassword);

    final busy = state.isSubmitting;
    final emailLoading = state.pendingAction == AuthPendingAction.email;
    final googleLoading = state.pendingAction == AuthPendingAction.google;
    final facebookLoading = state.pendingAction == AuthPendingAction.facebook;
    final githubLoading = state.pendingAction == AuthPendingAction.github;

    useEffect(() {
      var cancelled = false;
      () async {
        try {
          final dio = ref.read(dioProvider);
          final res = await dio.get<Map<String, dynamic>>(
            '/api/v1/legal/current',
          );
          final data = res.data?['data'] as Map<String, dynamic>?;
          if (cancelled || data == null) return;
          final terms = data['terms'] as Map<String, dynamic>?;
          final privacy = data['privacy'] as Map<String, dynamic>?;
          termsVersion.value = terms?['version'] as String?;
          privacyVersion.value = privacy?['version'] as String?;
          legalLoadError.value = null;
        } on DioException catch (e) {
          if (!cancelled) {
            legalLoadError.value = e.message ?? 'Gagal memuat dokumen legal';
          }
        } catch (_) {
          if (!cancelled) {
            legalLoadError.value = 'Gagal memuat dokumen legal';
          }
        }
      }();
      return () => cancelled = true;
    }, const []);

    ref.listen(authRegisterProvider.select((s) => s.session), (_, next) {
      if (next != null && context.mounted) context.go('/');
    });

    ref.listen(authRegisterProvider.select((s) => s.errorCode), (_, code) {
      if (!context.mounted || code == null) return;
      if (code == 'RATE_LIMITED') {
        showFToast(
          context: context,
          title: Text(
            ref.read(authRegisterProvider).errorMessage ?? 'Coba lagi nanti',
          ),
        );
        ref.read(authRegisterProvider.notifier).clearError();
        return;
      }
      if (code == AuthFailure.googleSignInCanceled ||
          code == AuthFailure.facebookSignInCanceled ||
          code == AuthFailure.githubSignInCanceled) {
        showFToast(context: context, title: const Text('Daftar dibatalkan'));
        ref.read(authRegisterProvider.notifier).acknowledgeSocialCancel();
      }
    });

    ref.listen(authRegisterProvider.select((s) => s.errorMessage), (_, next) {
      if (next == null || !context.mounted) return;
      final code = ref.read(authRegisterProvider).errorCode;
      if (code == 'RATE_LIMITED' ||
          code == AuthFailure.googleSignInCanceled ||
          code == AuthFailure.facebookSignInCanceled ||
          code == AuthFailure.githubSignInCanceled) {
        return;
      }
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(authRegisterProvider.notifier).clearError();
        }
      });
    });

    ref.listen(authRegisterProvider.select((s) => s.success), (_, success) {
      if (success != true || !context.mounted) return;
      final pending =
          ref.read(authRegisterProvider).pendingEmail ?? email.text.trim();
      unawaited(() async {
        if (ref.read(authStatusProvider).value?.isAuth == true) {
          await ref.read(authStatusProvider.notifier).logout();
        }
        if (!context.mounted) return;
        ref.read(authRegisterProvider.notifier).acknowledgeSuccess();
        context.go(
          '${AuthRouter.verifyEmail.path}?email=${Uri.encodeComponent(pending)}&cooldown=1',
        );
      }());
    });

    final passwordOk =
        password.text.length >= 8 &&
        password.text.contains(RegExp(r'[a-zA-Z]')) &&
        password.text.contains(RegExp(r'[0-9]'));
    final legalReady =
        termsVersion.value != null && privacyVersion.value != null;
    final canSubmit =
        name.text.trim().isNotEmpty &&
        email.text.contains('@') &&
        passwordOk &&
        confirmPassword.text == password.text &&
        acceptedLegal.value &&
        legalReady &&
        !busy;

    void submit() {
      final terms = termsVersion.value;
      final privacy = privacyVersion.value;
      if (terms == null || privacy == null) return;
      ref
          .read(authRegisterProvider.notifier)
          .submit(
            name: name.text,
            email: email.text,
            phoneNationalDigits: () {
              final national = phone.text.trim();
              if (national.isEmpty) return null;
              return toInternationalPhoneDigits(phoneCountry.value, national);
            }(),
            password: password.text,
            confirmPassword: confirmPassword.text,
            consents: [
              (documentType: 'terms', documentVersion: terms),
              (documentType: 'privacy', documentVersion: privacy),
            ],
          );
    }

    final theme = context.theme;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Daftar'),
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
                'Buat akun Kontributor',
                textAlign: .center,
                style: theme.typography.xl.copyWith(
                  fontWeight: .w600,
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(8),
              Text(
                'Kami kirim kode 6 karakter 0-9A-Z ke email. Verifikasi dulu sebelum masuk.',
                textAlign: .center,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(24),
              FTextField(
                control: .managed(controller: name),
                enabled: !state.isSubmitting,
                label: const Text('Nama'),
                textInputAction: .next,
              ),
              const Gap(12),
              FTextField.email(
                control: .managed(controller: email),
                enabled: !state.isSubmitting,
                label: const Text('Email'),
              ),
              const Gap(12),
              FTextField(
                control: .managed(controller: phone),
                enabled: !state.isSubmitting,
                label: const Text('No. HP (opsional)'),
                hint: '81234567890',
                keyboardType: .phone,
                textInputAction: .next,
                inputFormatters: const [PhoneNationalDigitsFormatter()],
                prefixBuilder: (context, style, variants) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: state.isSubmitting
                      ? null
                      : () async {
                          final picked = await showPhoneCountryPickerSheet(
                            context,
                            selected: phoneCountry.value,
                          );
                          if (picked != null) {
                            phoneCountry.value = picked;
                          }
                        },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PhoneCountryFlag.fromCountry(
                          phoneCountry.value,
                          size: 18,
                        ),
                        const Gap(6),
                        Text(
                          phoneCountry.value.prefixLabel,
                          style: theme.typography.sm.copyWith(
                            color: theme.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          FLucideIcons.chevronDown,
                          size: 14,
                          color: theme.colors.mutedForeground,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(12),
              FTextField.password(
                control: .managed(controller: password),
                enabled: !state.isSubmitting,
                label: const Text('Password'),
                hint: 'Minimal 8 karakter, huruf + angka',
                textInputAction: .next,
              ),
              const Gap(12),
              FTextField.password(
                control: .managed(controller: confirmPassword),
                enabled: !state.isSubmitting,
                label: const Text('Konfirmasi Password'),
                textInputAction: .done,
                onSubmit: canSubmit ? (_) => submit() : null,
              ),
              const Gap(16),
              if (legalLoadError.value != null)
                FAlert(
                  variant: .destructive,
                  title: Text(legalLoadError.value!),
                )
              else
                Row(
                  crossAxisAlignment: .start,
                  children: [
                    FCheckbox(
                      value: acceptedLegal.value,
                      enabled: !state.isSubmitting && legalReady,
                      onChange: (v) => acceptedLegal.value = v,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          GestureDetector(
                            onTap: state.isSubmitting || !legalReady
                                ? null
                                : () => acceptedLegal.value =
                                      !acceptedLegal.value,
                            child: Text(
                              'Saya setuju Syarat dan Ketentuan',
                              style: theme.typography.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Gap(2),
                          GestureDetector(
                            onTap: () =>
                                context.push(AuthRouter.termsWebView.path),
                            child: Text(
                              'Baca dokumen lengkap di SambasKu',
                              style: theme.typography.xs.copyWith(
                                color: theme.colors.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: theme.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const Gap(16),
              FButton(
                onPress: canSubmit ? submit : null,
                prefix: emailLoading ? const FCircularProgress() : null,
                child: Text(emailLoading ? 'Memproses...' : 'Daftar'),
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
                        label: 'Daftar dengan Google',
                        isLoading: googleLoading,
                        onPress: busy
                            ? null
                            : () => ref
                                  .read(authRegisterProvider.notifier)
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
                                  .read(authRegisterProvider.notifier)
                                  .submitGithub(),
                      ),
                  ],
                ),
                if (ref.watch(facebookAuthEnabledProvider) &&
                    !state.facebookUnavailable) ...[
                  const Gap(16),
                  FacebookAuthButton(
                    label: 'Daftar dengan Facebook',
                    isLoading: facebookLoading,
                    onPress: busy
                        ? null
                        : () => ref
                              .read(authRegisterProvider.notifier)
                              .submitFacebook(),
                  ),
                ],
              ],
              const Gap(8),
              FButton(
                variant: .ghost,
                onPress: busy
                    ? null
                    : () => context.go(AuthRouter.login.path),
                child: const Text('Sudah punya akun? Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
