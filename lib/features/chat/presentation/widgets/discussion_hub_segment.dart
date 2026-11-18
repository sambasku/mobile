import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Tab bar hub Diskusi - visual [FTabs] Forui (sama Tentang / Baleho).
///
/// Konten di [DiscussionHubShell] via `StatefulNavigationShell`; di sini
/// hanya chrome tab supaya tidak dobel scaffold.
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
    final theme = context.theme;

    return FTabs(
      expands: false,
      // Hub hanya pakai chrome tab; konten di parent - hilangkan jarak
      // default 10px antara tab bar dan child shrink.
      style: .delta(spacing: 0),
      control: .lifted(index: index, onChange: onChanged),
      children: [
        FTabEntry.entry(
          label: _HubTabLabel(
            icon: FLucideIcons.messagesSquare,
            text: l10n.discussionTabRooms,
            selected: index == 0,
            theme: theme,
          ),
          child: const SizedBox.shrink(),
        ),
        FTabEntry.entry(
          label: _HubTabLabel(
            icon: FLucideIcons.messageCircle,
            text: l10n.discussionTabChat,
            selected: index == 1,
            theme: theme,
          ),
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _HubTabLabel extends StatelessWidget {
  const _HubTabLabel({
    required this.icon,
    required this.text,
    required this.selected,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final bool selected;
  final FThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? theme.colors.foreground
        : theme.colors.mutedForeground;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const Gap(6),
        Text(
          text,
          style: theme.typography.body.sm.copyWith(
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
