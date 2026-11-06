import 'package:flutter/widgets.dart';

/// Helper sisip/bungkus sintaks Markdown pada [TextEditingController.selection].
class MarkdownSyntax {
  MarkdownSyntax._();

  /// Bungkus seleksi dengan [left] dan [right]. Bila tidak ada seleksi,
  /// sisip pasangan dan letakkan kursor di tengah.
  static void wrap(
    TextEditingController controller, {
    required String left,
    required String right,
  }) {
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final start = selection.start.clamp(0, text.length);
    final end = selection.end.clamp(0, text.length);
    final selected = text.substring(start, end);

    if (selected.isEmpty) {
      final inserted = '$left$right';
      final newText = text.replaceRange(start, end, inserted);
      final cursor = start + left.length;
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursor),
      );
      return;
    }

    final wrapped = '$left$selected$right';
    final newText = text.replaceRange(start, end, wrapped);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start,
        extentOffset: start + wrapped.length,
      ),
    );
  }

  /// Sisip teks di posisi kursor (atau ganti seleksi).
  static void insert(TextEditingController controller, String snippet) {
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final start = selection.isValid
        ? selection.start.clamp(0, text.length)
        : text.length;
    final end = selection.isValid
        ? selection.end.clamp(0, text.length)
        : text.length;
    final newText = text.replaceRange(start, end, snippet);
    final cursor = start + snippet.length;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  /// Awal baris yang berisi [offset] (aman untuk offset 0).
  static int _lineStart(String text, int offset) {
    if (offset <= 0) return 0;
    final i = text.lastIndexOf('\n', offset - 1);
    return i < 0 ? 0 : i + 1;
  }

  /// Sisip heading `## ` di awal baris kursor.
  static void insertHeadingLine(TextEditingController controller) {
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final offset = selection.isValid
        ? selection.baseOffset.clamp(0, text.length)
        : text.length;
    final lineStart = _lineStart(text, offset);
    const prefix = '## ';
    if (text.substring(lineStart).startsWith(prefix)) return;
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    final cursor = offset + prefix.length;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  /// Sisip `- ` di awal baris kursor (bullet).
  static void insertBulletLine(TextEditingController controller) {
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final offset = selection.isValid
        ? selection.baseOffset.clamp(0, text.length)
        : text.length;
    final lineStart = _lineStart(text, offset);
    const prefix = '- ';
    if (text.substring(lineStart).startsWith(prefix)) return;
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    final cursor = offset + prefix.length;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  /// `true` hanya untuk URL https yang punya host.
  static bool isHttpsUrl(String raw) {
    final uri = Uri.tryParse(raw.trim());
    return uri != null && uri.isScheme('https') && uri.host.isNotEmpty;
  }

  /// Sisip tautan `[label](url)`. Seleksi yang ada diganti.
  static void insertLink(
    TextEditingController controller, {
    required String label,
    required String url,
  }) {
    final href = url.trim();
    final cleaned = label.trim().replaceAll(RegExp(r'[\[\]]'), '');
    final text = cleaned.isEmpty ? href : cleaned;
    insert(controller, '[$text]($href)');
  }

  /// Sisip gambar Markdown `![alt](url)`.
  static void insertImage(
    TextEditingController controller, {
    required String url,
    required String alt,
  }) {
    final safeAlt = alt.trim().isEmpty ? 'img' : alt.trim();
    insert(controller, '\n![$safeAlt]($url)\n');
  }
}
