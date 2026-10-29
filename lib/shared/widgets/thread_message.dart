import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../utils/public_account_name.dart';
import '../utils/thread_reply_draft.dart';
import 'public_account_name.dart';
import 'user_avatar.dart';
import '../../../l10n/app_localizations.dart';

/// Label peran di header thread. Centang hijau sudah mewakili verifikator,
/// jadi label teks tidak lagi ditampilkan (dibiarkan untuk kompatibilitas
/// caller lama).
String threadAuthorRoleLabel({required bool isVerifier}) =>
    isVerifier ? 'Verifikator' : 'Kontributor';

/// Baris pesan thread (komentar kata / balasan bantuan) - layout kanonik.
///
/// ```
/// [Avatar] Nama ✓  2h
///          @username
///          isi komentar…
///          [footer]                    [hapus]
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
    this.onMentionTap,
    this.onDelete,
    this.onEdit,
    this.onReply,
    this.isEdited = false,
    this.editedLabel,
    this.onShowEditHistory,
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

  /// Humanize singkat di header (mis. `2 jam` dari [formatRelativeCompact]).
  final String? dateLabel;

  /// Bagian meta setelah tanggal (status, "Disematkan", dsb.).
  final List<String> metaParts;
  final bool isRedacted;
  final VoidCallback? onUsernameTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  /// Shortcut balas (#205): tampil bila non-null dan baris tidak redacted.
  final VoidCallback? onReply;

  /// true → tampilkan [editedLabel] di meta (tap → [onShowEditHistory]).
  final bool isEdited;

  /// Label tappable sunting (mis. dari l10n.commentEdited).
  final String? editedLabel;
  final VoidCallback? onShowEditHistory;

  /// Tap `@username` di body → callback (navigasi profil).
  final ValueChanged<String>? onMentionTap;

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
    // Tampilkan @username bila label memakai display name - user perlu tahu
    // handle untuk mention (issue: susah mention karena username tak terlihat).
    final showHandle =
        !isRedacted && isLinkablePublicUsername(username) && username != label;
    final nameStyle = theme.typography.body.sm.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: onUsernameTap == null || isRedacted
          ? theme.colors.foreground
          : theme.colors.primary,
    );
    final metaStyle = theme.typography.body.sm.copyWith(
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
                    child: PublicAccountName(
                      label: label,
                      isVerifier: isVerifier,
                      onTap: onUsernameTap == null || isRedacted
                          ? null
                          : onUsernameTap,
                      style: nameStyle,
                    ),
                  ),
                  if (_hasTrailingMeta) ...[
                    const Gap(6),
                    Flexible(
                      child: _ThreadMetaRow(
                        dateLabel: dateLabel,
                        metaParts: metaParts,
                        isEdited: isEdited,
                        editedLabel: editedLabel,
                        onShowEditHistory: onShowEditHistory,
                        style: metaStyle,
                        editedStyle: metaStyle.copyWith(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if ((onEdit != null || onDelete != null) &&
                      footer == null &&
                      !_showReplyAction) ...[
                    const Spacer(),
                    _ThreadRowActions(onEdit: onEdit, onDelete: onDelete),
                  ],
                ],
              ),
              // Handle @username di baris sendiri di bawah nama - user perlu
              // tahu handle untuk mention (issue: username tak terlihat).
              if (showHandle) ...[
                const Gap(2),
                Text(
                  '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: metaStyle,
                ),
              ],
              const Gap(3),
              if (body.trim().isNotEmpty)
                MentionBodyText(
                  body: body,
                  isRedacted: isRedacted,
                  onMentionTap: onMentionTap,
                  style: theme.typography.body.sm.copyWith(
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
              if (footer != null || _showReplyAction || onEdit != null || onDelete != null) ...[
                const Gap(4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (footer != null)
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: footer!,
                        ),
                      )
                    else
                      const Spacer(),
                    if (_showReplyAction)
                      _ThreadReplyButton(onPressed: onReply!),
                    _ThreadRowActions(onEdit: onEdit, onDelete: onDelete),
                  ],
                ),
              ],
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
              child: Padding(padding: const EdgeInsets.all(8), child: content),
            )
          : content,
    );
  }

  bool get _hasTrailingMeta =>
      (dateLabel != null && dateLabel!.isNotEmpty) ||
      metaParts.any((p) => p.trim().isNotEmpty) ||
      (isEdited && onShowEditHistory != null);

  bool get _showReplyAction => onReply != null && !isRedacted;
}

