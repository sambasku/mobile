/// Meta rilis dataset yang terpasang / dari pointer remote.
class LemmaReleaseMeta {
  const LemmaReleaseMeta({
    required this.releaseVersion,
    required this.schemaVersion,
    this.minAppVersion,
    this.channel,
    this.sha256,
    this.databaseUrl,
    this.databaseSize,
    this.releasedAt,
  });

  final int releaseVersion;
  final int schemaVersion;
  final String? minAppVersion;
  final String? channel;
  final String? sha256;
  final String? databaseUrl;
  final int? databaseSize;
  final String? releasedAt;

  factory LemmaReleaseMeta.fromActiveJson(Map<String, dynamic> json) {
    final database = json['database'];
    final db = database is Map<String, dynamic> ? database : const {};
    return LemmaReleaseMeta(
      releaseVersion: _asInt(json['release_version']) ?? 0,
      schemaVersion: _asInt(json['schema_version']) ?? 0,
      minAppVersion: json['min_app_version']?.toString(),
      channel: json['channel']?.toString(),
      sha256: db['sha256']?.toString(),
      databaseUrl: db['url']?.toString(),
      databaseSize: _asInt(db['size']),
      releasedAt: json['released_at']?.toString(),
    );
  }

  factory LemmaReleaseMeta.fromBundleMeta(Map<String, dynamic> json) {
    return LemmaReleaseMeta(
      releaseVersion: _asInt(json['release_version']) ?? 0,
      schemaVersion: _asInt(json['schema_version']) ?? 1,
    );
  }

  static int? _asInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }
}
