import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../chat/data/chat_providers.dart';
import '../../../voice/presentation/providers/voice_opt_in_provider.dart';
import '../../../voice/presentation/providers/voice_room_provider.dart';

/// Toggle opt-in voice room. Hanya tampil jika backend `voice_room_enabled`.
class VoiceOptInSection extends ConsumerWidget {
  const VoiceOptInSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final caps = ref.watch(chatCapabilitiesProvider).asData?.value;
    if (caps == null || !caps.voiceRoomEnabled) {
      return const SizedBox.shrink();
    }

    final optIn = ref.watch(voiceRoomOptInProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(8),
        FTileGroup(
          label: Text(l10n.settingsGroupExperiments),
          children: [
            FTile(
              prefix: const Icon(FLucideIcons.audioLines, size: 18),
              title: Text(l10n.settingsVoiceRoomOptIn),
              subtitle: Text(l10n.settingsVoiceRoomOptInSubtitle),
              suffix: FSwitch(
                value: optIn,
                onChange: (v) async {
                  await ref.read(voiceRoomOptInProvider.notifier).setOptIn(v);
                  if (!v) {
                    await ref.read(voiceRoomProvider.notifier).leave();
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
