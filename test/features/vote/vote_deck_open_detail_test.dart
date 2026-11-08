import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/vote/presentation/widgets/vote_deck_word_card.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  Future<void> pumpFace(
    WidgetTester tester, {
    VoidCallback? onOpenDetail,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        builder: (context, child) =>
            FTheme(data: foruiPalettes['zinc']!.light.touch, child: child!),
        home: FScaffold(
          child: VoteDeckMeaningFace(
            lemma: 'makatn',
            sense: 'makan',
            wordTypeLabel: 'Kata',
            onOpenDetail: onOpenDetail,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('ketuk area kartu membuka detail lemma', (tester) async {
    var opened = 0;
    await pumpFace(tester, onOpenDetail: () => opened++);

    await tester.tap(find.text('makatn'));
    await tester.pump();

    expect(opened, 1);
    expect(find.text('Lihat kata'), findsNothing);
  });

  testWidgets('tanpa callback, ketuk lemma tidak membuka detail', (
    tester,
  ) async {
    await pumpFace(tester);

    await tester.tap(find.text('makatn'));
    await tester.pump();

    expect(find.text('makatn'), findsOneWidget);
  });
}
