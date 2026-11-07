import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/entertainment/data/pantun_draft_store.dart';
import 'package:sambasku_mobile/features/entertainment/domain/pantun_compose_args.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('draftKey', () {
    test('new pantun', () {
      expect(PantunDraftStore.draftKey(), 'tmp_pantun:v1:new');
      expect(
        PantunDraftStore.draftKey(parentId: '', quoteId: 'x'),
        'tmp_pantun:v1:new',
      );
    });

    test('reply ke induk vs balasan tidak bentrok', () {
      expect(
        PantunDraftStore.draftKey(parentId: 'p1', quoteId: 'root'),
        'tmp_pantun:v1:reply:p1:quote:root',
      );
      expect(
        PantunDraftStore.draftKey(parentId: 'p1'),
        'tmp_pantun:v1:reply:p1:quote:root',
      );
      expect(
        PantunDraftStore.draftKey(parentId: 'p1', quoteId: 'r9'),
        'tmp_pantun:v1:reply:p1:quote:r9',
      );
      expect(
        PantunDraftStore.draftKey(parentId: 'p1', quoteId: 'root'),
        isNot(PantunDraftStore.draftKey(parentId: 'p1', quoteId: 'r9')),
      );
    });

    test('dari PantunComposeArgs', () {
      expect(
        PantunDraftStore.draftKeyFromArgs(const PantunComposeArgs()),
        'tmp_pantun:v1:new',
      );
      expect(
        PantunDraftStore.draftKeyFromArgs(
          const PantunComposeArgs(parentId: 'p1', quoteId: 'r2'),
        ),
        'tmp_pantun:v1:reply:p1:quote:r2',
      );
    });
  });

  group('persist', () {
    test('save lalu load baris yang sama', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = PantunDraftStore(prefs: prefs);
      await store.save(
        lines: const ['a', 'b', '', ''],
        parentId: 'p1',
        quoteId: 'r1',
      );
      final draft = await store.load(parentId: 'p1', quoteId: 'r1');
      expect(draft, isNotNull);
      expect(draft!.lines, ['a', 'b', '', '']);
      expect(draft.hasContent, isTrue);
    });

    test('key berbeda tidak saling timpa', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = PantunDraftStore(prefs: prefs);
      await store.save(
        lines: const ['induk', '1', '2', '3'],
        parentId: 'p1',
        quoteId: 'root',
      );
      await store.save(
        lines: const ['reply', 'x', 'y', 'z'],
        parentId: 'p1',
        quoteId: 'r1',
      );
      expect(
        (await store.load(parentId: 'p1', quoteId: 'root'))!.lines.first,
        'induk',
      );
      expect(
        (await store.load(parentId: 'p1', quoteId: 'r1'))!.lines.first,
        'reply',
      );
    });

    test('save kosong menghapus key', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = PantunDraftStore(prefs: prefs);
      await store.save(
        lines: const ['a', '', '', ''],
        parentId: null,
      );
      await store.save(
        lines: const ['', '', '', ''],
        parentId: null,
      );
      expect(await store.load(), isNull);
    });

    test('clear menghapus draf', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = PantunDraftStore(prefs: prefs);
      await store.save(lines: const ['a', 'b', 'c', 'd'], parentId: 'p1');
      await store.clear(parentId: 'p1', quoteId: 'root');
      expect(await store.load(parentId: 'p1', quoteId: 'root'), isNull);
    });

    test('TTL kedaluwarsa dibuang saat load', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = PantunDraftStore(prefs: prefs);
      final old = DateTime.now().toUtc().subtract(const Duration(days: 8));
      final key = PantunDraftStore.draftKey(parentId: 'p1', quoteId: 'root');
      await prefs.setString(
        key,
        PantunDraft(
          lines: const ['a', 'b', 'c', 'd'],
          updatedAt: old,
        ).encode(),
      );
      expect(await store.load(parentId: 'p1', quoteId: 'root'), isNull);
      expect(prefs.getString(key), isNull);
    });

    test('clearMissingReplyQuotes hanya hapus quote balasan mati', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = PantunDraftStore(prefs: prefs);
      await store.save(
        lines: const ['root', '', '', ''],
        parentId: 'p1',
        quoteId: 'root',
      );
      await store.save(
        lines: const ['live', '', '', ''],
        parentId: 'p1',
        quoteId: 'r-live',
      );
      await store.save(
        lines: const ['gone', '', '', ''],
        parentId: 'p1',
        quoteId: 'r-gone',
      );
      await store.clearMissingReplyQuotes(
        parentId: 'p1',
        liveReplyIds: {'r-live'},
      );
      expect(
        (await store.load(parentId: 'p1', quoteId: 'root'))!.lines.first,
        'root',
      );
      expect(
        (await store.load(parentId: 'p1', quoteId: 'r-live'))!.lines.first,
        'live',
      );
      expect(await store.load(parentId: 'p1', quoteId: 'r-gone'), isNull);
    });

    test('LRU memotong entri tertua di atas maxEntries', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = PantunDraftStore(prefs: prefs);
      // Harus dalam TTL (7 hari); jangan pakai tahun lama.
      final base = DateTime.now().toUtc().subtract(const Duration(hours: 2));
      for (var i = 0; i < PantunDraftStore.maxEntries + 3; i++) {
        final key = PantunDraftStore.draftKey(
          parentId: 'p$i',
          quoteId: 'root',
        );
        await prefs.setString(
          key,
          PantunDraft(
            lines: ['line-$i', '', '', ''],
            updatedAt: base.add(Duration(minutes: i)),
          ).encode(),
        );
      }
      // Trigger prune via save baru (paling baru).
      await store.save(
        lines: const ['fresh', '', '', ''],
        parentId: 'fresh',
        quoteId: 'root',
        now: DateTime.now().toUtc(),
      );
      final remaining = prefs
          .getKeys()
          .where((k) => k.startsWith(PantunDraftStore.keyPrefix))
          .length;
      expect(remaining, lessThanOrEqualTo(PantunDraftStore.maxEntries));
      expect(
        await store.load(parentId: 'p0', quoteId: 'root'),
        isNull,
      );
      expect(
        (await store.load(parentId: 'fresh', quoteId: 'root'))!.lines.first,
        'fresh',
      );
    });
  });
}
