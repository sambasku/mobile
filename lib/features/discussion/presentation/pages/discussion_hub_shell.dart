import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../chat/presentation/widgets/discussion_hub_segment.dart';
import '../../discussion_router.dart';

/// Chrome bersama hub Diskusi (header + tab) di atas [StatefulNavigationShell].
///
/// Branch 0 = Ruang Diskusi, 1 = Chat. State tiap branch dijaga
/// `StatefulShellRoute.indexedStack`.
class DiscussionHubShell extends StatelessWidget {
  const DiscussionHubShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final index = navigationShell.currentIndex;
    // Chat atur keyboard sendiri (padding manual) - shell jangan resize.
    final isChat = index == 1;

    return FScaffold(
      childPad: true,
      resizeToAvoidBottomInset: !isChat,
      header: FHeader.nested(
        title: Text(l10n.discussionHubTitle),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        suffixes: [
          if (!isChat)
            FHeaderAction(
              icon: const Icon(FLucideIcons.history),
              onPress: () => context.push(DiscussionRouter.mine.path),
            ),
        ],
      ),
      child: Column(
        children: [
          DiscussionHubSegment(
            index: index,
            onChanged: (i) {
              if (i == index) return;
              navigationShell.goBranch(i);
            },
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
