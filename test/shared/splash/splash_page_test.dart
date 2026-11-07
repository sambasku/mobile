import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/core/widgets/brand_logo.dart';
import 'package:sambasku_mobile/shared/splash/presentation/splash_page.dart';

import '../../helpers/l10n_delegates.dart';

Future<void> _pump(WidgetTester tester, {Brightness brightness = Brightness.light}) async {
  await tester.pumpWidget(
    FTheme(
      data: brightness == Brightness.dark
          ? foruiPalettes['zinc']!.dark.touch
          : foruiPalettes['zinc']!.light.touch,
      child: MaterialApp(
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: appTestSupportedLocales,
        locale: appTestLocale,
        home: const SplashPage(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('splash light: latar, BrandMark, slot sponsor, spinner, tagline', (
    tester,
  ) async {
    await _pump(tester);

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.contains('splashscreen_white'),
      ),
      findsOneWidget,
    );
    expect(find.byType(BrandMark), findsOneWidget);
    expect(find.byType(FCircularProgress), findsOneWidget);
    expect(find.textContaining('Kamus, Bahasa'), findsOneWidget);

    // Slot Area sponsor reserved (tinggi tetap).
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is SizedBox &&
            w.height == SplashPage.sponsorSlotHeight &&
            w.width == double.infinity,
      ),
      findsOneWidget,
    );
  });

  testWidgets('splash dark: pakai splashscreen_dark', (tester) async {
    await _pump(tester, brightness: Brightness.dark);

    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Image &&
            w.image is AssetImage &&
            (w.image as AssetImage).assetName.contains('splashscreen_dark'),
      ),
      findsOneWidget,
    );
  });
}
