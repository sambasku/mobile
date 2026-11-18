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

/// Strip 1 baris di atas stream chat - minimal, bukan kartu tebal.
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
      // Jarak ke list chat; jarak ke tab ditangani parent (padding top).
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.secondary.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border.withValues(alpha: 0.7)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 6, 4),
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
    final theme = FTheme.of(context);
    return Row(
      children: [
        Icon(
          FLucideIcons.audioLines,
          size: 14,
          color: theme.colors.mutedForeground,
        ),
        const Gap(6),
        Expanded(
          child: Text(
            l10n.voiceStripOptInHint,
            style: theme.typography.body.xs2.copyWith(
              color: theme.colors.mutedForeground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOpenSettings,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              l10n.voiceStripOpenSettings,
              style: theme.typography.body.xs2.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.primary,
              ),
            ),
          ),
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
    final mutedFg = theme.colors.mutedForeground;

    final title = reconnecting
        ? l10n.voiceReconnecting
        : inSession
            ? l10n.voiceStripInRoom(room.participantCount)
            : l10n.voiceStripTitle;

    return Row(
      children: [
        Icon(
          inSession ? FLucideIcons.radio : FLucideIcons.audioLines,
          size: 14,
          color: inSession ? theme.colors.primary : mutedFg,
        ),
        const Gap(6),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: inSession ? onShowParticipants : null,
            child: Text(
              title,
              style: theme.typography.body.xs.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (inSession) ...[
          _IconAction(
            icon: FLucideIcons.users,
            semanticsLabel: l10n.voiceShowParticipants,
            onTap: onShowParticipants,
          ),
          _IconAction(
            icon: room.muted ? FLucideIcons.micOff : FLucideIcons.mic,
            semanticsLabel:
                room.muted ? l10n.voiceUnmute : l10n.voiceMute,
            onTap: busy || reconnecting ? null : onMute,
          ),
          _IconAction(
            icon: FLucideIcons.phoneOff,
            semanticsLabel: l10n.voiceLeave,
            color: theme.colors.destructive,
            onTap: busy ? null : onLeave,
          ),
        ] else
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: busy
                ? null
                : () {
                    if (!isAuth) {
                      onLogin();
                      return;
                    }
                    onJoin();
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: busy
                  ? const FCircularProgress(size: .xs)
                  : Text(
                      l10n.voiceJoin,
                      style: theme.typography.body.xs2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colors.primary,
                      ),
                    ),
            ),
          ),
      ],
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onTap;
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
          child: Icon(
            icon,
            size: 15,
            color: onTap == null
                ? theme.colors.mutedForeground.withValues(alpha: 0.4)
                : (color ?? theme.colors.foreground),
          ),
        ),
      ),
    );
  }
}
