import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/vote/presentation/widgets/vote_deck_swipe_card.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

// #369: tepat satu getar medium per keputusan swipe (drag lewati ambang lalu
// lepas = satu getar, bukan dua).
void main() {
  late List<String> haptics;

  setUp(() {
    haptics = [];
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized()
        .defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: const [Locale('id')],
      locale: const Locale('id'),
      home: FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: Scaffold(
          body: Center(
            child: SizedBox(width: 400, height: 240, child: child),
          ),
        ),
      ),
    );
  }

  testWidgets('drag lewati ambang lalu lepas = satu getar medium', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        VoteDeckSwipeCard(
          itemKey: 'haptic',
          enabled: true,
          onSwiped: (_) async => true,
          child: const SizedBox.expand(child: Center(child: Text('kartu'))),
        ),
      ),
    );
    await tester.pumpAndSettle();
    haptics.clear();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(VoteDeckSwipeCard)),
    );
    await gesture.moveBy(const Offset(300, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      haptics.where((h) => h == 'HapticFeedbackType.mediumImpact').length,
      1,
    );
  });
}
