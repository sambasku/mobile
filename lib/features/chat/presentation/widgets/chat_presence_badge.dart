import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/chat_presence_provider.dart';

/// Indikator berapa orang sedang stay di layar Chat (satu baris tipis).
class ChatPresenceBadge extends ConsumerWidget {
  const ChatPresenceBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(chatPresenceCountProvider);
    if (count <= 0) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(6),
          Expanded(
            child: Text(
              l10n.chatPresenceCount(count),
              style: theme.typography.body.xs2.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
