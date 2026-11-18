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

/// Strip compact di atas stream chat.
///
/// Gate: `voice_room_enabled` (API) ∧ opt-in SharedPreferences.
/// Backend OFF → sembunyi. ON + belum opt-in → ajakan ke Pengaturan.
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
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.secondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: optIn
              ? _ConnectedRow(
                  l10n: l10n,
                  room: room,
                  isAuth: isAuth,
                  onLogin: () => context.push('/login'),
                  onJoin: () => ref.read(voiceRoomProvider.notifier).join(l10n),
                  onLeave: () => ref.read(voiceRoomProvider.notifier).leave(),
                  onMute: () =>
                      ref.read(voiceRoomProvider.notifier).toggleMute(),
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
    return Row(
      children: [
        const Icon(FLucideIcons.audioLines, size: 16),
        const Gap(8),
        Expanded(
          child: Text(
            l10n.voiceStripOptInHint,
            style: FTheme.of(context).typography.body.sm,
          ),
        ),
        FButton(
          variant: FButtonVariant.outline,
          onPress: onOpenSettings,
          child: Text(l10n.voiceStripOpenSettings),
        ),
      ],
    );
  }
}

class _ConnectedRow extends StatelessWidget {
  const _ConnectedRow({
    required this.l10n,
    required this.room,
    required this.isAuth,
    required this.onLogin,
    required this.onJoin,
    required this.onLeave,
    required this.onMute,
  });

  final AppLocalizations l10n;
  final VoiceRoomState room;
  final bool isAuth;
  final VoidCallback onLogin;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onMute;

  @override
  Widget build(BuildContext context) {
    final busy = room.phase == VoiceRoomPhase.connecting;
    final connected = room.isConnected;

    return Row(
      children: [
        Icon(
          connected ? FLucideIcons.radio : FLucideIcons.audioLines,
          size: 16,
        ),
        const Gap(8),
        Expanded(
          child: Text(
            connected
                ? l10n.voiceStripInRoom(room.participantCount)
                : l10n.voiceStripTitle,
            style: FTheme.of(context).typography.body.sm,
          ),
        ),
        if (connected) ...[
          FButton(
            variant: FButtonVariant.outline,
            onPress: busy ? null : onMute,
            child: Text(
              room.muted ? l10n.voiceUnmute : l10n.voiceMute,
            ),
          ),
          const Gap(6),
          FButton(
            variant: FButtonVariant.destructive,
            onPress: busy ? null : onLeave,
            child: Text(l10n.voiceLeave),
          ),
        ] else
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
