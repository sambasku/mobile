import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/chat_typing_provider.dart';

/// Indikator "{name} mengetik…" di baris atas composer (sejajar counter).
class ChatTypingIndicator extends ConsumerWidget {
  const ChatTypingIndicator({super.key});

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typers = ref.watch(chatTypingProvider);
    if (typers.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = FTheme.of(context);
    final label = switch (typers.length) {
      1 => l10n.chatTypingOne(typers.first.name),
      2 => l10n.chatTypingTwo(typers[0].name, typers[1].name),
      _ => l10n.chatTypingMany(typers.length),
    };

    return Text(
      label,
      style: theme.typography.body.xs3.copyWith(
        color: _green,
        fontWeight: FontWeight.w600,
        height: 1.1,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
