import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/voice_room_provider.dart';

Future<void> showVoiceParticipantsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const _VoiceParticipantsSheet(),
  );
}

class _VoiceParticipantsSheet extends ConsumerWidget {
  const _VoiceParticipantsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final room = ref.watch(voiceRoomProvider);
    final theme = FTheme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.voiceParticipantsTitle(room.participantCount),
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (room.participants.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Text(
                l10n.voiceParticipantsEmpty,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.5,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: FTileGroup(
                  children: [
                    for (final p in room.participants)
                      FTile(
                        prefix: Icon(
                          p.muted ? FLucideIcons.micOff : FLucideIcons.mic,
                          size: 16,
                          color: p.speaking
                              ? theme.colors.primary
                              : theme.colors.mutedForeground,
                        ),
                        title: Text(
                          p.isLocal
                              ? l10n.voiceParticipantYou(p.name)
                              : p.name,
                        ),
                        subtitle: Text(
                          p.speaking
                              ? l10n.voiceParticipantSpeaking
                              : (p.muted
                                  ? l10n.voiceParticipantMuted
                                  : l10n.voiceParticipantListening),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
