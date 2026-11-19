import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import '../../../../l10n/app_localizations.dart';

class ChatNewMessagesChip extends StatelessWidget {
  const ChatNewMessagesChip({
    super.key,
    required this.count,
    required this.onPress,
  });

  final int count;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: FButton(
        onPress: onPress,
        child: Text(l10n.chatNewMessages(count)),
      ),
    );
  }
}

/// Tombol bulat kecil: kembali ke pesan terakhir saat daftar digulir ke atas.
class ChatScrollToBottomButton extends StatelessWidget {
  const ChatScrollToBottomButton({super.key, required this.onPress});

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: l10n.chatScrollToLatest,
      child: Material(
        color: theme.colors.secondary,
        elevation: 1,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPress,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              FLucideIcons.chevronDown,
              size: 16,
              color: theme.colors.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
