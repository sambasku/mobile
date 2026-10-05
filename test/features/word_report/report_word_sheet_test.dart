import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/word_report/data/word_report_providers.dart';
import 'package:sambasku_mobile/features/word_report/data/word_report_repository.dart';
import 'package:sambasku_mobile/features/word_report/presentation/report_word_sheet.dart';

class _CapturingRepo extends WordReportRepository {
  _CapturingRepo() : super(Dio());

  String? reasonCode;
  String? note;
  String? imageId;

  @override
  Future<void> submit({
    required String wordId,
    required String reasonCode,
    String? note,
    String? imageId,
  }) async {
    this.reasonCode = reasonCode;
    this.note = note;
    this.imageId = imageId;
  }
}

Future<void> _pump(WidgetTester tester, _CapturingRepo repo, String? imageId) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [wordReportRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: FThemes.zinc.light.touch.toApproximateMaterialTheme(),
        localizationsDelegates: FLocalizations.localizationsDelegates,
        supportedLocales: FLocalizations.supportedLocales,
        builder: (context, child) => FTheme(
          data: FThemes.zinc.light.touch,
          child: FToaster(child: child!),
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FButton(
                onPress: () => showReportWordSheet(context, 'word-1', imageId: imageId),
                child: const Text('BUKA'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('BUKA'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('laporan foto: chip kekerasan terkirim sebagai violent_image', (tester) async {
    final repo = _CapturingRepo();
    await _pump(tester, repo, 'img-1');

    expect(find.text('Foto berisi kekerasan'), findsOneWidget);
    expect(find.text('Foto berisi konten seksual'), findsOneWidget);
    expect(find.text('Foto tidak pantas'), findsOneWidget);

    await tester.tap(find.text('Kirim laporan'));
    await tester.pumpAndSettle();
    expect(repo.reasonCode, 'violent_image');
    expect(repo.note, 'Foto berisi kekerasan');
    expect(repo.imageId, 'img-1');
  });

  testWidgets('laporan foto: chip lain + catatan digabung', (tester) async {
    final repo = _CapturingRepo();
    await _pump(tester, repo, 'img-1');

    await tester.tap(find.text('Foto tidak pantas'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'tolong cek');
    await tester.tap(find.text('Kirim laporan'));
    await tester.pumpAndSettle();

    expect(repo.reasonCode, 'violent_image');
    expect(repo.note, 'Foto tidak pantas. Catatan: tolong cek');
  });

  testWidgets('laporan entri tanpa imageId: alasan tetap', (tester) async {
    final repo = _CapturingRepo();
    await _pump(tester, repo, null);

    expect(find.text('Foto berisi kekerasan'), findsNothing);
    expect(find.text('Bukan kosakata Sambas'), findsOneWidget);

    await tester.tap(find.text('Kirim laporan'));
    await tester.pumpAndSettle();
    expect(repo.reasonCode, 'inappropriate');
    expect(repo.imageId, isNull);
  });
}
