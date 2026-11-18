import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../chat/data/chat_providers.dart';
import '../../../settings/settings_router.dart';
import '../providers/voice_opt_in_provider.dart';
import '../providers/voice_room_provider.dart';
import 'voice_participants_sheet.dart';

/// Strip compact di atas stream chat (bukan floating overlay).
///
/// Gate: `voice_room_enabled` (API) ∧ opt-in SharedPreferences.
class VoiceRoomStrip extends ConsumerWidget {
  const VoiceRoomStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final caps = ref.watch(chatCapabilitiesProvider).asData?.value;
    if (caps == null || !caps.voiceRoomEnabled) {
      return const SizedBox.shrink();
    }

    final optIn = ref.watch(voiceRoomOptInProvider);
    final room = ref.watch(voiceRoomProvider);
    final auth = ref.watch(authStatusProvider).value;
    final isAuth = auth?.isAuth ?? false;

    ref.listen(voiceRoomProvider.select((s) => s.errorMessage), (_, msg) {
      if (msg == null || !context.mounted) return;
      showAppErrorSheet(context, message: msg).whenComplete(() {
        if (context.mounted) ref.read(voiceRoomProvider.notifier).clearError();
      });
    });

    final colors = FTheme.of(context).colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: optIn
              ? _ActiveStrip(
                  l10n: l10n,
                  room: room,
                  isAuth: isAuth,
                  onLogin: () => context.push('/login'),
                  onJoin: () => ref.read(voiceRoomProvider.notifier).join(l10n),
                  onLeave: () => ref.read(voiceRoomProvider.notifier).leave(),
                  onMute: () =>
                      ref.read(voiceRoomProvider.notifier).toggleMute(),
                  onShowParticipants: () =>
                      showVoiceParticipantsSheet(context),
                )
              : _OptInHint(
                  l10n: l10n,
                  onOpenSettings: () =>
                      context.push(SettingsRouter.root.path),
                ),
        ),
      ),
    );
  }
}

class _OptInHint extends StatelessWidget {
  const _OptInHint({required this.l10n, required this.onOpenSettings});

  final AppLocalizations l10n;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(FLucideIcons.audioLines, size: 16),
            const Gap(8),
            Expanded(
              child: Text(
                l10n.voiceStripOptInHint,
                style: FTheme.of(context).typography.body.xs,
              ),
            ),
          ],
        ),
        const Gap(8),
        FButton(
          variant: FButtonVariant.outline,
          onPress: onOpenSettings,
          child: Text(l10n.voiceStripOpenSettings),
        ),
      ],
    );
  }
}

class _ActiveStrip extends StatelessWidget {
  const _ActiveStrip({
    required this.l10n,
    required this.room,
    required this.isAuth,
    required this.onLogin,
    required this.onJoin,
    required this.onLeave,
    required this.onMute,
    required this.onShowParticipants,
  });

  final AppLocalizations l10n;
  final VoiceRoomState room;
  final bool isAuth;
  final VoidCallback onLogin;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onMute;
  final VoidCallback onShowParticipants;

  @override
  Widget build(BuildContext context) {
    final busy = room.phase == VoiceRoomPhase.connecting;
    final inSession = room.isInSession;
    final reconnecting = room.phase == VoiceRoomPhase.reconnecting;
    final theme = FTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: inSession ? onShowParticipants : null,
          child: Row(
            children: [
              Icon(
                inSession ? FLucideIcons.radio : FLucideIcons.audioLines,
                size: 16,
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  reconnecting
                      ? l10n.voiceReconnecting
                      : inSession
                          ? l10n.voiceStripInRoom(room.participantCount)
                          : l10n.voiceStripTitle,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (inSession)
                Icon(
                  FLucideIcons.users,
                  size: 14,
                  color: theme.colors.mutedForeground,
                ),
            ],
          ),
        ),
        if (inSession && room.participants.isNotEmpty) ...[
          const Gap(6),
          Text(
            room.participants
                .take(3)
                .map((p) => p.isLocal ? l10n.voiceParticipantYou(p.name) : p.name)
                .join(', '),
            style: theme.typography.body.xs2.copyWith(
              color: theme.colors.mutedForeground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const Gap(8),
        if (inSession)
          Row(
            children: [
              Expanded(
                child: FButton(
                  variant: FButtonVariant.outline,
                  onPress: busy || reconnecting ? null : onMute,
                  prefix: Icon(
                    room.muted ? FLucideIcons.micOff : FLucideIcons.mic,
                    size: 14,
                  ),
                  child: Text(
                    room.muted ? l10n.voiceUnmute : l10n.voiceMute,
                  ),
                ),
              ),
              const Gap(8),
              Expanded(
                child: FButton(
                  variant: FButtonVariant.destructive,
                  onPress: busy ? null : onLeave,
                  child: Text(l10n.voiceLeave),
                ),
              ),
            ],
          )
        else
          FButton(
            onPress: busy
                ? null
                : () {
                    if (!isAuth) {
                      onLogin();
                      return;
                    }
                    onJoin();
                  },
            prefix: busy ? const FCircularProgress(size: .sm) : null,
            child: Text(busy ? l10n.voiceJoining : l10n.voiceJoin),
          ),
      ],
    );
  }
}
