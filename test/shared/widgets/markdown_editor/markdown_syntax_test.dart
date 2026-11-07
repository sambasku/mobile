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

    test('setHeadingLine prefixes current line', () {
      final c = TextEditingController(text: 'satu\ndua');
      c.selection = const TextSelection.collapsed(offset: 6);
      MarkdownSyntax.setHeadingLine(c, level: 2);
      expect(c.text, 'satu\n## dua');
    });

    test('setHeadingLine replaces existing heading level', () {
      final c = TextEditingController(text: '## lama');
      c.selection = const TextSelection.collapsed(offset: 3);
      MarkdownSyntax.setHeadingLine(c, level: 1);
      expect(c.text, '# lama');
    });

    test('setListLines prefixes current line as bullet', () {
      final c = TextEditingController(text: 'item');
      c.selection = const TextSelection.collapsed(offset: 0);
      MarkdownSyntax.setListLines(c, ordered: false);
      expect(c.text, '- item');
    });

    test('setListLines numbers multi-line selection', () {
      final c = TextEditingController(text: 'a\nb\nc');
      c.selection = const TextSelection(baseOffset: 0, extentOffset: 5);
      MarkdownSyntax.setListLines(c, ordered: true);
      expect(c.text, '1. a\n2. b\n3. c');
    });

    test('setListLines converts bullet to ordered', () {
      final c = TextEditingController(text: '- a\n- b');
      c.selection = const TextSelection(baseOffset: 0, extentOffset: 7);
      MarkdownSyntax.setListLines(c, ordered: true);
      expect(c.text, '1. a\n2. b');
    });

    test('setBlockquoteLines prefixes lines once', () {
      final c = TextEditingController(text: 'kutip\nsudah');
      c.selection = const TextSelection(baseOffset: 0, extentOffset: 11);
      MarkdownSyntax.setBlockquoteLines(c);
      expect(c.text, '> kutip\n> sudah');
      MarkdownSyntax.setBlockquoteLines(c);
      expect(c.text, '> kutip\n> sudah');
    });

    test('wrapOrFenceCode wraps inline selection', () {
      final c = TextEditingController(text: 'pakai foo di sini');
      c.selection = const TextSelection(baseOffset: 6, extentOffset: 9);
      MarkdownSyntax.wrapOrFenceCode(c);
      expect(c.text, 'pakai `foo` di sini');
    });

    test('wrapOrFenceCode fences multi-line selection', () {
      final c = TextEditingController(text: 'a\nb');
      c.selection = const TextSelection(baseOffset: 0, extentOffset: 3);
      MarkdownSyntax.wrapOrFenceCode(c);
      expect(c.text, '```\na\nb\n```');
    });

    test('insertTable inserts header separator and body rows', () {
      final c = TextEditingController();
      MarkdownSyntax.insertTable(
        c,
        headers: const ['Kolom 1', 'Kolom 2'],
        bodyRows: 2,
      );
      expect(
        c.text,
        '\n| Kolom 1 | Kolom 2 |\n| --- | --- |\n|   |   |\n|   |   |\n',
      );
    });

    test('insertHorizontalRule inserts markdown hr', () {
      final c = TextEditingController(text: 'atas');
      c.selection = const TextSelection.collapsed(offset: 4);
      MarkdownSyntax.insertHorizontalRule(c);
      expect(c.text, 'atas\n---\n');
    });

    test('strikethrough wrap uses tilde markers', () {
      final c = TextEditingController(text: 'lama');
      c.selection = const TextSelection(baseOffset: 0, extentOffset: 4);
      MarkdownSyntax.wrap(c, left: '~~', right: '~~');
      expect(c.text, '~~lama~~');
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
