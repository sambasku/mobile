import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/chat_limits.dart';
import '../../domain/chat_models.dart';
import 'chat_reply_bar.dart';
import 'chat_typing_indicator.dart';

/// Composer chat - layout mengikuti [ThreadComposer] (komentar lemma):
/// icon aksi di atas, field multiline + tombol kirim bulat.
///
/// Dipasang di **body** Column (bukan [FScaffold.footer]): footer Forui
/// menaruh anak di bottom absolut sehingga tertutup keyboard.
class ChatComposer extends HookWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.enabled,
    required this.sending,
    required this.replyTarget,
    required this.onClearReply,
    required this.onJumpToReply,
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
  final VoidCallback onJumpToReply;
  final VoidCallback onSendText;
  final VoidCallback onOpenStickers;
  final VoidCallback onRecordVoice;
  final VoidCallback onLoginPrompt;

  void _guarded(VoidCallback action) {
    if (!enabled) {
      onLoginPrompt();
      return;
    }
    action();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    useListenable(controller);
    final length = controller.text.characters.length;

    final countStyle = theme.typography.body.xs3.copyWith(
      color: length >= kChatBodyCountWarnAt
          ? theme.colors.destructive
          : theme.colors.mutedForeground,
    );

    return Material(
      color: theme.colors.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (replyTarget != null) ...[
                ChatReplyBar(
                  target: replyTarget!,
                  onClear: onClearReply,
                  onJump: onJumpToReply,
                ),
                const Gap(6),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ComposerIconButton(
                    icon: FLucideIcons.smile,
                    semanticsLabel: l10n.chatStickerSemantics,
                    enabled: !sending,
                    onTap: () => _guarded(onOpenStickers),
                  ),
                  _ComposerIconButton(
                    icon: FLucideIcons.mic,
                    semanticsLabel: l10n.chatMicSemantics,
                    enabled: !sending,
                    onTap: () => _guarded(onRecordVoice),
                  ),
                  const Gap(4),
                  const Expanded(child: ChatTypingIndicator()),
                ],
              ),
              const Gap(4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: FTextField(
                      control: FTextFieldControl.managed(
                        controller: controller,
                      ),
                      hint: l10n.chatComposerHint,
                      enabled: enabled && !sending,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: 3,
                      minLines: 1,
                      maxLength: kChatBodyMax,
                      style: FTextFieldStyleDelta.delta(
                        contentPadding: EdgeInsetsGeometryDelta.value(
                          const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 22),
                        ),
                      ),
                      builder: (context, style, _, field) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          field,
                          PositionedDirectional(
                            end: 8,
                            bottom: 4,
                            child: IgnorePointer(
                              child: Semantics(
                                label: l10n.chatComposerCharCount(
                                  length,
                                  kChatBodyMax,
                                ),
                                child: Text(
                                  l10n.chatComposerCharCount(
                                    length,
                                    kChatBodyMax,
                                  ),
                                  style: countStyle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(6),
                  Semantics(
                    button: true,
                    label: l10n.chatSend,
                    child: Material(
                      color: sending
                          ? theme.colors.primary.withValues(alpha: 0.5)
                          : theme.colors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: sending ? null : () => _guarded(onSendText),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: Center(
                            child: sending
                                ? const FCircularProgress(size: .xs)
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
          ),
        ),
      ),
    );
  }
}

class _ComposerIconButton extends StatelessWidget {
  const _ComposerIconButton({
    required this.icon,
    required this.semanticsLabel,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
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
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 18,
              color: enabled
                  ? theme.colors.mutedForeground
                  : theme.colors.mutedForeground.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}