import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/shared/widgets/markdown_editor/markdown_syntax.dart';

void main() {
  group('MarkdownSyntax', () {
    test('wrap inserts markers around empty selection', () {
      final c = TextEditingController(text: 'halo');
      c.selection = const TextSelection.collapsed(offset: 4);
      MarkdownSyntax.wrap(c, left: '**', right: '**');
      expect(c.text, 'halo****');
      expect(c.selection.baseOffset, 6);
    });

    test('wrap wraps selected text', () {
      final c = TextEditingController(text: 'halo dunia');
      c.selection = const TextSelection(baseOffset: 5, extentOffset: 10);
      MarkdownSyntax.wrap(c, left: '_', right: '_');
      expect(c.text, 'halo _dunia_');
    });

    test('insertHeadingLine prefixes current line', () {
      final c = TextEditingController(text: 'satu\ndua');
      c.selection = const TextSelection.collapsed(offset: 6);
      MarkdownSyntax.insertHeadingLine(c);
      expect(c.text, 'satu\n## dua');
    });

    test('insertBulletLine prefixes current line', () {
      final c = TextEditingController(text: 'item');
      c.selection = const TextSelection.collapsed(offset: 0);
      MarkdownSyntax.insertBulletLine(c);
      expect(c.text, '- item');
    });

    test('insertLink replaces the selection', () {
      final c = TextEditingController(text: 'baca sini ya');
      c.selection = const TextSelection(baseOffset: 5, extentOffset: 9);
      MarkdownSyntax.insertLink(
        c,
        label: 'sini',
        url: 'https://sambasku.com',
      );
      expect(c.text, 'baca [sini](https://sambasku.com) ya');
    });

    test('insertLink drops brackets in the label', () {
      final c = TextEditingController();
      MarkdownSyntax.insertLink(
        c,
        label: 'lihat [ini]',
        url: 'https://sambasku.com/a',
      );
      expect(c.text, '[lihat ini](https://sambasku.com/a)');
    });

    test('isHttpsUrl rejects other schemes', () {
      expect(MarkdownSyntax.isHttpsUrl('https://sambasku.com/a'), isTrue);
      expect(MarkdownSyntax.isHttpsUrl('http://sambasku.com'), isFalse);
      expect(MarkdownSyntax.isHttpsUrl('javascript:alert(1)'), isFalse);
      expect(MarkdownSyntax.isHttpsUrl('https://'), isFalse);
    });

    test('insertImage appends markdown image', () {
      final c = TextEditingController(text: 'teks');
      c.selection = const TextSelection.collapsed(offset: 4);
      MarkdownSyntax.insertImage(
        c,
        url: 'https://cdn.example/a.webp',
        alt: 'foto',
      );
      expect(c.text, 'teks\n![foto](https://cdn.example/a.webp)\n');
    });
  });
}
