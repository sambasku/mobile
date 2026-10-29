import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/shared/widgets/profile_hero_shell.dart';

import '../helpers/l10n_delegates.dart';

/// Isi halaman: satu blok tinggi supaya bisa digulir sejauh bar.
Widget _content({double height = 1200}) => SingleChildScrollView(
  child: Column(
    children: [
      Container(height: 200, color: const Color(0xFFEEEEEE)),
      SizedBox(height: height),
    ],
  ),
);

Future<void> _pump(WidgetTester tester, Widget shell) async {
  // MaterialApp wajib: IconButton + Tooltip butuh Overlay.
  await tester.pumpWidget(
    FTheme(
      data: foruiPalettes['zinc']!.light.touch,
      child: MaterialApp(
        localizationsDelegates: appLocalizationDelegates,
        supportedLocales: appTestSupportedLocales,
        locale: appTestLocale,
        home: FScaffold(child: shell),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('cover penuh: bar transparan, judul belum tampil', (tester) async {
    await _pump(
      tester,
      ProfileHeroShell(
        title: 'Budi',
        showBack: true,
        backLabel: 'Kembali',
        scrollView: _content(),
      ),
    );

    expect(find.text('Budi'), findsNothing);
    expect(find.byTooltip('Kembali'), findsOneWidget);
  });

  testWidgets('cover tergulir habis: judul muncul (bar solid)', (tester) async {
    await _pump(
      tester,
      ProfileHeroShell(
        title: 'Budi',
        showBack: true,
        backLabel: 'Kembali',
        coverHeight: 160,
        scrollView: _content(),
      ),
    );

    // Range = coverHeight (160) - tinggi bar (52) = 108.
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(find.text('Budi'), findsOneWidget);
    final title = tester.widget<Opacity>(
      find.ancestor(of: find.text('Budi'), matching: find.byType(Opacity)),
    );
    expect(title.opacity, 1.0);
  });
}
