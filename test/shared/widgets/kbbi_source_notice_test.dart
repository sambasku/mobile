import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:sambasku_mobile/shared/widgets/kbbi_source_notice.dart';

void main() {
  testWidgets('KbbiSourceNotice tampil sebagai FAlert info', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        home: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: const Scaffold(body: KbbiSourceNotice()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(KbbiSourceNotice)),
    );
    expect(find.text(l10n.kbbiSourceNotice), findsOneWidget);
    // Default FAlert = variant primary (info), bukan destructive.
    expect(find.byType(FAlert), findsOneWidget);
  });
}
