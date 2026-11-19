import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/voice_room_provider.dart';
import 'voice_participants_sheet.dart';

/// Mini bar global di atas bottom nav - gaya sama strip chat (1 baris padat).
class VoiceRoomMiniBar extends ConsumerWidget {
  const VoiceRoomMiniBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(voiceRoomProvider);
    if (!room.isInSession) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final colors = theme.colors;
    final reconnecting = room.phase == VoiceRoomPhase.reconnecting;
    final incoming = room.hasIncomingVoice;
    final micSending = room.isMicSending;
    final speaker = room.incomingSpeakerName;

    final title = reconnecting
        ? l10n.voiceReconnecting
        : incoming && speaker != null
            ? l10n.voiceStripHearing(speaker)
            : l10n.voiceStripInRoom(room.participantCount);

    // Capture notifier sebelum aksi async/tap (aman setelah rebuild).
    final voice = ref.read(voiceRoomProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 6, 4),
        child: SizedBox(
          height: 28,
          child: Row(
            children: [
              Icon(
                FLucideIcons.radio,
                size: 14,
                color: colors.primary,
              ),
              const Gap(6),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => showVoiceParticipantsSheet(context),
                  child: Text(
                    title,
                    style: theme.typography.body.xs.copyWith(
                      fontWeight: FontWeight.w600,
                      color: incoming ? colors.primary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              _MiniIcon(
                icon: FLucideIcons.users,
                semanticsLabel: l10n.voiceShowParticipants,
                onTap: () => showVoiceParticipantsSheet(context),
              ),
              if (incoming)
                Semantics(
                  label: l10n.voiceStripIncomingHint,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      FLucideIcons.volume2,
                      size: 13,
                      color: colors.primary,
                    ),
                  ),
                ),
              _MiniMic(
                muted: room.muted,
                sending: micSending,
                muteLabel: l10n.voiceMute,
                unmuteLabel: l10n.voiceUnmute,
                sendingLabel: l10n.voiceStripMicSending,
                onTap: reconnecting ? null : voice.toggleMute,
              ),
              _MiniIcon(
                icon: FLucideIcons.phoneOff,
                semanticsLabel: l10n.voiceLeave,
                color: colors.destructive,
                onTap: () {
                  // ignore: discarded_futures
                  voice.leave();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniIcon extends StatelessWidget {
  const _MiniIcon({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            icon,
            size: 15,
            color: color ?? theme.colors.foreground,
          ),
        ),
      ),
    );
  }
}

class _MiniMic extends StatelessWidget {
  const _MiniMic({
    required this.muted,
    required this.sending,
    required this.muteLabel,
    required this.unmuteLabel,
    required this.sendingLabel,
    required this.onTap,
  });

  final bool muted;
  final bool sending;
  final String muteLabel;
  final String unmuteLabel;
  final String sendingLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final disabled = onTap == null;
    final live = sending && !muted;
    final Color iconColor;
    if (disabled) {
      iconColor = theme.colors.mutedForeground.withValues(alpha: 0.4);
    } else if (muted) {
      iconColor = theme.colors.mutedForeground;
    } else if (live) {
      iconColor = theme.colors.primary;
    } else {
      iconColor = theme.colors.foreground;
    }

    return Semantics(
      button: true,
      label: muted ? unmuteLabel : (live ? sendingLabel : muteLabel),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: live
                  ? theme.colors.primary.withValues(alpha: 0.18)
                  : null,
              shape: BoxShape.circle,
              border: Border.all(
                color: live
                    ? theme.colors.primary.withValues(alpha: 0.7)
                    : const Color(0x00000000),
                width: 1,
              ),
            ),
            child: Icon(
              muted ? FLucideIcons.micOff : FLucideIcons.mic,
              size: 15,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
