import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/core/widgets/busy_aware_icon.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
      localizationsDelegates: FLocalizations.localizationsDelegates,
      supportedLocales: FLocalizations.supportedLocales,
      home: FTheme(
        data: FThemes.zinc.light.touch,
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('menampilkan icon saat tidak loading', (tester) async {
    await tester.pumpWidget(
      wrap(
        const BusyAwareIcon(
          loading: false,
          icon: Icon(FLucideIcons.check),
        ),
      ),
    );

    expect(find.byIcon(FLucideIcons.check), findsOneWidget);
    expect(find.byType(FCircularProgress), findsNothing);
  });

  testWidgets('menampilkan spinner saat loading', (tester) async {
    await tester.pumpWidget(
      wrap(
        const BusyAwareIcon(
          loading: true,
          icon: Icon(FLucideIcons.check),
        ),
      ),
    );

    expect(find.byIcon(FLucideIcons.check), findsNothing);
    expect(find.byType(FCircularProgress), findsOneWidget);
  });
}
