import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../core/widgets/verified_badge_icon.dart';
import '../utils/public_account_name.dart';
import 'user_avatar.dart';

/// Label peran di header thread (hanya Verifikator yang ditampilkan).
String threadAuthorRoleLabel({required bool isVerifier}) =>
    isVerifier ? 'Verifikator' : 'Kontributor';

/// Baris pesan thread (komentar kata / balasan bantuan) - layout kanonik.
///
/// ```
/// [Avatar] Nama ✓  2h
///          isi komentar…
///          [footer]
/// ```
class ThreadMessageRow extends StatelessWidget {
  const ThreadMessageRow({
    super.key,
    required this.username,
    required this.body,
    this.displayName,
    this.avatarUrl,
    this.isVerifier = false,
    this.dateLabel,
    this.metaParts = const [],
    this.isRedacted = false,
    this.onUsernameTap,
    this.onDelete,
    this.media,
    this.footer,
    this.highlighted = false,
  });

  /// Username mentah (nullable); dipakai untuk tap profil.
  final String? username;

  /// Nama tampilan; fallback ke [username] lewat [displayPublicAccountLabel].
  final String? displayName;

  /// URL avatar publik; null → inisial.
  final String? avatarUrl;

  /// true → centang hijau di samping nama.
  final bool isVerifier;

  final String body;

  /// Humanize singkat di header (mis. `2h` dari [formatRelativeCompact]).
  final String? dateLabel;

  /// Bagian meta setelah tanggal (status, "Disematkan", dsb.).
  final List<String> metaParts;
  final bool isRedacted;
  final VoidCallback? onUsernameTap;
  final VoidCallback? onDelete;

  /// Konten di bawah body (mis. player audio balasan).
  final Widget? media;

  /// Konten di bawah body (mis. [VoteButtons]).
  final Widget? footer;

  /// Latar lembut (mis. balasan disematkan).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = displayPublicAccountLabel(
      displayName: displayName,
      username: username,
    );
    final trailingMeta = [
      if (dateLabel != null && dateLabel!.isNotEmpty) dateLabel!,
      ...metaParts.where((p) => p.trim().isNotEmpty),
    ].join(' · ');

    final nameStyle = theme.typography.sm.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: onUsernameTap == null || isRedacted
          ? theme.colors.foreground
          : theme.colors.primary,
    );
    final metaStyle = theme.typography.sm.copyWith(
      color: theme.colors.mutedForeground,
      fontSize: 11,
      height: 1.2,
    );

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(name: label, imageUrl: avatarUrl, size: 28),
        const Gap(8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: onUsernameTap == null || isRedacted
                              ? Text(
                                  label,
                                  style: nameStyle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Semantics(
                                  button: true,
                                  label: 'Lihat profil $label',
                                  child: GestureDetector(
                                    onTap: onUsernameTap,
                                    child: Text(
                                      label,
                                      style: nameStyle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                        ),
                        if (isVerifier) ...[
                          const Gap(3),
                          const VerifiedBadgeIcon(size: 13),
                        ],
                      ],
                    ),
                  ),
                  if (trailingMeta.isNotEmpty) ...[
                    const Gap(6),
                    Text(
                      trailingMeta,
                      style: metaStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (onDelete != null) ...[
                    const Spacer(),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: onDelete,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            FLucideIcons.trash,
                            size: 14,
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Gap(3),
              if (body.trim().isNotEmpty)
                Text(
                  body,
                  style: theme.typography.sm.copyWith(
                    height: 1.35,
                    fontStyle: isRedacted ? FontStyle.italic : FontStyle.normal,
                    color: isRedacted
                        ? theme.colors.mutedForeground
                        : theme.colors.foreground,
                  ),
                ),
              if (media != null) ...[
                if (body.trim().isNotEmpty) const Gap(6),
                media!,
              ],
              if (footer != null) ...[const Gap(4), footer!],
            ],
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: highlighted
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.secondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: content,
              ),
            )
          : content,
    );
  }
}

/// Composer thread kanonik: field multi-baris + kirim.
/// Opsional [onRecordAudio] menampilkan chip berlabel "Rekam suara".
class ThreadComposer extends StatelessWidget {
  const ThreadComposer({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
    this.onRecordAudio,
    this.hint = 'Tulis komentar…',
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  /// Jika diisi, tampilkan chip "Rekam suara" di bawah field.
  final VoidCallback? onRecordAudio;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onRecordAudio != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              label: 'Rekam suara',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isSubmitting ? null : onRecordAudio,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colors.border,
                      ),
                      color: isSubmitting
                          ? theme.colors.secondary.withValues(alpha: 0.5)
                          : theme.colors.secondary.withValues(alpha: 0.35),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FLucideIcons.mic,
                            size: 14,
                            color: theme.colors.foreground,
                          ),
                          const Gap(6),
                          Text(
                            'Rekam suara',
                            style: theme.typography.sm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Gap(8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FTextField(
                control: FTextFieldControl.managed(controller: controller),
                hint: hint,
                enabled: !isSubmitting,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 3,
                minLines: 1,
              ),
            ),
            const Gap(6),
            Semantics(
              button: true,
              label: 'Kirim',
              child: Material(
                color: isSubmitting
                    ? theme.colors.primary.withValues(alpha: 0.5)
                    : theme.colors.primary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isSubmitting ? null : onSubmit,
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: isSubmitting
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colors.primaryForeground,
                              ),
                            )
                          : Icon(
                              FLucideIcons.send,
                              size: 16,
                              color: theme.colors.primaryForeground,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Prompt login di kaki thread (komentar / balasan).
class ThreadLoginPrompt extends StatelessWidget {
  const ThreadLoginPrompt({
    super.key,
    required this.message,
    required this.onLogin,
  });

  final String message;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: theme.typography.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        FButton(
          variant: FButtonVariant.outline,
          onPress: onLogin,
          child: const Text('Masuk'),
        ),
      ],
    );
  }
}
