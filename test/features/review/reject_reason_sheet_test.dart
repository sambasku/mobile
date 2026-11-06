import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/review/presentation/widgets/reject_reason_sheet.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

Future<Future<String?>> _open(WidgetTester tester) async {
  late Future<String?> result;
  await tester.pumpWidget(
    MaterialApp(
      theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: const [Locale('id')],
      locale: const Locale('id'),
      builder: (context, child) => FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FButton(
              onPress: () {
                result = showRejectReasonSheet(context);
              },
              child: const Text('BUKA'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('BUKA'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('Tolak langsung mengirim Kurang akurat', (tester) async {
    final result = await _open(tester);
    expect(find.text('Tolak usulan'), findsOneWidget);
    expect(find.text('Kurang akurat'), findsOneWidget);

    await tester.tap(find.text('Tolak'));
    await tester.pumpAndSettle();

    expect(await result, 'Kurang akurat');
  });

  testWidgets('chip lain menimpa default', (tester) async {
    final result = await _open(tester);

    await tester.tap(find.text('Tidak relevan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tolak'));
    await tester.pumpAndSettle();

    expect(await result, 'Tidak relevan');
  });
}
