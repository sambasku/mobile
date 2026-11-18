import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/voice_room_provider.dart';
import 'voice_participants_sheet.dart';

/// Mini bar global di atas bottom nav saat voice room terhubung.
/// Mute / keluar / daftar peserta tanpa harus kembali ke Chat.
class VoiceRoomMiniBar extends ConsumerWidget {
  const VoiceRoomMiniBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(voiceRoomProvider);
    if (!room.isInSession) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final colors = FTheme.of(context).colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.foreground.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => showVoiceParticipantsSheet(context),
                child: Row(
                  children: [
                    Icon(
                      FLucideIcons.radio,
                      size: 16,
                      color: colors.primary,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            room.phase == VoiceRoomPhase.reconnecting
                                ? l10n.voiceReconnecting
                                : l10n.voiceStripInRoom(room.participantCount),
                            style: FTheme.of(context).typography.body.sm
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            l10n.voiceShowParticipants,
                            style: FTheme.of(context).typography.body.xs2
                                .copyWith(color: colors.mutedForeground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      FLucideIcons.users,
                      size: 14,
                      color: colors.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
            const Gap(6),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () =>
                  ref.read(voiceRoomProvider.notifier).toggleMute(),
              prefix: Icon(
                room.muted ? FLucideIcons.micOff : FLucideIcons.mic,
                size: 14,
              ),
              child: Text(room.muted ? l10n.voiceUnmute : l10n.voiceMute),
            ),
            const Gap(6),
            FButton(
              variant: FButtonVariant.destructive,
              onPress: () => ref.read(voiceRoomProvider.notifier).leave(),
              child: Text(l10n.voiceLeave),
            ),
          ],
        ),
      ),
    );
  }
}
