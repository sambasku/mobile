import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';
import 'package:sambasku_mobile/shared/widgets/kbbi_source_notice.dart';

import '../../helpers/l10n_delegates.dart';

void main() {
  testWidgets('KbbiSourceNotice: label singkat + ikon info', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: appTestSupportedLocales,
        locale: appTestLocale,
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
    // Label singkat selalu tampil; penjelasan penuh di FPopover (tap ikon).
    expect(find.text(l10n.kbbiSourceNoticeShort), findsOneWidget);
    expect(find.byIcon(FLucideIcons.info), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.kbbiSourceNoticeInfoSemantics), findsOneWidget);
    // Teks panjang tidak di-tree sebelum popover dibuka.
    expect(find.text(l10n.kbbiSourceNotice), findsNothing);
  });
}
