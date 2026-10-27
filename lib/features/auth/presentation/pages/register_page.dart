import 'dart:async';

import 'package:dio/dio.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../l10n/app_localizations.dart';
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

    // Dibaca di luar hook: `Localizations.of` di dalam callback useEffect
    // mengenai init-hook assert flutter_hooks.
    final l10n = AppLocalizations.of(context);
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
            legalLoadError.value = e.message ?? l10n.authLegalLoadFailed;
          }
        } catch (_) {
          if (!cancelled) {
            legalLoadError.value = l10n.authLegalLoadFailed;
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
            ref.read(authRegisterProvider).errorMessage ??
                AppLocalizations.of(context).authRateLimitedFallback,
          ),
        );
        ref.read(authRegisterProvider.notifier).clearError();
        return;
      }
      if (code == AuthFailure.googleSignInCanceled ||
          code == AuthFailure.facebookSignInCanceled ||
          code == AuthFailure.githubSignInCanceled) {
        showFToast(
          context: context,
          title: Text(AppLocalizations.of(context).authRegisterCanceled),
        );
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
        context.push(
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

    /// Tombol sosial di halaman Daftar WAJIB lewat checkbox legal dulu -
    /// server (mode enforce) menolak akun baru tanpa consents.
    final socialReady = acceptedLegal.value && legalReady && !busy;
    List<({String documentType, String documentVersion})>? socialConsents() {
      final terms = termsVersion.value;
      final privacy = privacyVersion.value;
      if (terms == null || privacy == null) return null;
      return [
        (documentType: 'terms', documentVersion: terms),
        (documentType: 'privacy', documentVersion: privacy),
      ];
    }

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
        title: Text(AppLocalizations.of(context).authRegisterTitle),
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
                AppLocalizations.of(context).authRegisterHeadline,
                textAlign: .center,
                style: theme.typography.body.xl.copyWith(
                  fontWeight: .w600,
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(8),
              Text(
                AppLocalizations.of(context).authRegisterBody,
                textAlign: .center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const Gap(24),
              FTextField(
                control: .managed(controller: name),
                enabled: !state.isSubmitting,
                label: Text(AppLocalizations.of(context).authNameLabel),
                textInputAction: .next,
              ),
              const Gap(12),
              FTextField.email(
                control: .managed(controller: email),
                enabled: !state.isSubmitting,
                label: Text(AppLocalizations.of(context).authEmailLabel),
              ),
              const Gap(12),
              FTextField(
                control: .managed(controller: phone),
                enabled: !state.isSubmitting,
                label: Text(
                  AppLocalizations.of(context).authPhoneOptionalLabel,
                ),
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
                          style: theme.typography.body.sm.copyWith(
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
                label: Text(AppLocalizations.of(context).authPasswordLabel),
                hint: AppLocalizations.of(context).authPasswordHint,
                textInputAction: .next,
              ),
              const Gap(12),
              FTextField.password(
                control: .managed(controller: confirmPassword),
                enabled: !state.isSubmitting,
                label: Text(
                  AppLocalizations.of(context).authConfirmPasswordLabel,
                ),
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
                              AppLocalizations.of(context).authAgreeTerms,
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Gap(2),
                          GestureDetector(
                            onTap: () =>
                                context.push(AuthRouter.termsWebView.path),
                            child: Text(
                              AppLocalizations.of(context).authReadFullDoc,
                              style: theme.typography.body.xs.copyWith(
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
                child: Text(
                  emailLoading
                      ? AppLocalizations.of(context).authSubmitting
                      : AppLocalizations.of(context).authRegisterAction,
                ),
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
                        label: AppLocalizations.of(
                          context,
                        ).authRegisterWithGoogle,
                        isLoading: googleLoading,
                        onPress: socialReady
                            ? () => ref
                                  .read(authRegisterProvider.notifier)
                                  .submitGoogle(consents: socialConsents())
                            : null,
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
                        onPress: socialReady
                            ? () => ref
                                  .read(authRegisterProvider.notifier)
                                  .submitGithub(consents: socialConsents())
                            : null,
                      ),
                  ],
                ),
                if (ref.watch(facebookAuthEnabledProvider) &&
                    !state.facebookUnavailable) ...[
                  const Gap(16),
                  FacebookAuthButton(
                    label: AppLocalizations.of(
                      context,
                    ).authRegisterWithFacebook,
                    isLoading: facebookLoading,
                    onPress: socialReady
                        ? () => ref
                              .read(authRegisterProvider.notifier)
                              .submitFacebook(consents: socialConsents())
                        : null,
                  ),
                ],
              ],
              const Gap(8),
              FButton(
                variant: .ghost,
                onPress: busy ? null : () => context.go(AuthRouter.login.path),
                child: Text(AppLocalizations.of(context).authHaveAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
