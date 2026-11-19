import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

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
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.voiceParticipantsTitle(room.participantCount),
                style: theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (room.participants.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
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
                maxHeight: MediaQuery.sizeOf(context).height * 0.42,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                itemCount: room.participants.length,
                separatorBuilder: (_, _) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final p = room.participants[index];
                  return _ParticipantRow(participant: p, l10n: l10n);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({required this.participant, required this.l10n});

  final VoiceRoomParticipant participant;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final p = participant;
    final status = p.speaking
        ? l10n.voiceParticipantSpeaking
        : (p.muted
            ? l10n.voiceParticipantMuted
            : l10n.voiceParticipantListening);
    final iconColor = p.speaking
        ? theme.colors.primary
        : theme.colors.mutedForeground;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: Row(
        children: [
          Icon(
            p.muted ? FLucideIcons.micOff : FLucideIcons.mic,
            size: 14,
            color: iconColor,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              p.isLocal ? l10n.voiceParticipantYou(p.name) : p.name,
              style: theme.typography.body.sm.copyWith(
                fontWeight: p.speaking ? FontWeight.w600 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(8),
          Text(
            status,
            style: theme.typography.body.xs2.copyWith(
              color: p.speaking
                  ? theme.colors.primary
                  : theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
