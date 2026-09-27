import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../utils/public_account_name.dart';

/// Baris pesan thread (komentar kata / balasan bantuan) - layout kanonik.
///
/// Pola visual mengikuti `WordCommentsSection`: username · meta satu baris,
/// body di bawah, aksi hapus kompak, footer opsional (vote / badge).
class ThreadMessageRow extends StatelessWidget {
  const ThreadMessageRow({
    super.key,
    required this.username,
    required this.body,
    this.displayName,
    this.dateLabel,
    this.metaParts = const [],
    this.isRedacted = false,
    this.onUsernameTap,
    this.onDelete,
    this.footer,
    this.highlighted = false,
  });

  /// Username mentah (nullable); dipakai untuk tap profil.
  final String? username;

  /// Nama tampilan; fallback ke [username] lewat [displayPublicAccountLabel].
  final String? displayName;
  final String body;
  final String? dateLabel;

  /// Bagian meta setelah username (status, "dihapus …", dsb.).
  final List<String> metaParts;
  final bool isRedacted;
  final VoidCallback? onUsernameTap;
  final VoidCallback? onDelete;

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
    final rest = [
      if (dateLabel != null && dateLabel!.isNotEmpty) dateLabel!,
      ...metaParts.where((p) => p.trim().isNotEmpty),
    ].join(' · ');

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: onUsernameTap == null || isRedacted
                        ? Text(
                            label,
                            style: theme.typography.sm.copyWith(
                              color: theme.colors.mutedForeground,
                              fontSize: 11,
                            ),
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
                                style: theme.typography.sm.copyWith(
                                  color: theme.colors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                  ),
                  if (rest.isNotEmpty)
                    Flexible(
                      child: Text(
                        ' · $rest',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            if (onDelete != null)
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
        ),
        const Gap(2),
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
        if (footer != null) ...[const Gap(4), footer!],
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: highlighted
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.secondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colors.primary.withValues(alpha: 0.35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: content,
              ),
            )
          : content,
    );
  }
}

/// Composer thread kanonik: field multi-baris + tombol Kirim di kanan bawah.
class ThreadComposer extends StatelessWidget {
  const ThreadComposer({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
    this.hint = 'Tulis komentar…',
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTextField(
          control: FTextFieldControl.managed(controller: controller),
          hint: hint,
          enabled: !isSubmitting,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 1,
        ),
        const Gap(6),
        Align(
          alignment: Alignment.centerRight,
          child: FButton(
            onPress: isSubmitting ? null : onSubmit,
            prefix: isSubmitting ? const FCircularProgress() : null,
            child: Text(isSubmitting ? 'Mengirim...' : 'Kirim'),
          ),
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
