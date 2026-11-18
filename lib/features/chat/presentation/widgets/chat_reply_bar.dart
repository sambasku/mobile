import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/chat_models.dart';

class ChatReplyBar extends StatelessWidget {
  const ChatReplyBar({super.key, required this.target, required this.onClear});

  final ChatMessage target;
  final VoidCallback onClear;

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
            ChatMessageKind.text => (target.body ?? '').trim(),
          };

    return Material(
      color: theme.colors.secondary.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chatReplyBar(handle),
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    snippet.isEmpty ? l10n.chatTombstone : snippet,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
    );
  }
}
