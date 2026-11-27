import 'package:flutter/foundation.dart';

import 'oss_direct_packages.dart';

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

/// Nama paket langsung dari pubspec, diurutkan. Siap untuk daftar tanpa I/O.
List<String> directOssPackageNames({
  Set<String> packageNames = kDirectOssPackages,
}) {
  return packageNames.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

Future<Map<String, OssLicense>>? _cachedMap;
Set<String>? _cachedKeys;

/// Kosongkan cache (test).
@visibleForTesting
void resetOssLicenseCache() {
  _cachedMap = null;
  _cachedKeys = null;
}

/// Peta lisensi paket langsung. Hasil di-cache; scan Registry hanya sekali.
///
/// Setiap beberapa entri melepaskan frame supaya UI tidak macet.
Future<Map<String, OssLicense>> loadOssLicenseMap({
  Set<String> packageNames = kDirectOssPackages,
}) {
  if (_cachedMap != null &&
      _cachedKeys != null &&
      _cachedKeys!.length == packageNames.length &&
      packageNames.every(_cachedKeys!.contains)) {
    return _cachedMap!;
  }
  _cachedKeys = Set<String>.from(packageNames);
  return _cachedMap = _buildOssLicenseMap(packageNames);
}

Future<Map<String, OssLicense>> _buildOssLicenseMap(
  Set<String> packageNames,
) async {
  final grouped = <String, StringBuffer>{};
  var seen = 0;
  await for (final entry in LicenseRegistry.licenses) {
    seen += 1;
    // Lepas frame supaya daftar/detail tetap bisa digambar.
    if (seen % 24 == 0) {
      await Future<void>.delayed(Duration.zero);
    }
    final body = _entryText(entry);
    if (body.isEmpty) continue;
    for (final package in entry.packages) {
      final name = package.trim();
      if (name.isEmpty || !packageNames.contains(name)) continue;
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
  return {
    for (final e in grouped.entries)
      e.key: OssLicense(
        name: e.key,
        text: e.value.toString(),
        kind: ossLicenseKind(e.value.toString()),
      ),
  };
}

/// Satu paket dari cache / scan. Dipakai halaman detail.
Future<OssLicense?> loadOssLicense(
  String name, {
  Set<String> packageNames = kDirectOssPackages,
}) async {
  final map = await loadOssLicenseMap(packageNames: packageNames);
  return map[name];
}

/// Kumpulkan lisensi paket langsung (untuk test / pemakaian lama).
Future<List<OssLicense>> collectOssLicenses({
  Set<String> packageNames = kDirectOssPackages,
}) async {
  final map = await loadOssLicenseMap(packageNames: packageNames);
  final names = map.keys.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return [for (final name in names) map[name]!];
}
