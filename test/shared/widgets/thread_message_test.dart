import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/shared/widgets/thread_message.dart';

Widget _host(Widget child) {
  return FTheme(
    data: foruiPalettes['zinc']!.light.touch,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  testWidgets('@username dirender di baris bawah display name', (tester) async {
    await tester.pumpWidget(
      _host(
        const ThreadMessageRow(
          username: 'budi',
          displayName: 'Budi Santoso',
          body: 'Isi komentar.',
        ),
      ),
    );

    final nameTop = tester.getTopLeft(find.text('Budi Santoso')).dy;
    final handleTop = tester.getTopLeft(find.text('@budi')).dy;
    expect(find.text('@budi'), findsOneWidget);
    expect(handleTop, greaterThan(nameTop));
  });

  testWidgets('@username tidak dirender bila label sudah username', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const ThreadMessageRow(username: 'budi', body: 'Isi komentar.')),
    );

    expect(find.text('@budi'), findsNothing);
  });

  testWidgets('@username tidak dirender saat redacted', (tester) async {
    await tester.pumpWidget(
      _host(
        const ThreadMessageRow(
          username: 'budi',
          displayName: 'Budi Santoso',
          body: 'Isi komentar.',
          isRedacted: true,
        ),
      ),
    );

    expect(find.text('@budi'), findsNothing);
  });
}
