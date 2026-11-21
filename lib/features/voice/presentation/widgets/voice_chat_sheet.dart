import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../chat/presentation/pages/chat_page.dart';
import '../../../discussion/discussion_router.dart';

/// Buka Chat Publik di bottom sheet dari overlay openmic.
///
/// Full-bleed (tanpa padding samping) supaya barrier menutup seluruh layar.
/// No-op jika sudah di tab Chat (`/discussions/chat`) - strip voice di sana.
Future<void> showVoiceChatSheet(BuildContext context) {
  final path = GoRouterState.of(context).uri.path;
  if (path == DiscussionRouter.chat.path) {
    return Future<void>.value();
  }

  final theme = FTheme.of(context);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: theme.colors.background,
    builder: (sheetContext) {
      final size = MediaQuery.sizeOf(sheetContext);
      final viewInsets = MediaQuery.viewInsetsOf(sheetContext);
      return SizedBox(
        width: size.width,
        height: size.height,
        child: Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: const SafeArea(
            child: ChatPage(embeddedInSheet: true),
          ),
        ),
      );
    },
  );
}
