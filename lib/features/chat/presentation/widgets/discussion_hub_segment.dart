import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';

/// Segment Ruang Diskusi | Chat di bawah header hub Diskusi.
class DiscussionHubSegment extends StatelessWidget {
  const DiscussionHubSegment({
    super.key,
    required this.index,
    required this.onChanged,
  });

  /// 0 = Ruang Diskusi, 1 = Chat.
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Row(
        children: [
          Expanded(
            child: FButton(
              variant: index == 0
                  ? FButtonVariant.primary
                  : FButtonVariant.outline,
              onPress: () => onChanged(0),
              child: Text(l10n.discussionTabRooms),
            ),
          ),
          const Gap(8),
          Expanded(
            child: FButton(
              variant: index == 1
                  ? FButtonVariant.primary
                  : FButtonVariant.outline,
              onPress: () => onChanged(1),
              child: Text(l10n.discussionTabChat),
            ),
          ),
        ],
      ),
    );
  }
}
