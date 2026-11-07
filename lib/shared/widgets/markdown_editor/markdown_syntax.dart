import 'package:flutter/widgets.dart';

/// Helper sisip/bungkus sintaks Markdown pada [TextEditingController.selection].
class MarkdownSyntax {
  MarkdownSyntax._();

  static final RegExp _headingPrefix = RegExp(r'^#{1,6}\s+');
  static final RegExp _bulletPrefix = RegExp(r'^[-*+]\s+');
  static final RegExp _orderedPrefix = RegExp(r'^\d+\.\s+');
  static final RegExp _quotePrefix = RegExp(r'^>\s?');

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

  /// Akhir baris (indeks setelah karakter terakhir baris, sebelum `\n` atau EOF).
  static int _lineEnd(String text, int offset) {
    if (offset >= text.length) return text.length;
    final i = text.indexOf('\n', offset);
    return i < 0 ? text.length : i;
  }

  /// Rentang baris yang disentuh seleksi (atau baris kursor).
  static (int start, int end) _affectedLineRange(
    String text,
    TextSelection selection,
  ) {
    final rawStart = selection.isValid
        ? selection.start.clamp(0, text.length)
        : text.length;
    final rawEnd = selection.isValid
        ? selection.end.clamp(0, text.length)
        : text.length;
    final a = rawStart <= rawEnd ? rawStart : rawEnd;
    final b = rawStart <= rawEnd ? rawEnd : rawStart;
    // Seleksi yang berakhir tepat di awal baris berikutnya tidak ikut baris itu.
    final endProbe = b > a && b > 0 && text[b - 1] == '\n' ? b - 1 : b;
    return (_lineStart(text, a), _lineEnd(text, endProbe));
  }

  /// Ubah tiap baris di rentang seleksi lewat [mapLine] (index 0-based).
  static void _mapAffectedLines(
    TextEditingController controller,
    String Function(int index, String line) mapLine,
  ) {
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final (rangeStart, rangeEnd) = _affectedLineRange(text, selection);
    final block = text.substring(rangeStart, rangeEnd);
    final lines = block.split('\n');
    final mapped = <String>[];
    for (var i = 0; i < lines.length; i++) {
      mapped.add(mapLine(i, lines[i]));
    }
    final replacement = mapped.join('\n');
    final newText = text.replaceRange(rangeStart, rangeEnd, replacement);
    final cursor = rangeStart + replacement.length;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }

  static String _stripLinePrefixes(String line) {
    var out = line;
    out = out.replaceFirst(_headingPrefix, '');
    out = out.replaceFirst(_bulletPrefix, '');
    out = out.replaceFirst(_orderedPrefix, '');
    return out;
  }

  /// Set heading level 1-3 di tiap baris seleksi (strip prefix heading/list dulu).
  static void setHeadingLine(
    TextEditingController controller, {
    required int level,
  }) {
    final clamped = level.clamp(1, 3);
    final prefix = '${'#' * clamped} ';
    _mapAffectedLines(controller, (_, line) {
      final body = _stripLinePrefixes(line);
      return '$prefix$body';
    });
  }

  /// Set daftar bullet (`- `) atau bernomor (`1. `) di tiap baris seleksi.
  static void setListLines(
    TextEditingController controller, {
    required bool ordered,
  }) {
    _mapAffectedLines(controller, (index, line) {
      final body = _stripLinePrefixes(line);
      if (ordered) {
        return '${index + 1}. $body';
      }
      return '- $body';
    });
  }

  /// Sisip `> ` di awal tiap baris seleksi (tidak dobel bila sudah quote).
  static void setBlockquoteLines(TextEditingController controller) {
    _mapAffectedLines(controller, (_, line) {
      if (_quotePrefix.hasMatch(line)) return line;
      return '> $line';
    });
  }

  /// Seleksi berisi newline → fenced code; selain itu bungkus inline `` ` ``.
  static void wrapOrFenceCode(TextEditingController controller) {
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;
    final start = selection.isValid
        ? selection.start.clamp(0, text.length)
        : text.length;
    final end = selection.isValid
        ? selection.end.clamp(0, text.length)
        : text.length;
    final selected = text.substring(start, end);
    if (selected.contains('\n')) {
      final fenced = '```\n$selected\n```';
      final newText = text.replaceRange(start, end, fenced);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: start,
          extentOffset: start + fenced.length,
        ),
      );
      return;
    }
    wrap(controller, left: '`', right: '`');
  }

  /// Sisip skeleton tabel Markdown (header + separator + [bodyRows] baris kosong).
  static void insertTable(
    TextEditingController controller, {
    required List<String> headers,
    int bodyRows = 2,
  }) {
    assert(headers.isNotEmpty);
    final cols = headers.length;
    final header = '| ${headers.join(' | ')} |';
    final sep = '| ${List.filled(cols, '---').join(' | ')} |';
    final emptyCell = List.filled(cols, ' ').join(' | ');
    final body = List.generate(bodyRows, (_) => '| $emptyCell |').join('\n');
    final snippet = '\n$header\n$sep\n$body\n';
    insert(controller, snippet);
  }

  /// Sisip garis horizontal Markdown.
  static void insertHorizontalRule(TextEditingController controller) {
    insert(controller, '\n---\n');
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
