import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../core/utils/format_datetime.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../domain/chat_models.dart';

/// Baris system di tengah timeline (voice join/leave, ping, dll).
/// Pola interaktif: `[ikon] displayName : aksi` - ping dapat styling khusus.
class ChatSystemLine extends StatelessWidget {
  const ChatSystemLine({
    super.key,
    required this.message,
    this.showTime = true,
  });

  final ChatMessage message;
  final bool showTime;

  static const _pingGreen = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final name = displayPublicAccountLabel(
      displayName: message.displayName,
      username: message.username,
    );
    final body = (message.body ?? '').trim();
    final kind = _systemKindFromBody(body);
    final action = switch (kind) {
      _SystemKind.ping => kChatPingBody,
      _SystemKind.voiceJoin => l10n.chatSystemVoiceJoinAction,
      _SystemKind.voiceLeave => l10n.chatSystemVoiceLeaveAction,
      _SystemKind.other => body,
    };
    final icon = switch (kind) {
      _SystemKind.ping => FLucideIcons.radio,
      _SystemKind.voiceJoin => FLucideIcons.mic,
      _SystemKind.voiceLeave => FLucideIcons.micOff,
      _SystemKind.other => FLucideIcons.info,
    };
    final iconColor = switch (kind) {
      _SystemKind.ping => _pingGreen,
      _SystemKind.voiceJoin => theme.colors.primary,
      _SystemKind.voiceLeave => theme.colors.mutedForeground,
      _SystemKind.other => theme.colors.mutedForeground,
    };
    final nameStyle = theme.typography.body.xs.copyWith(
      color: theme.colors.foreground,
      fontWeight: FontWeight.w600,
    );
    final colonStyle = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    final actionStyle = switch (kind) {
      _SystemKind.ping => theme.typography.body.xs.copyWith(
          color: _pingGreen,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      _SystemKind.voiceJoin => theme.typography.body.xs.copyWith(
          color: theme.colors.primary,
          fontWeight: FontWeight.w600,
        ),
      _SystemKind.voiceLeave => theme.typography.body.xs.copyWith(
          color: theme.colors.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      _SystemKind.other => theme.typography.body.xs.copyWith(
          color: theme.colors.mutedForeground,
        ),
    };

    final created = DateTime.tryParse(message.createdAt);
    final timeLabel = created == null ? '' : formatClockLocal(created);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: iconColor),
              const Gap(5),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: name, style: nameStyle),
                      if (action.isNotEmpty) ...[
                        TextSpan(text: ' : ', style: colonStyle),
                        TextSpan(text: action, style: actionStyle),
                      ],
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (showTime && timeLabel.isNotEmpty) ...[
            const Gap(2),
            Text(
              timeLabel,
              textAlign: TextAlign.center,
              style: theme.typography.body.xs3.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum _SystemKind { ping, voiceJoin, voiceLeave, other }

_SystemKind _systemKindFromBody(String body) {
  if (body == kChatPingBody) return _SystemKind.ping;
  if (body == kChatVoiceJoinBody) return _SystemKind.voiceJoin;
  if (body == kChatVoiceLeaveBody) return _SystemKind.voiceLeave;
  return _SystemKind.other;
}