class _ThreadReplyButton extends StatelessWidget {
  const _ThreadReplyButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Semantics(
      button: true,
      label: l10n.threadReply,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              l10n.threadReply,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreadMetaRow extends StatelessWidget {
  const _ThreadMetaRow({
    required this.dateLabel,
    required this.metaParts,
    required this.isEdited,
    required this.editedLabel,
    required this.onShowEditHistory,
    required this.style,
    required this.editedStyle,
  });

  final String? dateLabel;
  final List<String> metaParts;
  final bool isEdited;
  final String? editedLabel;
  final VoidCallback? onShowEditHistory;
  final TextStyle style;
  final TextStyle editedStyle;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    void sep() {
      if (children.isNotEmpty) {
        children.add(Text(' · ', style: style));
      }
    }

    if (dateLabel != null && dateLabel!.isNotEmpty) {
      children.add(Text(dateLabel!, style: style));
    }
    if (isEdited && onShowEditHistory != null) {
      sep();
      children.add(
        GestureDetector(
          onTap: onShowEditHistory,
          child: Text(
            editedLabel ?? AppLocalizations.of(context).commentEdited,
            style: editedStyle,
          ),
        ),
      );
    }
    for (final part in metaParts.where((p) => p.trim().isNotEmpty)) {
      sep();
      children.add(Text(part, style: style));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

class _ThreadRowActions extends StatelessWidget {
  const _ThreadRowActions({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onEdit != null)
          _ThreadIconButton(
            icon: FLucideIcons.pencil,
            onPressed: onEdit!,
            semanticsLabel: AppLocalizations.of(context).commentEdit,
          ),
        if (onDelete != null)
          _ThreadIconButton(
            icon: FLucideIcons.trash,
            onPressed: onDelete!,
            semanticsLabel: AppLocalizations.of(context).commonDelete,
          ),
      ],
    );
  }
}

class _ThreadIconButton extends StatelessWidget {
  const _ThreadIconButton({
    required this.icon,
    required this.onPressed,
    required this.semanticsLabel,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(
              icon,
              size: 14,
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Composer thread kanonik: field multi-baris + kirim.
/// Opsional [onRecordAudio] / [onPickImage] menampilkan chip aksi di atas field.
/// [suggestBuilder] dipasang di atas field (mis. autocomplete mention).
class ThreadComposer extends StatelessWidget {
  const ThreadComposer({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
    this.onRecordAudio,
    this.onPickImage,
    this.attachmentPreview,
    this.replyBanner,
    this.suggestBuilder,
    this.focusNode,
    this.hint = 'Tulis komentar…',
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  /// Jika diisi, tampilkan chip rekam suara di atas field.
  final VoidCallback? onRecordAudio;

  /// Jika diisi, tampilkan chip lampirkan foto di atas field.
  final VoidCallback? onPickImage;

  /// Pratinjau lampiran (mis. thumbnail foto staging) di atas field.
  final Widget? attachmentPreview;

  /// Chip "Membalas @user" (#205) di atas aksi foto/mic.
  final Widget? replyBanner;

  /// Builder opsional untuk overlay suggestion (mis. mention autocomplete).
  final Widget Function(BuildContext)? suggestBuilder;

  /// Fokus field setelah tap Balas.
  final FocusNode? focusNode;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (suggestBuilder != null) ...[suggestBuilder!(context), const Gap(4)],
        if (replyBanner != null) ...[
          replyBanner!,
          const Gap(8),
        ],
        if (attachmentPreview != null) ...[
          attachmentPreview!,
          const Gap(8),
        ],
        if (onRecordAudio != null || onPickImage != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onPickImage != null)
                _ThreadComposerChip(
                  icon: FLucideIcons.image,
                  label: AppLocalizations.of(context).commentAddPhoto,
                  semanticsLabel: AppLocalizations.of(context).threadAddPhoto,
                  enabled: !isSubmitting,
                  onTap: onPickImage!,
                ),
              if (onRecordAudio != null)
                _ThreadComposerChip(
                  icon: FLucideIcons.mic,
                  label: AppLocalizations.of(context).threadRecordVoice,
                  semanticsLabel: AppLocalizations.of(context).threadRecordVoice,
                  enabled: !isSubmitting,
                  onTap: onRecordAudio!,
                ),
            ],
          ),
          const Gap(8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: FTextField(
                control: FTextFieldControl.managed(controller: controller),
                focusNode: focusNode,
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
              label: AppLocalizations.of(context).threadSend,
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

class _ThreadComposerChip extends StatelessWidget {
  const _ThreadComposerChip({
    required this.icon,
    required this.label,
    required this.semanticsLabel,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String semanticsLabel;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled ? onTap : null,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colors.border),
              color: enabled
                  ? theme.colors.secondary.withValues(alpha: 0.35)
                  : theme.colors.secondary.withValues(alpha: 0.5),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: theme.colors.foreground),
                  const Gap(6),
                  Text(
                    label,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip dismissible "Membalas @user" di atas composer (#205).
class ThreadReplyBanner extends StatelessWidget {
  const ThreadReplyBanner({
    super.key,
    required this.title,
    required this.onDismiss,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: theme.colors.primary, width: 3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colors.primary,
                    ),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const Gap(2),
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Semantics(
              button: true,
              label: l10n.threadReplyDismiss,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: onDismiss,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      FLucideIcons.x,
                      size: 14,
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
        FButton(
          variant: FButtonVariant.outline,
          onPress: onLogin,
          child: Text(AppLocalizations.of(context).commonLoginRequiredShort),
        ),
      ],
    );
  }
}

/// Teks body thread dengan deteksi `@username`: mention dirender bold +
/// warna primer, tap → [onMentionTap] (navigasi profil).
/// Leading baris `>` dirender sebagai cuplikan quote (#205).
class MentionBodyText extends StatelessWidget {
  const MentionBodyText({
    super.key,
    required this.body,
    required this.style,
    this.isRedacted = false,
    this.onMentionTap,
  });

  final String body;
  final TextStyle style;
  final bool isRedacted;

  /// Callback dengan username yang di-tap (tanpa `@`).
  final ValueChanged<String>? onMentionTap;

  static final RegExp _mentionRe = RegExp(
    r'@([a-zA-Z0-9_.\-]{2,30})(?![a-zA-Z0-9_.\-])',
  );

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final mentionStyle = style.copyWith(
      color: isRedacted ? null : theme.colors.primary,
      fontWeight: isRedacted ? null : FontWeight.w600,
    );

    final split = splitLeadingBlockquote(body);
    final quoteStyle = style.copyWith(
      color: theme.colors.mutedForeground,
      fontStyle: FontStyle.italic,
    );
    final quoteMentionStyle = quoteStyle.copyWith(
      color: isRedacted ? null : theme.colors.primary,
      fontWeight: isRedacted ? null : FontWeight.w600,
      fontStyle: FontStyle.normal,
    );

    if (split.quote.isEmpty) {
      return RichText(text: _buildTextSpan(body, mentionStyle, style));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: theme.colors.border, width: 3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: RichText(
              text: _buildTextSpan(split.quote, quoteMentionStyle, quoteStyle),
            ),
          ),
        ),
        if (split.rest.trim().isNotEmpty) ...[
          const Gap(6),
          RichText(
            text: _buildTextSpan(split.rest, mentionStyle, style),
          ),
        ],
      ],
    );
  }

  TextSpan _buildTextSpan(
    String text,
    TextStyle mentionStyle,
    TextStyle baseStyle,
  ) {
    final spans = <TextSpan>[];
    var lastEnd = 0;

    for (final match in _mentionRe.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      final username = match.group(1)!;
      // `anonim` = akun sistem, dirender sebagai teks biasa.
      final isRealMention = username.toLowerCase() != 'anonim';
      spans.add(
        TextSpan(
          text: match.group(0),
          style: isRealMention ? mentionStyle : null,
          recognizer: isRealMention && onMentionTap != null
              ? (TapGestureRecognizer()..onTap = () => onMentionTap!(username))
              : null,
        ),
      );
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return TextSpan(children: spans, style: baseStyle);
  }
}
