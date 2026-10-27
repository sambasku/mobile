import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/f_colors_x.dart';
import '../../../../shared/utils/image_sheet_drawer.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/phone_country.dart';
import '../../../../shared/utils/phone_country_picker_sheet.dart';
import '../../../../shared/utils/phone_national_digits_formatter.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../../shared/widgets/phone_country_flag.dart';
import '../../../auth/auth_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/data/providers/contribution_data_providers.dart';
import '../../domain/entities/verifier_application.dart';
import '../../verifier_application_router.dart';
import '../../../../core/i18n/l10n.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/verifier_application_providers.dart';

const _platforms = <String, String>{
  'instagram': 'Instagram',
  'facebook': 'Facebook',
  'tiktok': 'TikTok',
  'youtube': 'YouTube',
  'x': 'X',
  'website': 'Website',
};

const _maxScreenshotMb = 5;
const _uploadFolder = '/verifier-applications';

String _normalizeUsername(String raw) {
  var value = raw.trim();
  while (value.startsWith('@')) {
    value = value.substring(1).trim();
  }
  return value;
}

class SocialDraft {
  const SocialDraft({
    this.platform,
    this.username = '',
    this.screenshotUrl,
    this.screenshotFileId,
    this.localPath,
    this.uploading = false,
    this.error = false,
  });

  /// null = belum dipilih user (jangan default ke platform tertentu).
  final String? platform;
  final String username;
  final String? screenshotUrl;
  final String? screenshotFileId;
  final String? localPath;
  final bool uploading;
  final bool error;

  bool get platformReady =>
      platform != null && _platforms.containsKey(platform);

  bool get screenshotReady =>
      (screenshotUrl ?? '').isNotEmpty &&
      (screenshotFileId ?? '').isNotEmpty &&
      !uploading &&
      !error;

  SocialDraft copyWith({
    String? platform,
    String? username,
    String? screenshotUrl,
    String? screenshotFileId,
    String? localPath,
    bool? uploading,
    bool? error,
    bool clearRemoteScreenshot = false,
  }) {
    return SocialDraft(
      platform: platform ?? this.platform,
      username: username ?? this.username,
      screenshotUrl: clearRemoteScreenshot
          ? null
          : (screenshotUrl ?? this.screenshotUrl),
      screenshotFileId: clearRemoteScreenshot
          ? null
          : (screenshotFileId ?? this.screenshotFileId),
      localPath: localPath ?? this.localPath,
      uploading: uploading ?? this.uploading,
      error: error ?? this.error,
    );
  }
}

/// Validasi form sebelum kirim. Kosong = siap kirim.
///
/// Diambil keluar dari `build` supaya bisa diuji tanpa widget test.
List<String> verifierFormErrors({
  required String phoneDigits,
  required String address,
  required List<SocialDraft> social,
}) {
  final errors = <String>[];
  if (phoneDigits.isEmpty) {
    errors.add(l10n.verifierApplicationPhoneRequired);
  } else if (!RegExp(r'^\d{8,15}$').hasMatch(phoneDigits)) {
    errors.add(l10n.verifierApplicationPhoneInvalid);
  }
  if (address.trim().length < 10) {
    errors.add(l10n.verifierApplicationAddressMin);
  }
  if (social.isEmpty) {
    errors.add(l10n.verifierApplicationSocialMin);
  }
  for (var i = 0; i < social.length; i++) {
    final row = social[i];
    final label = i == 0
        ? l10n.verifierApplicationAccountFirst
        : l10n.verifierApplicationAccountNth(i + 1);
    if (!row.platformReady) {
      errors.add(l10n.verifierApplicationPickPlatformFor(label));
    }
    if (_normalizeUsername(row.username).length < 2) {
      errors.add(l10n.verifierApplicationUsernameMinFor(label));
    }
    if (row.uploading) {
      errors.add(l10n.verifierApplicationWaitUploadFor(label));
    } else if (row.error) {
      errors.add(l10n.verifierApplicationUploadFailedFor(label));
    } else if (!row.screenshotReady) {
      errors.add(l10n.verifierApplicationUploadRequiredFor(label));
    }
  }
  return errors;
}

