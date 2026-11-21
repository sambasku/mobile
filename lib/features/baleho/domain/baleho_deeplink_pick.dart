/// Hasil pilih deeplink / entity untuk frame Baleho.
class BalehoDeeplinkPick {
  const BalehoDeeplinkPick({
    required this.path,
    this.entityType,
    this.entityId,
  });

  final String path;

  /// Wire API: `place` | `event` | `usaha` | `karya`.
  final String? entityType;
  final String? entityId;
}
