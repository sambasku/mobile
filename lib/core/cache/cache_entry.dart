/// Scope entry L1 - logout hanya wipe [CacheScope.user].
enum CacheScope {
  public,
  user,
}

/// Kelas data untuk matriks TTL §5.5.
enum CacheClass {
  /// languages, word-classes, dialects
  referenceStatic,

  /// words/:id, lemma (transitional)
  dictionaryDetail,

  /// words/latest, words page
  feedList,

  /// words/today
  wordOfDay,

  /// words/search (transitional)
  search,

  /// 404 lemma/id singkat
  negative404,
}

/// Metadata index tanpa body - untuk list di explorer / diagnostics.
class CacheEntryMeta {
  const CacheEntryMeta({
    required this.key,
    required this.cachedAt,
    required this.lastAccess,
    required this.sizeBytes,
    required this.scope,
    required this.schemaVersion,
  });

  final String key;
  final DateTime cachedAt;
  final DateTime lastAccess;
  final int sizeBytes;
  final CacheScope scope;
  final int schemaVersion;

  static CacheEntryMeta? fromIndexMap(String key, dynamic indexRaw) {
    if (indexRaw is! Map) return null;
    final cachedAt = DateTime.tryParse('${indexRaw['cachedAt']}');
    final lastAccess = DateTime.tryParse('${indexRaw['lastAccess']}');
    if (cachedAt == null || lastAccess == null) return null;
    final scopeName = '${indexRaw['scope']}';
    final scope = CacheScope.values.firstWhere(
      (s) => s.name == scopeName,
      orElse: () => CacheScope.public,
    );
    final size = indexRaw['size'];
    final schema = indexRaw['schemaVersion'];
    return CacheEntryMeta(
      key: key,
      cachedAt: cachedAt.toUtc(),
      lastAccess: lastAccess.toUtc(),
      sizeBytes: size is int ? size : int.tryParse('$size') ?? 0,
      scope: scope,
      schemaVersion: schema is int ? schema : int.tryParse('$schema') ?? 0,
    );
  }
}

/// Hasil baca store sebelum policy diterapkan.
class CacheEntry {
  const CacheEntry({
    required this.key,
    required this.body,
    required this.cachedAt,
    required this.lastAccess,
    required this.sizeBytes,
    required this.scope,
    required this.schemaVersion,
  });

  final String key;
  final String body;
  final DateTime cachedAt;
  final DateTime lastAccess;
  final int sizeBytes;
  final CacheScope scope;
  final int schemaVersion;

  CacheEntryMeta get meta => CacheEntryMeta(
    key: key,
    cachedAt: cachedAt,
    lastAccess: lastAccess,
    sizeBytes: sizeBytes,
    scope: scope,
    schemaVersion: schemaVersion,
  );

  Map<String, dynamic> toIndexMap() => {
    'cachedAt': cachedAt.toIso8601String(),
    'lastAccess': lastAccess.toIso8601String(),
    'size': sizeBytes,
    'scope': scope.name,
    'schemaVersion': schemaVersion,
  };

  static CacheEntry? fromBoxes({
    required String key,
    required dynamic indexRaw,
    required dynamic bodyRaw,
  }) {
    if (indexRaw is! Map || bodyRaw is! String || bodyRaw.isEmpty) {
      return null;
    }
    final cachedAt = DateTime.tryParse('${indexRaw['cachedAt']}');
    final lastAccess = DateTime.tryParse('${indexRaw['lastAccess']}');
    if (cachedAt == null || lastAccess == null) return null;
    final scopeName = '${indexRaw['scope']}';
    final scope = CacheScope.values.firstWhere(
      (s) => s.name == scopeName,
      orElse: () => CacheScope.public,
    );
    final size = indexRaw['size'];
    final schema = indexRaw['schemaVersion'];
    return CacheEntry(
      key: key,
      body: bodyRaw,
      cachedAt: cachedAt.toUtc(),
      lastAccess: lastAccess.toUtc(),
      sizeBytes: size is int ? size : int.tryParse('$size') ?? bodyRaw.length,
      scope: scope,
      schemaVersion: schema is int ? schema : int.tryParse('$schema') ?? 0,
    );
  }
}

enum CacheFreshness {
  /// age <= fresh → sajikan, 0 hit API
  fresh,

  /// fresh < age <= staleMax → sajikan + revalidate background
  stale,

  /// age > staleMax → jangan sajikan; fetch sync
  expired,
}
