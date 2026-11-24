import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/about/domain/oss_license.dart';
import 'package:sambasku_mobile/features/about/presentation/pages/oss_licenses_page.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

void main() {
  setUp(resetOssLicenseCache);

  test('deteksi jenis lisensi dari teks', () {
    expect(
      ossLicenseKind('MIT License\n\nPermission is hereby granted'),
      'MIT',
    );
    expect(
      ossLicenseKind('Apache License\nVersion 2.0, January 2004'),
      'Apache-2.0',
    );
    expect(
      ossLicenseKind('GNU GENERAL PUBLIC LICENSE\nVersion 3, 29 June 2007'),
      'GPL-3.0',
    );
    expect(ossLicenseKind('BSD 3-Clause License'), 'BSD');
    expect(ossLicenseKind('teks tanpa judul standar'), isNull);
  });

  test('kolektor hanya paket di allowlist pubspec', () async {
    LicenseRegistry.addLicense(() {
      return Stream.fromIterable(const [
        LicenseEntryWithLineBreaks(<String>[
          'forui',
        ], 'MIT License\n\nPermission is hereby granted, free of charge.'),
        LicenseEntryWithLineBreaks(<String>[
          'some_transitive_pkg',
        ], 'MIT License\n\nPermission is hereby granted, free of charge.'),
      ]);
    });

    final list = await collectOssLicenses(packageNames: const {'forui', 'gap'});
    expect(list.map((e) => e.name), ['forui']);
    expect(list.single.kind, 'MIT');
    expect(list.single.text, contains('Permission is hereby granted'));
  });

  testWidgets('daftar langsung tampil tanpa menunggu Registry', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: foruiPalettes['zinc']!.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          ...FLocalizations.localizationsDelegates,
        ],
        supportedLocales: const [Locale('id')],
        locale: const Locale('id'),
        home: FTheme(
          data: foruiPalettes['zinc']!.light.touch,
          child: const OssLicensesPage(packageNames: {'forui', 'gap'}),
        ),
      ),
    );
    // Satu frame cukup: nama sync dari pubspec, bukan FutureBuilder Registry.
    await tester.pump();

    expect(find.text('forui'), findsOneWidget);
    expect(find.text('gap'), findsOneWidget);
    expect(find.byType(FCircularProgress), findsNothing);
  });
}
