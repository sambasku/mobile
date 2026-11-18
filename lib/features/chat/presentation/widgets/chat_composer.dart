import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/chat_models.dart';
import 'chat_reply_bar.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.enabled,
    required this.sending,
    required this.replyTarget,
    required this.onClearReply,
    required this.onSendText,
    required this.onOpenStickers,
    required this.onRecordVoice,
    required this.onLoginPrompt,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool sending;
  final ChatMessage? replyTarget;
  final VoidCallback onClearReply;
  final VoidCallback onSendText;
  final VoidCallback onOpenStickers;
  final VoidCallback onRecordVoice;
  final VoidCallback onLoginPrompt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (replyTarget != null)
          ChatReplyBar(target: replyTarget!, onClear: onClearReply),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  onPress: sending
                      ? null
                      : () {
                          if (!enabled) {
                            onLoginPrompt();
                            return;
                          }
                          onOpenStickers();
                        },
                  child: Icon(
                    FLucideIcons.smile,
                    size: 20,
                    semanticLabel: l10n.chatStickerSemantics,
                  ),
                ),
                FButton.icon(
                  variant: FButtonVariant.ghost,
                  onPress: sending
                      ? null
                      : () {
                          if (!enabled) {
                            onLoginPrompt();
                            return;
                          }
                          onRecordVoice();
                        },
                  child: Icon(
                    FLucideIcons.mic,
                    size: 20,
                    semanticLabel: l10n.chatMicSemantics,
                  ),
                ),
                const Gap(4),
                Expanded(
                  child: FTextField(
                    control: FTextFieldControl.managed(controller: controller),
                    hint: l10n.chatComposerHint,
                    maxLines: 4,
                    minLines: 1,
                    enabled: enabled && !sending,
                    onSubmit: (_) {
                      if (!enabled) {
                        onLoginPrompt();
                        return;
                      }
                      onSendText();
                    },
                  ),
                ),
                const Gap(8),
                FButton(
                  onPress: sending
                      ? null
                      : () {
                          if (!enabled) {
                            onLoginPrompt();
                            return;
                          }
                          onSendText();
                        },
                  prefix: sending ? const FCircularProgress() : null,
                  child: Text(l10n.chatSend),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
