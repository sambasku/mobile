import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/entertainment/presentation/widgets/pantun_edit_reply_sheet.dart';

import '../../../../helpers/l10n_delegates.dart';

void main() {
  testWidgets(
    'showPantunReplyEditSheet menjaga posisi kursor dan teks saat keyboard naik',
    (tester) async {
      List<String>? savedLines;

      await tester.pumpWidget(
        FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: MaterialApp(
            localizationsDelegates: appLocalizationDelegates,
            supportedLocales: appTestSupportedLocales,
            locale: appTestLocale,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    await showPantunReplyEditSheet(
                      context,
                      initialLines: const [
                        'Pergi ke pasar sejak lama',
                        'Jangan lupa membeli kain',
                        'Kalau hati sedang sama',
                        'Mari kita belajar rajin',
                      ],
                      onSave: (lines, scheme) async {
                        savedLines = lines;
                        return null;
                      },
                    );
                  },
                  child: const Text('buka'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('buka'));
      await tester.pumpAndSettle();

      final firstField = find.byType(EditableText).first;
      await tester.tap(firstField);
      await tester.pump();

      final controllerBefore =
          tester.widget<EditableText>(firstField).controller;
      controllerBefore.selection = const TextSelection.collapsed(offset: 6);
      await tester.pump();

      addTearDown(tester.view.resetViewInsets);
      for (final logicalBottom in [100.0, 200.0, 300.0]) {
        tester.view.viewInsets = FakeViewPadding(
          bottom: logicalBottom * tester.view.devicePixelRatio,
        );
        await tester.pump();
      }

      final controllerAfter =
          tester.widget<EditableText>(firstField).controller;
      expect(identical(controllerAfter, controllerBefore), isTrue);
      expect(controllerAfter.selection, const TextSelection.collapsed(offset: 6));
      expect(controllerAfter.text, 'Pergi ke pasar sejak lama');

      controllerAfter.value = const TextEditingValue(
        text: 'Jalan ke pasar sejak lama',
        selection: TextSelection.collapsed(offset: 5),
      );
      await tester.pump();

      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();

      expect(
        tester.widget<EditableText>(firstField).controller.text,
        'Jalan ke pasar sejak lama',
      );
      expect(
        tester.widget<EditableText>(firstField).controller.selection,
        const TextSelection.collapsed(offset: 5),
      );

      await tester.tap(find.byType(FButton));
      await tester.pumpAndSettle();

      expect(savedLines?.first, 'Jalan ke pasar sejak lama');
    },
  );
}
