import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../providers/chat_presence_provider.dart';

/// Tab bar hub Diskusi - chips [FBadge] pola kategori feed (#193, #361).
///
/// Konten di [DiscussionHubShell] via `StatefulNavigationShell`; di sini
/// hanya chrome tab supaya tidak dobel scaffold.
/// Label Chat selalu `Chat (x)` supaya lebar chip stabil saat presence sync.
/// Ikon + garis pemisah bawah membedakan tab hub dari `_SortChips` di feed.
class DiscussionHubSegment extends ConsumerWidget {
  const DiscussionHubSegment({
    super.key,
    required this.index,
    required this.onChanged,
  });

  /// 0 = Chat, 1 = Ruang Diskusi.
  final int index;
  final ValueChanged<int> onChanged;

  /// Tinggi baris chip (selaras `_FeedCategoryChips.height`).
  static const double height = 32;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final presence = ref.watch(chatPresenceCountProvider);
    final items = <({IconData icon, String label})>[
      (
        icon: FLucideIcons.messageCircle,
        label: l10n.discussionTabChatWithCount(presence),
      ),
      (icon: FLucideIcons.messagesSquare, label: l10n.discussionTabRooms),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colors.border, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: SizedBox(
          height: height,
          child: ListView.separated(
            key: const ValueKey('discussion_hub_chips'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 2),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Gap(6),
            itemBuilder: (context, i) {
              final item = items[i];
              return _HubTabChip(
                icon: item.icon,
                text: item.label,
                selected: index == i,
                theme: theme,
                onTap: () => onChanged(i),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HubTabChip extends StatelessWidget {
  const _HubTabChip({
    required this.icon,
    required this.text,
    required this.selected,
    required this.theme,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final bool selected;
  final FThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected
        ? theme.colors.primaryForeground
        : theme.colors.secondaryForeground;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: FBadge(
          variant: selected ? FBadgeVariant.primary : FBadgeVariant.secondary,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const Gap(5),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}