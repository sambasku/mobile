import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/chat_ping_provider.dart';

/// Bottom sheet cooldown ping dengan timer live (detik).
Future<void> showChatPingCooldownSheet(BuildContext context) {
  final theme = FTheme.of(context);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: theme.colors.background,
    builder: (_) => const _ChatPingCooldownSheet(),
  );
}

class _ChatPingCooldownSheet extends ConsumerWidget {
  const _ChatPingCooldownSheet();

  static String _clock(AppLocalizations l10n, Duration rem) {
    final safe = rem.isNegative ? Duration.zero : rem;
    return l10n.chatPingCooldown(
      '${safe.inMinutes}',
      safe.inSeconds.remainder(60).toString().padLeft(2, '0'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final ping = ref.watch(chatPingProvider);
    final rem = ping.remaining.isNegative ? Duration.zero : ping.remaining;
    final ready = rem <= Duration.zero;
    final totalMs = (ping.cooldownSeconds <= 0 ? 300 : ping.cooldownSeconds) *
        1000;
    // Lingkaran = sisa waktu (penuh di awal, mengecil tiap detik).
    final remainingRatio =
        ready ? 0.0 : (rem.inMilliseconds / totalMs).clamp(0.0, 1.0);

    ref.listen(chatPingProvider.select((s) => s.remaining), (prev, next) {
      if (!context.mounted) return;
      if (next <= Duration.zero && (prev == null || prev > Duration.zero)) {
        Navigator.of(context).maybePop();
      }
    });

    final clock = _clock(l10n, rem);

    return Material(
      color: theme.colors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.chatPingCooldownTitle,
                textAlign: TextAlign.center,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(20),
              Center(
                child: SizedBox(
                  width: 148,
                  height: 148,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: ready
                              ? 0
                              : remainingRatio.clamp(0.02, 1.0),
                          strokeWidth: 8,
                          backgroundColor: theme.colors.secondary,
                          color: ready
                              ? const Color(0xFF16A34A)
                              : theme.colors.primary,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ready ? _clock(l10n, Duration.zero) : clock,
                            textAlign: TextAlign.center,
                            style: theme.typography.body.xl.copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: ready
                                  ? const Color(0xFF16A34A)
                                  : theme.colors.foreground,
                              height: 1.1,
                            ),
                          ),
                          const Gap(4),
                          Icon(
                            FLucideIcons.radio,
                            size: 18,
                            color: ready
                                ? const Color(0xFF16A34A)
                                : theme.colors.mutedForeground,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(20),
              Text(
                ready
                    ? l10n.chatPingCooldownReady
                    : l10n.chatPingCooldownSheetHint,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  height: 1.35,
                ),
              ),
              const Gap(16),
              FButton(
                onPress: () => Navigator.of(context).pop(),
                child: Text(l10n.infoSheetUnderstood),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
