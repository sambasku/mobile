import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/shared/widgets/sambasku_markdown.dart';

/// Issue #160: ukuran heading/spasi artikel + edge case input.
Widget _host(Widget child) => MaterialApp(
  theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
  localizationsDelegates: FLocalizations.localizationsDelegates,
  supportedLocales: FLocalizations.supportedLocales,
  home: FTheme(
    data: FThemes.zinc.light.touch,
    child: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

double? _sizeOf(WidgetTester t, String text) {
  final rich = t.widgetList<RichText>(find.byType(RichText)).firstWhere(
    (w) => w.text.toPlainText() == text,
  );
  // Style heading ada di span anak, bukan di span akar RichText.
  double? size;
  rich.text.visitChildren((span) {
    if (span is TextSpan && (span.text ?? '').isNotEmpty) {
      size = span.style?.fontSize;
      return false;
    }
    return true;
  });
  return size ?? rich.text.style?.fontSize;
}

void main() {
  testWidgets('heading h1-h5 punya ukuran berjenjang dan di bawah skala lama', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const SambaskuMarkdown(
          selectable: false,
          data: '# A1\n\n## A2\n\n### A3\n\n#### A4\n\n##### A5\n\nbody',
        ),
      ),
    );
    final sizes = [
      for (final t in ['A1', 'A2', 'A3', 'A4', 'A5', 'body']) _sizeOf(tester, t)!,
    ];
    // touch: h1 xl 22, h2 md 18, h3/h4/body sm 16, h5 xs 14.
    expect(sizes, [22, 18, 16, 16, 14, 16]);
    expect(sizes.first, lessThan(30), reason: 'h1 lama = xl2 (30px)');
  });

  testWidgets('input kosong atau spasi saja tidak menggambar apa pun', (
    tester,
  ) async {
    for (final data in ['', '   \n\t ']) {
      await tester.pumpWidget(_host(SambaskuMarkdown(data: data)));
      expect(find.byType(MarkdownBody), findsNothing);
    }
  });

  testWidgets('tabel 7 kolom dan teks panjang tidak overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(
        const SambaskuMarkdown(
          selectable: false,
          data:
              '| a | b | c | d | e | f | g |\n| - | - | - | - | - | - | - |\n'
              '| Ratu Sepudak | 10,40 | 2,98 | 2 | 3 | 9 | Muhkarti Setya Budi Pranyoto |\n\n'
              '# Judul yang sangat panjang sekali supaya membungkus beberapa baris di layar sempit',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(Table), findsOneWidget);
  });
}