class VerifierApplicationPage extends HookConsumerWidget {
  const VerifierApplicationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(verifierApplicationProvider);
    final phone = useTextEditingController();
    final address = useTextEditingController();
    final phoneCountry = useState(kPhoneCountryId);
    final social = useState<List<SocialDraft>>([const SocialDraft()]);
    final isReLogging = useState(false);
    useListenable(phone);
    useListenable(address);

    ref.listen(verifierApplicationProvider.select((s) => s.application), (
      _,
      next,
    ) {
      if (next == null) return;
      final parsed = parseStoredPhone(next.phone);
      phoneCountry.value = parsed.country;
      phone.text = parsed.national;
      address.text = next.address;
      social.value = next.socialLinks.isEmpty
          ? [const SocialDraft()]
          : next.socialLinks
                .map(
                  (l) => SocialDraft(
                    platform: l.platform,
                    username: l.username,
                    screenshotUrl: l.screenshot.url,
                    screenshotFileId: l.screenshot.providerFileId,
                  ),
                )
                .toList();
    });

    ref.listen(verifierApplicationProvider.select((s) => s.successMessage), (
      _,
      next,
    ) {
      if (next == null) return;
      showFToast(context: context, title: Text(next));
    });

    ref.listen(verifierApplicationProvider.select((s) => s.errorMessage), (
      _,
      next,
    ) {
      if (next == null || !context.mounted) return;
      showAppErrorSheet(context, message: next).whenComplete(() {
        if (context.mounted) {
          ref.read(verifierApplicationProvider.notifier).clearError();
        }
      });
    });

    final application = state.application;
    final pending = application?.isPending == true;
    final rejected = application?.isRejected == true;
    final approved = application?.isApproved == true;
    final needsRevision = application?.needsRevision == true;
    final readOnly = state.isSubmitting;

    // Baris tidak lengkap dilewati di sini; validasi di `submit()` yang
    // menjelaskan ke user kenapa belum bisa dikirim.
    final links = <SocialLink>[];
    for (final row in social.value) {
      final username = _normalizeUsername(row.username);
      final platform = row.platform;
      if (!row.platformReady ||
          platform == null ||
          username.length < 2 ||
          !row.screenshotReady) {
        continue;
      }
      links.add(
        SocialLink(
          platform: platform,
          username: username,
          screenshot: SocialScreenshot(
            url: row.screenshotUrl!,
            providerFileId: row.screenshotFileId!,
          ),
        ),
      );
    }
    final blocked = readOnly || state.isLoading || pending || approved;

    void submit() {
      final phoneDigits = toInternationalPhoneDigits(
        phoneCountry.value,
        phone.text.trim(),
      );
      final errors = verifierFormErrors(
        phoneDigits: phoneDigits,
        address: address.text.trim(),
        social: social.value,
      );
      if (errors.isNotEmpty) {
        showAppErrorSheet(
          context,
          title: AppLocalizations.of(context).verifierApplicationCannotSendTitle,
          message: errors.map((e) => '- $e').join('\n'),
        );
        return;
      }
      ref
          .read(verifierApplicationProvider.notifier)
          .submit(
            phone: phoneDigits,
            address: address.text.trim(),
            socialLinks: links,
          );
    }

    Future<void> reLogin() async {
      if (isReLogging.value) return;
      isReLogging.value = true;
      try {
        await ref.read(authStatusProvider.notifier).logout();
        if (!context.mounted) return;
        // Biarkan frame berikutnya baca isAuth=false sebelum masuk /login
        // (hindari redirect balik ke HOME karena sesi lama).
        await Future<void>.delayed(Duration.zero);
        if (!context.mounted) return;
        context.go('${AuthRouter.login.path}?relogin=1');
      } finally {
        if (context.mounted) isReLogging.value = false;
      }
    }

