import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/shared/widgets/option_picker_sheet.dart';

void main() {
  testWidgets('cari di sheet: hasil tampil di atas keyboard, sheet tetap buka',
      (tester) async {
    String? picked;
    await tester.pumpWidget(
      FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  picked = await showOptionPickerSheet<String>(
                    context,
                    title: 'Pilih kecamatan',
                    searchable: true,
                    items: [
                      for (final n in ['Sambas', 'Tebas', 'Jawai', 'Paloh'])
                        OptionPickerItem(value: n, label: n),
                    ],
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

    // Simulasi keyboard 300 logis (viewInsets dalam pixel fisik).
    const keyboardLogical = 300.0;
    tester.view.viewInsets = FakeViewPadding(
      bottom: keyboardLogical * tester.view.devicePixelRatio,
    );
    addTearDown(tester.view.resetViewInsets);
    await tester.enterText(find.byType(EditableText), 'teb');
    await tester.pumpAndSettle();

    expect(find.text('Pilih kecamatan'), findsOneWidget);
    expect(find.text('Sambas'), findsNothing);
    final hit = find.text('Tebas');
    expect(hit, findsOneWidget);
    // Hasil berada di atas area keyboard.
    final screenHeight =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(tester.getBottomLeft(hit).dy, lessThan(screenHeight - keyboardLogical));

    await tester.tap(hit);
    await tester.pumpAndSettle();
    expect(picked, 'Tebas');
  });
}
