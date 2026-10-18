import 'cache_entry.dart';

/// Matriks TTL L1 kanonik (§5.5 MOBILE_LOCAL_STRATEGI).
abstract final class CachePolicy {
  /// Bump = wipe total L1 (response cache) saat open berikutnya. Naikkan tiap
  /// data CDN mengubah URL/konten yang di-cache 24 jam (referenceStatic) -
  /// tanpa bump, `places.json` lama dengan URL gambar usang tetap dipakai.
  static const int schemaVersion = 2;
  static const int maxBudgetBytes = 40 * 1024 * 1024; // ~40 MB (dalam rentang 32-50)

  static Duration freshFor(CacheClass cacheClass, {DateTime? now}) {
    final n = now ?? DateTime.now();
    switch (cacheClass) {
      case CacheClass.referenceStatic:
        return const Duration(hours: 24);
      case CacheClass.dictionaryDetail:
        return const Duration(minutes: 5);
      case CacheClass.feedList:
        return const Duration(minutes: 2);
      case CacheClass.wordOfDay:
        // Segar sampai ganti hari lokal, capped 1 jam.
        final untilMidnight = DateTime(n.year, n.month, n.day + 1).difference(n);
        final cap = const Duration(hours: 1);
        return untilMidnight < cap ? untilMidnight : cap;
      case CacheClass.search:
        return const Duration(minutes: 1);
      case CacheClass.negative404:
        return const Duration(minutes: 2);
    }
  }

  static Duration staleMaxFor(CacheClass cacheClass) {
    switch (cacheClass) {
      case CacheClass.referenceStatic:
        return const Duration(days: 7);
      case CacheClass.dictionaryDetail:
        return const Duration(hours: 24);
      case CacheClass.feedList:
        return const Duration(hours: 1);
      case CacheClass.wordOfDay:
        return const Duration(hours: 24);
      case CacheClass.search:
        return const Duration(minutes: 30);
      case CacheClass.negative404:
        // Tanpa SWR: staleMax = fresh.
        return const Duration(minutes: 2);
    }
  }

  static CacheFreshness freshness(
    CacheEntry entry,
    CacheClass cacheClass, {
    DateTime? now,
  }) {
    final n = (now ?? DateTime.now()).toUtc();
    final age = n.difference(entry.cachedAt.toUtc());
    if (age < Duration.zero) return CacheFreshness.fresh;
    final fresh = freshFor(cacheClass, now: n.toLocal());
    final staleMax = staleMaxFor(cacheClass);
    if (age <= fresh) return CacheFreshness.fresh;
    if (cacheClass == CacheClass.negative404) return CacheFreshness.expired;
    if (age <= staleMax) return CacheFreshness.stale;
    return CacheFreshness.expired;
  }
}
