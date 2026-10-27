import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/features/vote/domain/entities/vote_deck_item.dart';
import 'package:sambasku_mobile/features/vote/presentation/widgets/vote_deck_word_card.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

const _nomina = VoteDeckWordClass(
  id: '01WCNOMINA000000000000000',
  code: 'n',
  name: 'Nomina',
  alias: 'Kata Benda',
);

const _item = VoteDeckItem(
  id: '01MEANING0000000000000000A',
  wordId: '01WORD0000000000000000000A',
  lemma: 'kalintiak',
  languageId: '01LANG',
  languageCode: 'sbs',
  wordType: 'word',
  status: 'published',
  isVerified: false,
  approvedAt: '2026-09-01T00:00:00.000Z',
  sense: 'ikan kecil',
  orderIndex: 2,
  meaningCount: 3,
  wordClass: _nomina,
);

const _tanpaKelas = VoteDeckItem(
  id: '01MEANING0000000000000000B',
  wordId: '01WORD0000000000000000000A',
  lemma: 'kalintiak',
  languageId: '01LANG',
  languageCode: 'sbs',
  wordType: 'word',
  status: 'published',
  isVerified: false,
  approvedAt: '2026-09-01T00:00:00.000Z',
  sense: 'ikan kecil',
  orderIndex: 1,
  meaningCount: 1,
);

Future<void> _pump(WidgetTester tester, VoteDeckItem item) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: [
        ...AppLocalizations.localizationsDelegates,
        ...FLocalizations.localizationsDelegates,
      ],
      supportedLocales: const [Locale('id')],
      locale: const Locale('id'),
      home: FTheme(
        data: foruiPalettes['zinc']!.light.touch,
        child: Scaffold(
          body: SizedBox(
            width: 800,
            height: 900,
            child: VoteDeckWordCard(item: item),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  // 0101: kartu deck fokus SATU makna - bukan semua makna kata.
  testWidgets('kartu menampilkan lemma + definisi makna ini + konteks urutan',
      (tester) async {
    await _pump(tester, _item);

    expect(find.text('kalintiak'), findsOneWidget);
    expect(find.text('ikan kecil'), findsOneWidget);
    expect(find.text('Makna ke-2 dari 3'), findsOneWidget);
  });

  testWidgets('kelas kata makna tampil pakai alias', (tester) async {
    await _pump(tester, _item);

    expect(find.text('Kata Benda'), findsOneWidget);
    expect(find.text('Nomina'), findsNothing);
  });

  testWidgets('kelas kata kosong tidak bikin chip kosong', (tester) async {
    await _pump(tester, _tanpaKelas);

    expect(find.byType(FBadge), findsNothing);
    expect(find.text('kalintiak'), findsOneWidget);
  });

  testWidgets('kelas "umum" tampil sebagai Umum, bukan alias seed',
      (tester) async {
    await _pump(
      tester,
      const VoteDeckItem(
        id: '01MEANING0000000000000000C',
        wordId: '01WORD0000000000000000000A',
        lemma: 'kalintiak',
        languageId: '01LANG',
        languageCode: 'sbs',
        wordType: 'word',
        status: 'published',
        isVerified: false,
        approvedAt: '2026-09-01T00:00:00.000Z',
        sense: 'ikan kecil',
        orderIndex: 1,
        wordClass: VoteDeckWordClass(
          id: '01WCUMUM0000000000000000',
          code: 'umum',
          name: 'Umum',
          alias: 'Belum Diketahui',
        ),
      ),
    );

    expect(find.text('Umum'), findsOneWidget);
    expect(find.text('Belum Diketahui'), findsNothing);
  });

  testWidgets('jenis entri "Kata" disembunyikan, idiom tampil', (tester) async {
    await _pump(tester, _tanpaKelas);
    expect(find.text('Kata'), findsNothing);

    await _pump(
      tester,
      const VoteDeckItem(
        id: '01MEANING0000000000000000D',
        wordId: '01WORD0000000000000000000A',
        lemma: 'kalintiak',
        languageId: '01LANG',
        languageCode: 'sbs',
        wordType: 'idiom',
        status: 'published',
        isVerified: false,
        approvedAt: '2026-09-01T00:00:00.000Z',
        sense: 'ikan kecil',
        orderIndex: 1,
      ),
    );
    expect(find.text('Idiom'), findsOneWidget);
  });

  testWidgets('kata 1 makna tanpa label konteks urutan', (tester) async {
    await _pump(tester, _tanpaKelas);

    expect(find.text('kalintiak'), findsOneWidget);
    expect(find.textContaining('Makna ke-'), findsNothing);
  });
}
