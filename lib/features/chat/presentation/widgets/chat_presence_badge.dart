import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/chat_presence_provider.dart';

/// Indikator berapa orang sedang stay di layar Chat.
class ChatPresenceBadge extends ConsumerWidget {
  const ChatPresenceBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(chatPresenceCountProvider);
    if (count <= 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(8),
          Expanded(
            child: Text(
              l10n.chatPresenceCount(count),
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
