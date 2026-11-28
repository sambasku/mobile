import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/chat/presentation/providers/chat_typing_provider.dart';
import 'package:sambasku_mobile/features/chat/presentation/widgets/chat_composer.dart';
import 'package:sambasku_mobile/features/comment/presentation/providers/mention_suggest_providers.dart';
import 'package:sambasku_mobile/features/comment/presentation/widgets/mention_suggest_overlay.dart';
import 'package:sambasku_mobile/features/user_profile/domain/entities/public_profile.dart';
import 'package:sambasku_mobile/features/user_profile/domain/failures/user_profile_failure.dart';
import 'package:sambasku_mobile/features/user_profile/domain/providers/user_profile_domain_providers.dart';
import 'package:sambasku_mobile/features/user_profile/domain/usecases/suggest_mentions_use_case.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  testWidgets('#398 ChatComposer renders MentionSuggestOverlay and inserts mention', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        suggestMentionsUseCaseProvider.overrideWith((ref) => _FakeSuggest()),
        chatTypingProvider.overrideWith(_IdleTypingNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final controller = TextEditingController();
    addTearDown(controller.dispose);
    controller.addListener(
      () => container
          .read(mentionSuggestControllerProvider.notifier)
          .onTextChanged(controller.text, controller.selection.baseOffset),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            ...FLocalizations.localizationsDelegates,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => FTheme(
            data: foruiPalettes[defaultPalette]!.light.touch,
            child: child!,
          ),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: ChatComposer(
                controller: controller,
                enabled: true,
                sending: false,
                replyTarget: null,
                onClearReply: () {},
                onJumpToReply: () {},
                onSendText: () {},
                onOpenStickers: () {},
                onRecordVoice: () {},
                onLoginPrompt: () {},
                suggestBuilder: (_) => MentionSuggestOverlay(
                  onSelect: (username) =>
                      insertIntoComposer(controller, username),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'halo @bu');
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('@budi'), findsOneWidget);
    await tester.tap(find.text('@budi'));
    await tester.pump();

    expect(controller.text, 'halo @budi ');
  });

  testWidgets('#397 ChatComposer defaults to 0 horizontal padding and supports custom value', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        chatTypingProvider.overrideWith(_IdleTypingNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    final controller = TextEditingController();
    addTearDown(controller.dispose);

    Widget buildApp({double? horizontalPadding}) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => FTheme(
          data: foruiPalettes[defaultPalette]!.light.touch,
          child: child!,
        ),
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: horizontalPadding == null
                ? ChatComposer(
                    controller: controller,
                    enabled: true,
                    sending: false,
                    replyTarget: null,
                    onClearReply: () {},
                    onJumpToReply: () {},
                    onSendText: () {},
                    onOpenStickers: () {},
                    onRecordVoice: () {},
                    onLoginPrompt: () {},
                  )
                : ChatComposer(
                    controller: controller,
                    enabled: true,
                    sending: false,
                    replyTarget: null,
                    onClearReply: () {},
                    onJumpToReply: () {},
                    onSendText: () {},
                    onOpenStickers: () {},
                    onRecordVoice: () {},
                    onLoginPrompt: () {},
                    horizontalPadding: horizontalPadding,
                  ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    Padding outerPadding() {
      final safeArea = tester.widget<SafeArea>(
        find.descendant(
          of: find.byType(ChatComposer),
          matching: find.byType(SafeArea),
        ),
      );
      return safeArea.child as Padding;
    }

    expect(outerPadding().padding, const EdgeInsets.fromLTRB(0, 6, 0, 6));

    await tester.pumpWidget(buildApp(horizontalPadding: 16));
    await tester.pumpAndSettle();

    expect(outerPadding().padding, const EdgeInsets.fromLTRB(16, 6, 16, 6));
  });
}

class _FakeSuggest implements SuggestMentionsUseCase {
  @override
  Future<Either<UserProfileFailure, List<MentionSuggestion>>> call(
    String query,
  ) async => Either.right(const [
    MentionSuggestion(id: '1', username: 'budi', displayName: 'Budi'),
  ]);
}

class _IdleTypingNotifier extends ChatTypingController {
  @override
  List<ChatTyper> build() => const [];
}
