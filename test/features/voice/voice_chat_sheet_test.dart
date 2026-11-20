import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/chat/presentation/pages/chat_page.dart';
import 'package:sambasku_mobile/features/discussion/discussion_router.dart';
import 'package:sambasku_mobile/features/voice/presentation/widgets/voice_chat_sheet.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('showVoiceChatSheet no-op di tab Chat', (tester) async {
    var opened = false;
    final router = GoRouter(
      initialLocation: DiscussionRouter.chat.path,
      routes: [
        GoRoute(
          path: DiscussionRouter.chat.path,
          builder: (context, state) {
            return Scaffold(
              body: Center(
                child: FButton(
                  onPress: () async {
                    await showVoiceChatSheet(context);
                    opened = true;
                  },
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: MaterialApp.router(
            localizationsDelegates: [
              ...AppLocalizations.localizationsDelegates,
              ...FLocalizations.localizationsDelegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(opened, isTrue);
    expect(find.byType(ChatPage), findsNothing);
  });
}
