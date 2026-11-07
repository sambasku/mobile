/// Argumen navigasi ke form tulis/balas pantun (via GoRouter `extra`).
///
/// [parentId] null = pantun pembuka baru. Non-null = balasan ke pantun induk
/// itu (API flat). [quoteId] menentukan cuplikan yang ditampilkan dan key
/// draf lokal: `'root'` = induk, selain itu = id balasan yang di-tap.
class PantunComposeArgs {
  const PantunComposeArgs({
    this.parentId,
    this.quoteId = quoteRoot,
    this.quoteLines,
    this.quoteAuthorLabel,
  });

  /// Token quote untuk pantun induk (bukan id balasan).
  static const quoteRoot = 'root';

  final String? parentId;

  /// `'root'` atau id balasan. Diabaikan bila [parentId] null.
  final String quoteId;

  /// 4 baris cuplikan (dari detail sebelum push). Null = resolve di compose.
  final List<String>? quoteLines;

  /// Label penulis cuplikan (displayName/username).
  final String? quoteAuthorLabel;

  bool get isReply => parentId != null && parentId!.isNotEmpty;

  /// Id efektif untuk key draf / query: selalu `'root'` atau id balasan.
  String get normalizedQuoteId {
    if (!isReply) return quoteRoot;
    final q = quoteId.trim();
    if (q.isEmpty || q == quoteRoot) return quoteRoot;
    return q;
  }
}
