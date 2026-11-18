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
