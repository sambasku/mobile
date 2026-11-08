import 'package:dio/dio.dart';

/// Tim inti (users.is_team) dari API.
class AboutTeamMember {
  const AboutTeamMember({
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.teamAs,
    this.teamNote,
  });

  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? teamAs;
  final String? teamNote;

  static AboutTeamMember? fromJson(Map<String, dynamic> json) {
    final username = json['username'];
    final displayName = json['display_name'];
    if (username is! String || displayName is! String) return null;
    return AboutTeamMember(
      username: username,
      displayName: displayName,
      avatarUrl: json['avatar_url'] is String
          ? json['avatar_url'] as String
          : null,
      teamAs: json['team_as'] is String ? json['team_as'] as String : null,
      teamNote: json['team_note'] is String
          ? json['team_note'] as String
          : null,
    );
  }
}

/// Nama flat kontributor (role contributor).
class AboutContributorName {
  const AboutContributorName({
    required this.username,
    required this.displayName,
  });

  final String username;
  final String displayName;

  static AboutContributorName? fromJson(Map<String, dynamic> json) {
    final username = json['username'];
    final displayName = json['display_name'];
    if (username is! String || displayName is! String) return null;
    return AboutContributorName(username: username, displayName: displayName);
  }
}

class AboutContributorsPage {
  const AboutContributorsPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    required this.total,
  });

  final List<AboutContributorName> items;
  final String? nextCursor;
  final bool hasMore;
  final int total;
}

/// Verifikator (role reviewer) - avatar + nama.
class AboutVerifier {
  const AboutVerifier({
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  final String username;
  final String displayName;
  final String? avatarUrl;

  static AboutVerifier? fromJson(Map<String, dynamic> json) {
    final username = json['username'];
    final displayName = json['display_name'];
    if (username is! String || displayName is! String) return null;
    return AboutVerifier(
      username: username,
      displayName: displayName,
      avatarUrl: json['avatar_url'] is String
          ? json['avatar_url'] as String
          : null,
    );
  }
}

/// Sponsor dari API (mirror CDN fields).
class AboutSponsorship {
  const AboutSponsorship({
    required this.id,
    required this.name,
    required this.since,
    required this.note,
    this.username,
    this.description,
    this.logoUrl,
    this.url,
  });

  final String id;
  final String name;
  final String since;
  final String note;
  final String? username;
  final String? description;
  final String? logoUrl;
  final String? url;

  static AboutSponsorship? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final since = json['since'];
    final note = json['note'];
    if (id is! String || name is! String) return null;
    if (since is! String || note is! String) return null;
    return AboutSponsorship(
      id: id,
      name: name,
      since: since,
      note: note,
      username: _cleanUsername(json['username']),
      description: json['description'] is String
          ? json['description'] as String
          : null,
      logoUrl: json['logo_url'] is String ? json['logo_url'] as String : null,
      url: _cleanUrl(json['url']),
    );
  }
}

String? _cleanUsername(Object? raw) {
  if (raw is! String) return null;
  final t = raw.trim();
  return t.isEmpty ? null : t;
}

String? _cleanUrl(Object? raw) {
  if (raw is! String) return null;
  final t = raw.trim();
  if (t.isEmpty || t == '-') return null;
  return t;
}

/// Fetch daftar About dari API app (bukan CDN).
class AboutApiDatasource {
  AboutApiDatasource(this._dio);

  final Dio _dio;

  Future<List<AboutTeamMember>> fetchTeam() async {
    final resp = await _dio.get<dynamic>('/api/v1/about/team');
    return _parseItems(resp.data, 'items', AboutTeamMember.fromJson);
  }

  Future<List<AboutSponsorship>> fetchSponsorships() async {
    final resp = await _dio.get<dynamic>('/api/v1/about/sponsorships');
    return _parseItems(resp.data, 'items', AboutSponsorship.fromJson);
  }

  Future<List<AboutVerifier>> fetchVerifiers() async {
    final resp = await _dio.get<dynamic>('/api/v1/users/verifiers');
    return _parseItems(resp.data, 'items', AboutVerifier.fromJson);
  }

  Future<AboutContributorsPage> fetchContributors({
    int limit = 50,
    String? cursor,
  }) async {
    final resp = await _dio.get<dynamic>(
      '/api/v1/users/contributors',
      queryParameters: {'limit': limit, 'cursor': ?cursor},
    );
    final body = resp.data;
    if (body is! Map) {
      throw const FormatException('Body contributors bukan object');
    }
    final data = body['data'];
    if (data is! Map) {
      throw const FormatException('Field data tidak valid');
    }
    final rawList = data['items'];
    final items = <AboutContributorName>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is! Map) continue;
        final parsed = AboutContributorName.fromJson(
          Map<String, dynamic>.from(item),
        );
        if (parsed != null) items.add(parsed);
      }
    }
    final next = data['next_cursor'];
    final totalRaw = data['total'];
    return AboutContributorsPage(
      items: items,
      nextCursor: next is String ? next : null,
      hasMore: data['has_more'] == true,
      total: totalRaw is num ? totalRaw.toInt() : items.length,
    );
  }

  List<T> _parseItems<T>(
    dynamic body,
    String key,
    T? Function(Map<String, dynamic>) parse,
  ) {
    if (body is! Map) return const [];
    final data = body['data'];
    if (data is! Map) return const [];
    final rawList = data[key];
    if (rawList is! List) return const [];
    final out = <T>[];
    for (final item in rawList) {
      if (item is! Map) continue;
      final parsed = parse(Map<String, dynamic>.from(item));
      if (parsed != null) out.add(parsed);
    }
    return out;
  }
}
