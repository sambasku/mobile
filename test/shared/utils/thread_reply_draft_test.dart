import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/utils/thread_reply_draft.dart';

void main() {
  group('buildThreadReplyDraft', () {
    test('quote + mention', () {
      final draft = buildThreadReplyDraft(
        username: 'budi',
        body: 'Halo dunia',
      );
      expect(draft.text, '> Halo dunia\n\n@budi ');
      expect(draft.cursor, draft.text.length);
      expect(draft.mentionUsername, 'budi');
      expect(draft.quotePreview, 'Halo dunia');
    });

    test('skip mention ke diri sendiri', () {
      final draft = buildThreadReplyDraft(
        username: 'Budi',
        body: 'teks',
        currentUsername: 'budi',
      );
      expect(draft.text, '> teks\n\n');
      expect(draft.mentionUsername, isNull);
    });

    test('tanpa body → hanya mention', () {
      final draft = buildThreadReplyDraft(username: 'budi', body: null);
      expect(draft.text, '@budi ');
      expect(draft.quotePreview, isNull);
    });

    test('username tidak linkable → tanpa mention', () {
      final draft = buildThreadReplyDraft(
        username: 'anonim',
        body: 'isi',
      );
      expect(draft.text, '> isi\n\n');
      expect(draft.mentionUsername, isNull);
    });

    test('cuplikan dipotong max chars', () {
      final long = 'a' * 200;
      final draft = buildThreadReplyDraft(username: 'budi', body: long);
      expect(draft.quotePreview!.endsWith('…'), isTrue);
      expect(draft.quotePreview!.length, lessThanOrEqualTo(121));
    });
  });

  group('stripLeadingReplyDraft', () {
    test('hapus prefix bila masih di awal', () {
      expect(
        stripLeadingReplyDraft('> hi\n\n@budi balasan', '> hi\n\n@budi '),
        'balasan',
      );
    });

    test('biarkan teks bila prefix sudah diubah', () {
      expect(
        stripLeadingReplyDraft('ubah manual', '> hi\n\n@budi '),
        'ubah manual',
      );
    });
  });

  group('splitLeadingBlockquote', () {
    test('pisah quote dan sisa', () {
      final split = splitLeadingBlockquote('> satu\n> dua\n\n@budi ya');
      expect(split.quote, 'satu\ndua');
      expect(split.rest, '@budi ya');
    });

    test('tanpa quote', () {
      final split = splitLeadingBlockquote('@budi halo');
      expect(split.quote, isEmpty);
      expect(split.rest, '@budi halo');
    });
  });
}
