import 'package:flutter/foundation.dart';

/// Satu pustaka pihak ketiga beserta teks lisensi yang dibundel Flutter.
class OssLicense {
  const OssLicense({required this.name, required this.text, this.kind});

  final String name;
  final String text;

  /// Kode pendek (MIT, Apache-2.0, ...) bila judul lisensi dikenali.
  final String? kind;
}

/// Jenis lisensi dari awal teks. Null bila judul tidak dikenali.
String? ossLicenseKind(String text) {
  final head = text.length > 600 ? text.substring(0, 600) : text;
  final lower = head.toLowerCase();
  if (lower.contains('gnu lesser general public license') ||
      lower.contains('gnu library general public license')) {
    return 'LGPL';
  }
  if (lower.contains('gnu general public license')) {
    if (lower.contains('version 3')) return 'GPL-3.0';
    if (lower.contains('version 2')) return 'GPL-2.0';
    return 'GPL';
  }
  if (lower.contains('gnu affero general public license')) return 'AGPL';
  if (lower.contains('apache license')) return 'Apache-2.0';
  if (lower.contains('mozilla public license')) return 'MPL-2.0';
  if (lower.contains('mit license') ||
      lower.contains('permission is hereby granted, free of charge')) {
    return 'MIT';
  }
  if (lower.contains('isc license')) return 'ISC';
  if (lower.contains('the unlicense') || lower.contains('unlicense')) {
    return 'Unlicense';
  }
  if (lower.contains('bsd')) return 'BSD';
  return null;
}

String _entryText(LicenseEntry entry) {
  if (entry is LicenseEntryWithLineBreaks) return entry.text.trim();
  final buf = StringBuffer();
  for (final paragraph in entry.paragraphs) {
    if (buf.isNotEmpty) buf.writeln();
    buf.write(paragraph.text);
  }
  return buf.toString().trim();
}

/// Kumpulkan lisensi yang didaftarkan Flutter (SDK + paket pub).
Future<List<OssLicense>> collectOssLicenses() async {
  final grouped = <String, StringBuffer>{};
  await for (final entry in LicenseRegistry.licenses) {
    final body = _entryText(entry);
    if (body.isEmpty) continue;
    for (final package in entry.packages) {
      final name = package.trim();
      if (name.isEmpty) continue;
      final existing = grouped[name];
      if (existing == null) {
        grouped[name] = StringBuffer(body);
      } else if (!existing.toString().contains(body)) {
        existing
          ..writeln()
          ..writeln()
          ..write(body);
      }
    }
  }
  final names = grouped.keys.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return [
    for (final name in names) _licenseFor(name, grouped[name]!.toString()),
  ];
}

OssLicense _licenseFor(String name, String text) {
  return OssLicense(name: name, text: text, kind: ossLicenseKind(text));
}
