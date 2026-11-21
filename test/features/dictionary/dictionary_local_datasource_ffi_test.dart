import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/dictionary/data/datasources/dictionary_local_datasource.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database db;
  late DictionaryLocalDatasource ds;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final asset = File('assets/data/database.sqlite');
    expect(asset.existsSync(), isTrue, reason: 'bundle sqlite must exist');
    final tmp = await File(
      '${Directory.systemTemp.path}/lemma_test_${DateTime.now().microsecondsSinceEpoch}.sqlite',
    ).create();
    await asset.copy(tmp.path);
    db = await openDatabase(tmp.path, readOnly: true, singleInstance: false);
    ds = DictionaryLocalDatasource(db);
  });

  tearDownAll(() async {
    await db.close();
  });

  test('search finds lemma', () async {
    final page = await ds.searchWords(query: 'pais', limit: 10);
    expect(page.items, isNotEmpty);
    expect(
      page.items.any((w) => w.lemma.toLowerCase().contains('pais')),
      isTrue,
    );
  });

  test('getWordByLemma returns detail', () async {
    final detail = await ds.getWordByLemma('1 pais');
    expect(detail, isNotNull);
    expect(detail!.meanings, isNotEmpty);
  });

  test('getWordById miss returns null', () async {
    final detail = await ds.getWordById('NOT_A_REAL_ID');
    expect(detail, isNull);
  });

  test('listLatest returns published words', () async {
    final page = await ds.listLatest(limit: 5);
    expect(page.items.length, lessThanOrEqualTo(5));
    expect(page.items, isNotEmpty);
  });
}
