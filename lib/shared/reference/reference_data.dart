import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cache/cache_entry.dart';
import '../../core/cache/cache_key.dart';
import '../../core/cache/cache_providers.dart';
import '../../core/network/network_providers.dart';

/// Data referensi statis (kelas kata, bahasa) yang dipakai lintas fitur untuk
/// mengubah id mentah menjadi label yang bisa dibaca manusia.
///
/// Dipisah dari page agar tidak ada lagi fetch `/word-classes` yang diduplikasi
/// di tiap layar. Cache `referenceStatic`: segar 24 jam, basi maks 7 hari.
class ReferenceItem {
  const ReferenceItem({
    required this.id,
    required this.name,
    this.code = '',
    this.alias,
    this.nativeName,
  });

  final String id;
  final String name;
  final String code;
  final String? alias;
  final String? nativeName;

  /// `Nama (alias)` bila alias ada - mengikuti gaya picker yang sudah dipakai.
  String get displayLabel =>
      (alias == null || alias!.isEmpty) ? name : '$name ($alias)';

  /// Nama saja; untuk bahasa lebih enak pakai nama lokal bila tersedia.
  String get readableName => nativeName?.trim().isNotEmpty == true
      ? '$name · ${nativeName!.trim()}'
      : name;
}

Future<Map<String, dynamic>> _fetchReference(
  Ref ref,
  String path,
  String label,
) async {
  final cache = ref.watch(cachedJsonClientProvider);
  final dio = ref.watch(dioProvider);
  final key = buildCacheKey(method: 'GET', path: path);
  final data = await cache.getOrFetch(
    key: key,
    cacheClass: CacheClass.referenceStatic,
    fetch: () async {
      final resp = await dio.get<dynamic>(path);
      final body = resp.data;
      if (body is! Map) {
        throw StateError('Envelope $label tidak valid');
      }
      return Map<String, dynamic>.from(body);
    },
  );
  return data;
}

List<ReferenceItem> _parseItems(
  Map<String, dynamic> data, {
  required bool withAlias,
  required bool withNativeName,
}) {
  final arr = data['data'];
  if (arr is! List) return const [];
  final items = <ReferenceItem>[];
  for (final raw in arr.whereType<Map>()) {
    final id = raw['id']?.toString() ?? '';
    if (id.isEmpty) continue;
    items.add(
      ReferenceItem(
        id: id,
        name: raw['name']?.toString().trim().isNotEmpty == true
            ? raw['name'].toString().trim()
            : '(tanpa nama)',
        code: raw['code']?.toString() ?? '',
        alias: withAlias ? raw['alias']?.toString() : null,
        nativeName: withNativeName ? raw['native_name']?.toString() : null,
      ),
    );
  }
  return List.unmodifiable(items);
}

final referenceWordClassesProvider = FutureProvider<List<ReferenceItem>>((
  ref,
) async {
  final data = await _fetchReference(
    ref,
    '/api/v1/word-classes',
    'word-classes',
  );
  return _parseItems(data, withAlias: true, withNativeName: false);
});

final referenceLanguagesProvider = FutureProvider<List<ReferenceItem>>((
  ref,
) async {
  final data = await _fetchReference(
    ref,
    '/api/v1/languages?is_active=true',
    'languages',
  );
  return _parseItems(data, withAlias: false, withNativeName: true);
});

/// Cari label dari daftar referensi; null saat id tidak ditemukan.
///
/// `byCode` dipakai untuk kasus id sudah berupa kode (mis. `nomina`) dan untuk
/// pencocokan longg pada form koreksi.
ReferenceItem? findReferenceItem(
  List<ReferenceItem> items,
  String? idOrCode, {
  bool byCode = false,
}) {
  final needle = idOrCode?.trim();
  if (needle == null || needle.isEmpty || items.isEmpty) return null;
  final lower = needle.toLowerCase();
  for (final item in items) {
    if (item.id == needle) return item;
  }
  for (final item in items) {
    if (item.code.toLowerCase() == lower) return item;
  }
  if (byCode) {
    for (final item in items) {
      if (item.name.toLowerCase() == lower) return item;
    }
  }
  return null;
}

/// Nama kelas kata dari id; null kalau tidak ketemu (baris disembunyikan, bukan
/// menampilkan ULID mentah ke user).
String? wordClassNameFrom(List<ReferenceItem> classes, String? id) =>
    findReferenceItem(classes, id)?.displayLabel;

/// Nama bahasa dari id; null kalau tidak ketemu.
String? languageNameFrom(List<ReferenceItem> languages, String? id) =>
    findReferenceItem(languages, id)?.readableName;

/// Panaskan kedua daftar sebelum layar review dibuka supaya swipe pertama sudah
/// menampilkan nama, bukan ULID. Kegagalan diamkan - preview tetap jalan dengan
/// fallback menyembunyikan baris.
void prefetchReferenceData(WidgetRef ref) {
  ref.read(referenceWordClassesProvider);
  ref.read(referenceLanguagesProvider);
}
