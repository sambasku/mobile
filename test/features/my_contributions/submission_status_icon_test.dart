import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/my_contributions/presentation/widgets/submission_status_icon.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
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
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('tiap status punya ikon - tile tidak pernah tanpa prefix', (
    tester,
  ) async {
    final cases = <(String, IconData)>[
      ('approved', FLucideIcons.circleDashedCheck),
      ('rejected', FLucideIcons.circleX),
      ('corrected', FLucideIcons.penLine),
      ('pending', FLucideIcons.clock),
    ];
    for (final (status, icon) in cases) {
      await tester.pumpWidget(wrap(SubmissionStatusIcon(status: status)));
      expect(find.byIcon(icon), findsOneWidget, reason: status);
    }
  });
}
