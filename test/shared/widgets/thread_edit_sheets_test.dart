import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/shared/widgets/thread_edit_sheets.dart';

void main() {
  testWidgets(
    'showThreadTextEditSheet menjaga posisi kursor dan teks saat keyboard naik (#352)',
    (tester) async {
      String? result;
      String? savedPayload;

      await tester.pumpWidget(
        FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await showThreadTextEditSheet(
                      context,
                      title: 'Sunting komentar',
                      initialBody: 'Halo dunia Sambas',
                      saveLabel: 'Simpan',
                      onSave: (body) async {
                        savedPayload = body;
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

      final editableFinder = find.byType(EditableText);
      expect(editableFinder, findsOneWidget);

      await tester.tap(editableFinder);
      await tester.pump();

      final controllerBefore =
          tester.widget<EditableText>(editableFinder).controller;
      controllerBefore.selection = const TextSelection.collapsed(offset: 5);
      await tester.pump();

      // Simulasi beberapa frame animasi keyboard naik (viewInsets berubah).
      addTearDown(tester.view.resetViewInsets);
      for (final logicalBottom in [100.0, 200.0, 300.0]) {
        tester.view.viewInsets = FakeViewPadding(
          bottom: logicalBottom * tester.view.devicePixelRatio,
        );
        await tester.pump();
      }

      final controllerAfter =
          tester.widget<EditableText>(editableFinder).controller;
      expect(identical(controllerAfter, controllerBefore), isTrue);
      expect(controllerAfter.selection, const TextSelection.collapsed(offset: 5));
      expect(controllerAfter.text, 'Halo dunia Sambas');

      // Ubah teks lalu simulasikan keyboard turun -> teks dan kursor tidak reset.
      controllerAfter.value = const TextEditingValue(
        text: 'Halo Sambas baru',
        selection: TextSelection.collapsed(offset: 11),
      );
      await tester.pump();

      tester.view.viewInsets = FakeViewPadding.zero;
      await tester.pumpAndSettle();

      final controllerFinal =
          tester.widget<EditableText>(editableFinder).controller;
      expect(controllerFinal.text, 'Halo Sambas baru');
      expect(controllerFinal.selection, const TextSelection.collapsed(offset: 11));

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(savedPayload, 'Halo Sambas baru');
      expect(result, 'Halo Sambas baru');
    },
  );
}
