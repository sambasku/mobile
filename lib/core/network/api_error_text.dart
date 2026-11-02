/// Pesan dari envelope API. `details` didahulukan supaya field yang ditolak
/// (misalnya `word_type`) terlihat, bukan hanya kalimat umum.
String apiErrorText(Object? data, String fallback) {
  if (data is! Map) return fallback;
  final details = data['details'];
  if (details is List) {
    final lines = <String>[];
    for (final raw in details) {
      if (raw is! Map) continue;
      final field = raw['field']?.toString().trim() ?? '';
      final message = raw['message']?.toString().trim() ?? '';
      if (message.isEmpty) continue;
      lines.add(field.isEmpty ? message : '$field: $message');
    }
    if (lines.isNotEmpty) return lines.join('\n');
  }
  final message = data['message']?.toString().trim() ?? '';
  if (message.isNotEmpty) return message;
  return fallback;
}
