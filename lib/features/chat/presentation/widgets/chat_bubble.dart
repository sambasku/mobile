import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/thread_audio_player.dart';
import '../../../../shared/widgets/thread_message.dart';
import '../../../user_profile/user_profile_router.dart';
import '../../domain/chat_models.dart';
import 'chat_sticker_view.dart';
import 'chat_swipe_reply.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.mine,
    required this.onReply,
    this.onDelete,
    this.onJumpToReply,
    this.highlighted = false,
    this.replyingTo = false,
    this.showName = true,
    this.showTime = true,
    this.clustered = false,
  });

  final ChatMessage message;
  final bool mine;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final VoidCallback? onJumpToReply;

  /// Bingkai singkat setelah loncat dari quote reply.
  final bool highlighted;

  /// Pesan ini sedang jadi target balas (swipe / long-press reply).
  final bool replyingTo;

  /// Nama pengirim: hanya di pesan pertama grup beruntun.
  final bool showName;

  /// Jam: hanya di pesan terakhir grup (orang sama + menit sama).
  final bool showTime;

  /// Pesan tengah grup: padding vertikal lebih rapat.
  final bool clustered;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final created = DateTime.tryParse(message.createdAt);
    final timeLabel = created == null ? '' : formatClockLocal(created);
    final name = displayPublicAccountLabel(
      displayName: message.displayName,
      username: message.username,
    );

    final align = mine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = mine
        ? theme.colors.primary.withValues(alpha: 0.12)
        : theme.colors.secondary.withValues(alpha: 0.65);
    final showEdited = message.isEdited && !message.isDeleted;
    final showMeta =
        message.pending || (showTime && timeLabel.isNotEmpty) || showEdited;
    final frameBubble = highlighted || replyingTo;
    // Player & stiker tanpa reply tampil bare tanpa kotak bubble luar.
    final bareVoice =
        !message.isDeleted &&
        message.kind == ChatMessageKind.voiceNote &&
        (message.audioUrl?.trim().isNotEmpty ?? false);
    final bareSticker =
        !message.isDeleted &&
        message.kind == ChatMessageKind.sticker &&
        message.replyToId == null;
    final bareContainer = bareVoice || bareSticker;
    final bubbleBody = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.replyToId != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: _ReplyQuote(
              username: message.replyUsername,
              snippet: message.replySnippet,
              onTap: onJumpToReply,
            ),
          ),
          const Gap(4),
        ],
        Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: _BubbleBody(
            message: message,
          ),
        ),
        if (showMeta) ...[
          const Gap(2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.pending) ...[
                Text(
                  l10n.chatSending,
                  style: theme.typography.body.xs3.copyWith(
                    color: theme.colors.mutedForeground,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Gap(4),
                const FCircularProgress(size: .xs),
              ] else ...[
                if (showEdited) ...[
                  Text(
                    l10n.chatEdited,
                    style: theme.typography.body.xs3.copyWith(
                      color: theme.colors.mutedForeground,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (showTime && timeLabel.isNotEmpty) const Gap(4),
                ],
                if (showTime && timeLabel.isNotEmpty)
                  Text(
                    timeLabel,
                    style: theme.typography.body.xs3.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ],
    );

    final swipeReply = !message.pending &&
        !message.isDeleted &&
        message.kind != ChatMessageKind.system;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: ChatSwipeReply(
          enabled: swipeReply,
          onReply: onReply,
          child: GestureDetector(
            onLongPress: () => _showActions(context),
            child: Padding(
            padding: EdgeInsets.fromLTRB(
              2,
              // clustered = run beruntun: rapat tapi masih ada napas
              clustered ? 2 : 5,
              2,
              clustered ? 2 : 4,
            ),
            child: Column(
              crossAxisAlignment: align,
              children: [
                if (!mine && showName && name.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 1),
                    child: Text(
                      name,
                      style: theme.typography.body.xs3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: DecoratedBox(
                    decoration: frameBubble
                        ? BoxDecoration(
                            color: replyingTo
                                ? theme.colors.primary.withValues(alpha: 0.08)
                                : null,
                            border: Border.all(
                              color: theme.colors.primary,
                              width: 1.5,
                            ),
                          )
                        : const BoxDecoration(),
                    child: bareContainer
                        ? bubbleBody
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              color: bubbleColor,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
                              child: bubbleBody,
                            ),
                          ),
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

  String? _textToCopy(AppLocalizations l10n) {
    if (message.pending || message.isDeleted) return null;
    return switch (message.kind) {
      ChatMessageKind.text || ChatMessageKind.system => () {
          final t = (message.body ?? '').trim();
          return t.isEmpty ? null : t;
        }(),
      ChatMessageKind.sticker => l10n.chatReplySnippetSticker,
      ChatMessageKind.voiceNote => l10n.chatReplySnippetVoice,
    };
  }

  Future<void> _showActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final copyText = _textToCopy(l10n);
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: MediaQuery.of(sheetContext).viewInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FTileGroup(
                children: [
                  FTile(
                    title: Text(l10n.chatLongPressReply),
                    onPress: () => Navigator.pop(sheetContext, 'reply'),
                  ),
                  if (copyText != null)
                    FTile(
                      title: Text(l10n.chatLongPressCopy),
                      onPress: () => Navigator.pop(sheetContext, 'copy'),
                    ),
                  if (onDelete != null &&
                      !message.pending &&
                      !message.isDeleted)
                    FTile(
                      title: Text(l10n.chatLongPressDelete),
                      onPress: () => Navigator.pop(sheetContext, 'delete'),
                    ),
                  FTile(
                    title: Text(l10n.commonCancel),
                    onPress: () => Navigator.pop(sheetContext),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (!context.mounted) return;
    if (action == 'reply') onReply();
    if (action == 'copy' && copyText != null) {
      await Clipboard.setData(ClipboardData(text: copyText));
      if (!context.mounted) return;
      showFToast(
        context: context,
        title: Text(l10n.chatMessageCopied),
      );
    }
    if (action == 'delete') onDelete?.call();
  }
}

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({this.username, this.snippet, this.onTap});

  final String? username;
  final String? snippet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final handle = (username ?? '-').trim();
    final text = (snippet ?? '').trim().isEmpty
        ? l10n.chatTombstone
        : snippet!.trim();
    return Semantics(
      button: onTap != null,
      hint: onTap == null ? null : l10n.chatReplyJumpSemantics,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.primary.withValues(alpha: 0.14),
              border: Border(
                left: BorderSide(color: theme.colors.primary, width: 3),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            // softWrap false: ikut lebar teks, jangan tarik bubble ke max.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '@$handle',
                  softWrap: false,
                  style: theme.typography.body.xs2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  text,
                  softWrap: false,
                  style: theme.typography.body.xs2.copyWith(
                    color: theme.colors.foreground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

class _BubbleBody extends StatelessWidget {
  const _BubbleBody({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);

    if (message.isDeleted) {
      return Text(
        l10n.chatTombstone,
        style: theme.typography.body.xs2.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colors.mutedForeground,
        ),
      );
    }

    switch (message.kind) {
      case ChatMessageKind.sticker:
        return ChatStickerView(
          stickerId: message.stickerId ?? '',
          size: 110,
          tappable: !message.pending && !message.isDeleted,
        );
      case ChatMessageKind.voiceNote:
        final url = message.audioUrl?.trim() ?? '';
        if (url.isEmpty) {
          return Text(
            l10n.chatSending,
            style: theme.typography.body.xs2.copyWith(
              color: theme.colors.mutedForeground,
              fontStyle: FontStyle.italic,
            ),
          );
        }
        // Compact = visual sama AudioPlayerTile pelafalan lemma (bukan tint bubble).
        return ThreadAudioPlayer(
          url: url,
          audioId: 'chat-${message.id}',
          durationMs: message.durationMs,
          compact: true,
        );
      case ChatMessageKind.system:
        // System line punya widget sendiri; fallback kalau ketiban bubble.
        return Text(
          message.body ?? '',
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        );
      case ChatMessageKind.text:
        return MentionBodyText(
          body: message.body ?? '',
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.foreground,
            height: 1.25,
          ),
          onMentionTap: (username) =>
              UserProfileRouter.open(context, username),
        );
    }
  }
}
