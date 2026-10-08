import 'package:dio/dio.dart';

import '../../../../core/constants/sponsors_data_url.dart';

/// Exception data sponsor tidak sesuai schema (`data/sponsors.json`).
class SponsorsException implements Exception {
  const SponsorsException(this.message);

  final String message;

  @override
  String toString() => 'SponsorsException: $message';
}

/// Satu entri sponsor: nama + logo + keterangan dukungan.
/// Nominal dana TIDAK ada di sini; catatannya di Kas Publik (github-pages).
class SponsorEntry {
  const SponsorEntry({
    required this.id,
    required this.name,
    required this.since,
    required this.note,
    this.sambaskuUsername,
    this.description,
    this.logoUrl,
    this.url,
  });

  final String id;

  /// Username akun SambasKu (bukan platform lain) - tap tile membuka profil
  /// publik in-app (#100). Opsional; tanpa ini tile tidak interaktif.
  final String? sambaskuUsername;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? url;

  /// ISO date (YYYY-MM-DD), dasar sorting terlama dulu.
  final String since;
  final String note;

  static SponsorEntry? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final since = json['since'];
    final note = json['note'];
    if (id is! String || name is! String) return null;
    if (since is! String || note is! String) return null;
    return SponsorEntry(
      id: id,
      sambaskuUsername:
          json['sambaskuUsername'] is String &&
              (json['sambaskuUsername'] as String).trim().isNotEmpty
          ? (json['sambaskuUsername'] as String).trim()
          : null,
      name: name,
      description: json['description'] is String
          ? json['description'] as String
          : null,
      logoUrl: json['logoUrl'] is String ? json['logoUrl'] as String : null,
      url: json['url'] is String ? json['url'] as String : null,
      since: since,
      note: note,
    );
  }
}

/// Remote datasource data sponsor dari CDN.
///
/// Sama pola dengan [CardImagesRemoteDatasource]: fetch jsDelivr via Dio,
/// parse minimal, throw = caller yang putuskan soft-fail (sembunyikan
/// section).
class SponsorsRemoteDatasource {
  SponsorsRemoteDatasource(this._dio, {String? configUrl})
    : _configUrl = configUrl ?? kSponsorsDataUrl;

  final Dio _dio;

  final String _configUrl;

  /// Fetch + parse `sponsors.json`, sudah ter-sort `since` ascending.
  Future<List<SponsorEntry>> fetchSponsors() async {
    final resp = await _dio.get<dynamic>(
      _configUrl,
      options: Options(receiveTimeout: const Duration(seconds: 5)),
    );
    final body = resp.data;
    if (body is! Map) {
      throw const SponsorsException('Body sponsors.json bukan object');
    }
    final rawList = body['sponsors'];
    if (rawList is! List) {
      throw const SponsorsException('Field "sponsors" tidak valid');
    }
    final parsed = <SponsorEntry>[];
    for (final item in rawList) {
      if (item is! Map) continue;
      final entry = SponsorEntry.fromJson(Map<String, dynamic>.from(item));
      if (entry != null) parsed.add(entry);
    }
    // Terlama dulu; tie = urutan file dipertahankan (sort stabil Dart).
    parsed.sort((a, b) => a.since.compareTo(b.since));
    return parsed;
  }
}
