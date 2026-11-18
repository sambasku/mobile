import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../../shared/widgets/thread_audio_player.dart';
import '../../domain/chat_models.dart';
import 'chat_sticker_view.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.mine,
    required this.onReply,
    this.onDelete,
    this.showName = true,
    this.showTime = true,
    this.clustered = false,
  });

  final ChatMessage message;
  final bool mine;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

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

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        child: GestureDetector(
          onLongPress: () => _showActions(context),
          child: Padding(
            padding: EdgeInsets.fromLTRB(4, clustered ? 1 : 3, 4, clustered ? 1 : 2),
            child: Column(
              crossAxisAlignment: align,
              children: [
                if (!mine && showName && name.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 1),
                    child: Text(
                      name,
                      style: theme.typography.body.xs2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                if (message.replyToId != null) ...[
                  _ReplyQuote(
                    username: message.replyUsername,
                    snippet: message.replySnippet,
                  ),
                  const Gap(2),
                ],
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: _BubbleBody(message: message, mine: mine),
                  ),
                ),
                if (showMeta) ...[
                  const Gap(1),
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
                        if (showTime && timeLabel.isNotEmpty)
                          Text(
                            timeLabel,
                            style: theme.typography.body.xs3.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        if (showEdited) ...[
                          if (showTime && timeLabel.isNotEmpty) const Gap(4),
                          Text(
                            l10n.chatEdited,
                            style: theme.typography.body.xs3.copyWith(
                              color: theme.colors.mutedForeground,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showActions(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
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
    if (action == 'delete') onDelete?.call();
  }
}

class _ReplyQuote extends StatelessWidget {
  const _ReplyQuote({this.username, this.snippet});

  final String? username;
  final String? snippet;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final handle = (username ?? '-').trim();
    final text = (snippet ?? '').trim().isEmpty
        ? l10n.chatTombstone
        : snippet!.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.colors.primary, width: 2)),
        color: theme.colors.secondary.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '@$handle: $text',
        style: theme.typography.body.xs2.copyWith(
          color: theme.colors.mutedForeground,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  const _BubbleBody({required this.message, required this.mine});

  final ChatMessage message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);

    if (message.isDeleted) {
      return Text(
        l10n.chatTombstone,
        style: theme.typography.body.xs.copyWith(
          fontStyle: FontStyle.italic,
          color: theme.colors.mutedForeground,
        ),
      );
    }

    switch (message.kind) {
      case ChatMessageKind.sticker:
        return ChatStickerView(
          stickerId: message.stickerId ?? '',
          size: 56,
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
        return ThreadAudioPlayer(
          url: url,
          audioId: 'chat-${message.id}',
          durationMs: message.durationMs,
          compact: true,
        );
      case ChatMessageKind.text:
        return Text(
          message.body ?? '',
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.foreground,
            height: 1.3,
          ),
        );
    }
  }
}
