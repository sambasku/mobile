import 'package:dio/dio.dart';

import '../../../../core/constants/contributors_data_url.dart';

/// Exception data kontributor tidak sesuai schema (`data/contributor.json`).
class ContributorsException implements Exception {
  const ContributorsException(this.message);

  final String message;

  @override
  String toString() => 'ContributorsException: $message';
}

/// Satu entri kontributor: nama + peran + keterangan keterlibatan.
class ContributorEntry {
  const ContributorEntry({
    required this.id,
    required this.name,
    required this.roles,
    required this.since,
    required this.note,
    this.avatarUrl,
    this.url,
  });

  final String id;
  final String name;
  final List<String> roles;
  final String? avatarUrl;
  final String? url;

  /// ISO date (YYYY-MM-DD), dasar sorting terlama dulu.
  final String since;
  final String note;

  static ContributorEntry? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final since = json['since'];
    final note = json['note'];
    final rawRoles = json['roles'];
    if (id is! String || name is! String) return null;
    if (since is! String || note is! String) return null;
    if (rawRoles is! List ||
        rawRoles.isEmpty ||
        rawRoles.any((r) => r is! String)) {
      return null;
    }
    return ContributorEntry(
      id: id,
      name: name,
      roles: List<String>.from(rawRoles),
      avatarUrl: json['avatarUrl'] is String ? json['avatarUrl'] as String : null,
      url: json['url'] is String ? json['url'] as String : null,
      since: since,
      note: note,
    );
  }
}

/// Remote datasource data kontributor dari CDN.
///
/// Sama pola dengan [SponsorsRemoteDatasource]: fetch jsDelivr via Dio,
/// parse minimal, throw = caller yang putuskan soft-fail (sembunyikan
/// section).
class ContributorsRemoteDatasource {
  ContributorsRemoteDatasource(this._dio, {String? configUrl})
      : _configUrl = configUrl ?? kContributorsDataUrl;

  final Dio _dio;

  final String _configUrl;

  /// Fetch + parse `contributor.json`, sudah ter-sort `since` ascending.
  Future<List<ContributorEntry>> fetchContributors() async {
    final resp = await _dio.get<dynamic>(
      _configUrl,
      options: Options(receiveTimeout: const Duration(seconds: 5)),
    );
    final body = resp.data;
    if (body is! Map) {
      throw const ContributorsException('Body contributor.json bukan object');
    }
    final rawList = body['contributors'];
    if (rawList is! List) {
      throw const ContributorsException('Field "contributors" tidak valid');
    }
    final parsed = <ContributorEntry>[];
    for (final item in rawList) {
      if (item is! Map) continue;
      final entry = ContributorEntry.fromJson(
        Map<String, dynamic>.from(item),
      );
      if (entry != null) parsed.add(entry);
    }
    // Terlama dulu; tie = urutan file dipertahankan (sort stabil Dart).
    parsed.sort((a, b) => a.since.compareTo(b.since));
    return parsed;
  }
}