    final theme = context.theme;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(AppLocalizations.of(context).verifierApplicationTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/profile'),
          ),
        ],
      ),
      child: state.isLoading
          ? const Center(child: FCircularProgress())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (approved) ...[
                  if (isReLogging.value) ...[
                    const Gap(48),
                    const Center(child: FCircularProgress()),
                    const Gap(16),
                    Text(
                      AppLocalizations.of(context).verifierApplicationOpeningLogin,
                      textAlign: .center,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ] else ...[
                    const Gap(24),
                    Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.success.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Icon(
                            FLucideIcons.circleCheck,
                            size: 64,
                            color: theme.colors.success,
                          ),
                        ),
                      ),
                    ),
                    const Gap(20),
                    Text(
                      AppLocalizations.of(context).verifierApplicationApprovedTitle,
                      textAlign: .center,
                      style: theme.typography.body.xl.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.success,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      AppLocalizations.of(context).verifierApplicationApprovedBody,
                      textAlign: .center,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(24),
                    FButton(
                      onPress: reLogin,
                      prefix: const Icon(FLucideIcons.logIn),
                      child: Text(AppLocalizations.of(context).verifierApplicationReLoginCta),
                    ),
                  ],
                ] else if (pending) ...[
                  FAlert(
                    title: Text(AppLocalizations.of(context).verifierApplicationPendingTitle),
                    subtitle: Text(
                      AppLocalizations.of(context).verifierApplicationPendingBody,
                    ),
                  ),
                ] else ...[
                  FTileGroup(
                    children: [
                      FTile(
                        prefix: const Icon(FLucideIcons.badgeCheck),
                        title: Text(AppLocalizations.of(context).verifierApplicationLearnTitle),
                        subtitle: Text(
                          AppLocalizations.of(context).verifierApplicationLearnSubtitle,
                        ),
                        suffix: const Icon(FLucideIcons.chevronRight),
                        onPress: () =>
                            context.push(VerifierApplicationRouter.about.path),
                      ),
                    ],
                  ),
                  const Gap(12),
                  if (needsRevision) ...[
                    FAlert(
                      variant: .destructive,
                      title: Text(AppLocalizations.of(context).verifierApplicationNeedsRevisionTitle),
                      subtitle: Text(application!.adminComment!.trim()),
                    ),
                    const Gap(12),
                  ] else if (rejected) ...[
                    FAlert(
                      variant: .destructive,
                      title: Text(AppLocalizations.of(context).verifierApplicationRejectedTitle),
                      subtitle: Text(
                        AppLocalizations.of(context).verifierApplicationRejectedBody,
                      ),
                    ),
                    const Gap(12),
                  ],
                  FTextField(
                    control: .managed(controller: phone),
                    enabled: !readOnly,
                    label: Text(AppLocalizations.of(context).verifierApplicationPhoneLabel),
                    hint: AppLocalizations.of(context).verifierApplicationPhoneHint,
                    keyboardType: .phone,
                    textInputAction: .next,
                    inputFormatters: const [PhoneNationalDigitsFormatter()],
                    prefixBuilder: (context, style, variants) =>
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: readOnly
                              ? null
                              : () async {
                                  final picked =
                                      await showPhoneCountryPickerSheet(
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
                                  style: context.theme.typography.body.sm
                                      .copyWith(
                                        color: context
                                            .theme
                                            .colors
                                            .mutedForeground,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Icon(
                                  FLucideIcons.chevronDown,
                                  size: 14,
                                  color: context.theme.colors.mutedForeground,
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                  const Gap(12),
                  FTextField(
                    control: .managed(controller: address),
                    enabled: !readOnly,
                    label: Text(AppLocalizations.of(context).verifierApplicationAddressLabel),
                    hint: AppLocalizations.of(context).verifierApplicationAddressHint,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    minLines: 3,
                    maxLines: 6,
                  ),
                  const Gap(16),
                  Text(
                    AppLocalizations.of(context).verifierApplicationSocialSection,
                    style: context.theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(8),
                  for (var i = 0; i < social.value.length; i++) ...[
                    if (i > 0) const Gap(16),
                    _SocialRow(
                      key: ValueKey('social-$i'),
                      index: i,
                      draft: social.value[i],
                      enabled: !readOnly,
                      canRemove: social.value.length > 1 && !readOnly,
                      onChanged: (next) {
                        final copy = [...social.value];
                        copy[i] = next;
                        social.value = copy;
                      },
                      onRemove: () {
                        final copy = [...social.value]..removeAt(i);
                        social.value = copy;
                      },
                    ),
                  ],
                  if (!readOnly && social.value.length < 5) ...[
                    const Gap(12),
                    FButton(
                      variant: .outline,
                      onPress: () {
                        social.value = [...social.value, const SocialDraft()];
                      },
                      child: Text(AppLocalizations.of(context).verifierApplicationAddSocial),
                    ),
                  ],
                  const Gap(16),
                  FButton(
                    onPress: blocked ? null : submit,
                    prefix: state.isSubmitting
                        ? const FCircularProgress()
                        : null,
                    child: Text(
                      state.isSubmitting
                          ? AppLocalizations.of(context).verifierApplicationSubmitting
                          : rejected
                          ? AppLocalizations.of(context).verifierApplicationResubmit
                          : AppLocalizations.of(context).verifierApplicationSubmit,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    AppLocalizations.of(context).verifierApplicationPrivacyNote,
                    textAlign: .center,
                    style: context.theme.typography.body.sm.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _SocialRow extends ConsumerStatefulWidget {
  const _SocialRow({
    super.key,
    required this.index,
    required this.draft,
    required this.enabled,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final SocialDraft draft;
  final bool enabled;
  final bool canRemove;
  final ValueChanged<SocialDraft> onChanged;
  final VoidCallback onRemove;

  @override
  ConsumerState<_SocialRow> createState() => _SocialRowState();
}

class _SocialRowState extends ConsumerState<_SocialRow> {
  late final TextEditingController _username;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _username = TextEditingController(text: widget.draft.username);
  }

  @override
  void didUpdateWidget(covariant _SocialRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.username != widget.draft.username &&
        _username.text != widget.draft.username) {
      _username.text = widget.draft.username;
    }
  }

  @override
  void dispose() {
    _username.dispose();
    super.dispose();
  }

  Future<void> _pickPlatform() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = sheetContext.theme;
        return Material(
          color: Theme.of(sheetContext).colorScheme.surface,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text(
                    AppLocalizations.of(context).verifierApplicationPickPlatform,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(12),
                  FTileGroup(
                    children: [
                      for (final entry in _platforms.entries)
                        FTile(
                          title: Text(entry.value),
                          suffix: entry.key == widget.draft.platform
                              ? Icon(
                                  FLucideIcons.check,
                                  size: 16,
                                  color: theme.colors.primary,
                                )
                              : null,
                          onPress: () =>
                              Navigator.of(sheetContext).pop(entry.key),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (selected != null && selected != widget.draft.platform) {
      widget.onChanged(
        widget.draft.copyWith(platform: selected, username: _username.text),
      );
    }
  }

  void _openScreenshotPicker() {
    if (!widget.enabled || widget.draft.uploading) return;
    showImageSheetDrawer(
      context,
      picker: _picker,
      filePicker: false,
      onPicked: _handlePicked,
    );
  }

  Future<void> _handlePicked(File file) async {
    if (!mounted) return;
    try {
      final size = await file.length();
      if (size > _maxScreenshotMb * 1024 * 1024) {
        if (mounted) _toast(AppLocalizations.of(context).verifierApplicationImageTooLarge(_maxScreenshotMb));
        return;
      }

      widget.onChanged(
        widget.draft.copyWith(
          username: _username.text,
          localPath: file.path,
          uploading: true,
          error: false,
          clearRemoteScreenshot: true,
        ),
      );

      final result = await ref
          .read(privateImageUploadServiceProvider)
          .uploadFile(file, folder: _uploadFolder);
      if (!mounted) return;

      result.match(
        (failure) {
          widget.onChanged(
            widget.draft.copyWith(
              username: _username.text,
              localPath: file.path,
              uploading: false,
              error: true,
              clearRemoteScreenshot: true,
            ),
          );
          _toast(failure.message);
        },
        (dto) {
          widget.onChanged(
            widget.draft.copyWith(
              username: _username.text,
              localPath: file.path,
              screenshotUrl: dto.url,
              screenshotFileId: dto.providerFileId,
              uploading: false,
              error: false,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('[ImageSheet] verifier screenshot $e');
      if (mounted) _toast(AppLocalizations.of(context).verifierApplicationImageProcessFailed);
    }
  }

  void _toast(String message) {
    showFToast(
      context: context,
      title: Text(message),
      variant: FToastVariant.destructive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.draft.platform;
    final l10n = AppLocalizations.of(context);
    final label = selected == null
        ? l10n.verifierApplicationPickPlatform
        : (_platforms[selected] ?? selected);
    final theme = context.theme;
    final hint = selected == 'website'
        ? l10n.verifierApplicationUsernameHintSite
        : l10n.verifierApplicationUsernameHintUser;

    return Column(
      crossAxisAlignment: .start,
      children: [
        FTileGroup(
          children: [
            FTile(
              title: Text(label),
              subtitle: Text(
                widget.index == 0
                    ? l10n.verifierApplicationPlatformLabel
                    : l10n.verifierApplicationPlatformNth(widget.index + 1),
              ),
              suffix: Icon(
                FLucideIcons.chevronDown,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
              onPress: widget.enabled ? _pickPlatform : null,
            ),
          ],
        ),
        const Gap(8),
        FTextField(
          control: .managed(
            controller: _username,
            onChange: (value) =>
                widget.onChanged(widget.draft.copyWith(username: value.text)),
          ),
          enabled: widget.enabled,
          label: Text(l10n.verifierApplicationUsernameLabel),
          hint: hint,
          keyboardType: TextInputType.text,
          textInputAction: .next,
        ),
        const Gap(8),
        Text(
          l10n.verifierApplicationScreenshotLabel,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(6),
        _ScreenshotSlot(
          draft: widget.draft,
          enabled: widget.enabled,
          onTap: _openScreenshotPicker,
        ),
        if (widget.canRemove) ...[
          const Gap(4),
          Align(
            alignment: .centerRight,
            child: FButton(
              variant: .ghost,
              onPress: widget.onRemove,
              prefix: const Icon(FLucideIcons.trash, size: 16),
              child: Text(l10n.verifierApplicationRemoveAccount),
            ),
          ),
        ],
      ],
    );
  }
}

class _ScreenshotSlot extends StatelessWidget {
  const _ScreenshotSlot({
    required this.draft,
    required this.enabled,
    required this.onTap,
  });

  final SocialDraft draft;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final local = draft.localPath;
    final remote = draft.screenshotUrl;

    Widget preview;
    if (local != null && local.isNotEmpty) {
      preview = Image.file(
        File(local),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => ColoredBox(
          color: theme.colors.muted,
          child: Icon(FLucideIcons.image, color: theme.colors.mutedForeground),
        ),
      );
    } else if (remote != null && remote.isNotEmpty) {
      preview = CachedNetworkImageWithFallback(
        imageUrl: remote,
        fit: BoxFit.cover,
      );
    } else {
      preview = ColoredBox(
        color: theme.colors.muted,
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(FLucideIcons.camera, color: theme.colors.mutedForeground),
            const Gap(4),
            Text(
              AppLocalizations.of(context).verifierApplicationCameraGallery,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 96,
        height: 96,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: preview,
              ),
            ),
            if (draft.uploading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x88000000),
                  child: Center(child: FCircularProgress()),
                ),
              ),
            if (draft.error)
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0x88B91C1C),
                  child: Icon(
                    FLucideIcons.circleAlert,
                    color: theme.colors.primaryForeground,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
