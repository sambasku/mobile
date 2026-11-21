import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/chat_models.dart';

class ChatReplyBar extends StatelessWidget {
  const ChatReplyBar({
    super.key,
    required this.target,
    required this.onClear,
    required this.onJump,
  });

  final ChatMessage target;
  final VoidCallback onClear;
  final VoidCallback onJump;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final handle = (target.username ?? target.displayName ?? '-').trim();
    final snippet = target.isDeleted
        ? l10n.chatTombstone
        : switch (target.kind) {
            ChatMessageKind.sticker => l10n.chatReplySnippetSticker,
            ChatMessageKind.voiceNote => l10n.chatReplySnippetVoice,
            ChatMessageKind.system => l10n.chatReplySnippetSystem,
            ChatMessageKind.text => (target.body ?? '').trim(),
          };

    // Pola & clip sama [ThreadReplyBanner] (komentar lemma).
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.secondary,
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
              child: Semantics(
                button: true,
                hint: l10n.chatReplyJumpSemantics,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onJump,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chatReplyBar(handle),
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        snippet.isEmpty ? l10n.chatTombstone : snippet,
                        style: theme.typography.body.xs.copyWith(
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
            FButton.icon(
              variant: FButtonVariant.ghost,
              onPress: onClear,
              child: Icon(
                FLucideIcons.x,
                size: 16,
                semanticLabel: l10n.chatReplyCancelSemantics,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
