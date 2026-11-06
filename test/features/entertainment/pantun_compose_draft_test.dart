import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart' show Override;
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/entertainment/data/pantun_draft_store.dart';
import 'package:sambasku_mobile/features/entertainment/domain/pantun_compose_args.dart';
import 'package:sambasku_mobile/features/entertainment/domain/pantun_models.dart';
import 'package:sambasku_mobile/features/entertainment/presentation/pages/pantun_compose_page.dart';
import 'package:sambasku_mobile/features/entertainment/presentation/providers/pantun_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/l10n_delegates.dart';

Pantun _pantun({
  required String id,
  String? parentId,
  required List<String> lines,
}) => Pantun(
  id: id,
  userId: 'u1',
  username: 'penulis',
  displayName: 'Penulis',
  avatarUrl: null,
  parentId: parentId,
  language: 'id',
  themeId: null,
  rhymeScheme: 'ABAB',
  lines: lines,
  status: 'published',
  createdAt: DateTime.utc(2026, 1, 1),
  updatedAt: DateTime.utc(2026, 1, 1),
);

class _FakeDetail extends PantunDetailController {
  _FakeDetail(super.id, this.detail);

  final PantunDetail detail;

  @override
  Future<PantunDetail> build() async => detail;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpCompose(
    WidgetTester tester, {
    required PantunComposePage page,
    List<Override> overrides = const [],
  }) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          localizationsDelegates: appLocalizationDelegates,
          locale: appTestLocale,
          supportedLocales: appTestSupportedLocales,
          home: FTheme(
            data: foruiPalettes['zinc']!.light.touch,
            child: FToaster(child: page),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('restore draf pantun baru ke empat field', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final store = PantunDraftStore(prefs: prefs);
    await store.save(lines: const ['satu', 'dua', 'tiga', 'empat']);

    await pumpCompose(
      tester,
      page: PantunComposePage(draftStore: store),
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('satu'), findsOneWidget);
    expect(find.text('dua'), findsOneWidget);
    expect(find.text('tiga'), findsOneWidget);
    expect(find.text('empat'), findsOneWidget);
    expect(find.text('Draf tersimpan'), findsOneWidget);
  });

  testWidgets('quote berbeda memuat draf berbeda', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    final store = PantunDraftStore(prefs: prefs);
    await store.save(
      lines: const ['root-a', 'root-b', 'root-c', 'root-d'],
      parentId: 'p1',
      quoteId: PantunComposeArgs.quoteRoot,
    );
    await store.save(
      lines: const ['rep-a', 'rep-b', 'rep-c', 'rep-d'],
      parentId: 'p1',
      quoteId: 'r9',
    );

    final root = _pantun(
      id: 'p1',
      lines: const ['induk1', 'induk2', 'induk3', 'induk4'],
    );
    final reply = _pantun(
      id: 'r9',
      parentId: 'p1',
      lines: const ['balas1', 'balas2', 'balas3', 'balas4'],
    );

    await pumpCompose(
      tester,
      page: PantunComposePage(
        parentId: 'p1',
        quoteId: 'r9',
        draftStore: store,
        args: PantunComposeArgs(
          parentId: 'p1',
          quoteId: 'r9',
          quoteLines: reply.lines,
          quoteAuthorLabel: 'Penulis',
        ),
      ),
      overrides: [
        pantunDetailProvider('p1').overrideWith(
          () => _FakeDetail('p1', PantunDetail(root, [reply])),
        ),
      ],
    );
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('rep-a'), findsOneWidget);
    expect(find.text('root-a'), findsNothing);
  });
}
