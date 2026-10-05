import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:sambasku_mobile/shared/widgets/compact_list.dart';

void main() {
  Widget harness(Widget child) {
    return MaterialApp(
      home: FTheme(
        data: FThemes.zinc.light.touch,
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('CompactListCard renders rows separated by 1px dividers',
      (tester) async {
    await tester.pumpWidget(
      harness(
        const CompactListCard(
          children: [
            CompactRow(title: 'Kata', subtitle: 'Total entri kamus'),
            CompactDivider(),
            CompactRow(title: 'Kontribusi', subtitle: '6 menunggu review'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kata'), findsOneWidget);
    expect(find.text('Total entri kamus'), findsOneWidget);
    expect(find.text('Kontribusi'), findsOneWidget);
    expect(find.text('6 menunggu review'), findsOneWidget);
    expect(find.byType(CompactDivider), findsOneWidget);
    // Tanpa dekorasi kartu per item: hanya satu DecoratedBox kartu luar.
    expect(find.byType(FTile), findsNothing);
  });

  testWidgets('CompactRow onTap fires', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      harness(
        CompactRow(title: 'Pengguna', onTap: () => taps++),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pengguna'));
    expect(taps, 1);
  });
}
