import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/header_action_icon.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/info_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../providers/chat_ping_provider.dart';

/// Aksi Ping di header: ikon radio hijau siap / abu cooldown (tanpa label).
class ChatPingAction extends ConsumerWidget {
  const ChatPingAction({super.key});

  static const _pingGreen = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStatusProvider).value;
    final loggedIn = auth?.userId != null && auth!.userId!.trim().isNotEmpty;
    if (!loggedIn) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final ping = ref.watch(chatPingProvider);

    ref.listen(chatPingProvider.select((s) => s.errorMessage), (_, msg) {
      if (msg == null || !context.mounted) return;
      final code = ref.read(chatPingProvider).errorCode;
      if (code == 'RATE_LIMITED') {
        showFToast(context: context, title: Text(msg));
      } else {
        showAppErrorSheet(context, message: msg);
      }
      ref.read(chatPingProvider.notifier).clearError();
    });

    final rem = ping.remaining;
    final ready = ping.isReady;
    final color = ready ? _pingGreen : theme.colors.mutedForeground;
    final cooldownClock = rem <= Duration.zero
        ? null
        : l10n.chatPingCooldown(
            '${rem.inMinutes}',
            rem.inSeconds.remainder(60).toString().padLeft(2, '0'),
          );
    final semantics = ready
        ? l10n.chatPingAction
        : (cooldownClock == null
              ? l10n.chatPingAction
              : l10n.chatPingCooldownSemantics(cooldownClock));

    return FHeaderAction(
      semanticsLabel: semantics,
      icon: Icon(
        FLucideIcons.radio,
        size: kHeaderActionIconSize,
        color: color,
      ),
      onPress: ping.sending
          ? null
          : () async {
              if (!ready) {
                if (!context.mounted) return;
                await showAppInfoSheet(
                  context,
                  title: l10n.chatPingCooldownTitle,
                  message: cooldownClock == null
                      ? l10n.chatPingCooldownBodyGeneric
                      : l10n.chatPingCooldownBody(cooldownClock),
                );
                return;
              }
              final ok = await ref.read(chatPingProvider.notifier).send();
              if (ok && context.mounted) {
                showFToast(
                  context: context,
                  title: Text(l10n.chatPingSent),
                );
              }
            },
    );
  }
}
