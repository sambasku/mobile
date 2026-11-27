import 'package:flutter_localizations/flutter_localizations.dart'
    hide GlobalMaterialLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/contribution/presentation/widgets/category_multi_picker_sheet.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  const sampleItems = [
    CategoryPickItem(id: '1', name: 'Adat & Tradisi'),
    CategoryPickItem(id: '2', name: 'Alam'),
    CategoryPickItem(id: '3', name: 'Binatang & Hewan'),
  ];

  Widget buildHarness({
    required Set<String> initialSelected,
    required ValueChanged<Set<String>?> onResult,
  }) {
    return MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (_, child) => FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              final res = await showCategoryMultiPickerSheet(
                context,
                items: sampleItems,
                selectedIds: initialSelected,
              );
              onResult(res);
            },
            child: const Text('buka'),
          ),
        ),
      ),
    );
  }

  testWidgets('pakai baris polos tanpa FTile/FCheckbox dan toggle multi-select',
      (tester) async {
    Set<String>? picked;
    await tester.pumpWidget(
      buildHarness(
        initialSelected: const {'1'},
        onResult: (v) => picked = v,
      ),
    );

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    // Seragam dengan picker lain: tidak pakai card FTile maupun kotak FCheckbox.
    expect(find.byType(FTile), findsNothing);
    expect(find.byType(FCheckbox), findsNothing);
    expect(find.byIcon(FLucideIcons.check), findsOneWidget);

    // Pilih item kedua, lalu batal pilih item pertama.
    await tester.tap(find.text('Alam'));
    await tester.pumpAndSettle();
    expect(find.byIcon(FLucideIcons.check), findsNWidgets(2));

    await tester.tap(find.text('Adat & Tradisi'));
    await tester.pumpAndSettle();
    expect(find.byIcon(FLucideIcons.check), findsOneWidget);

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(picked, {'2'});
  });

  testWidgets('pencarian memfilter daftar tanpa menghapus pilihan sebelumnya',
      (tester) async {
    Set<String>? picked;
    await tester.pumpWidget(
      buildHarness(
        initialSelected: const {'1'},
        onResult: (v) => picked = v,
      ),
    );

    await tester.tap(find.text('buka'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'hewan');
    await tester.pumpAndSettle();

    expect(find.text('Adat & Tradisi'), findsNothing);
    expect(find.text('Binatang & Hewan'), findsOneWidget);

    await tester.tap(find.text('Binatang & Hewan'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(picked, {'1', '3'});
  });
}
