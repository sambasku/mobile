class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.username,
    this.displayName,
    this.avatarUrl,
    required this.submittedPoints,
    required this.approvedPoints,
    required this.verificationPoints,
    required this.combined,
    required this.isVerifier,
  });

  final int rank;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final int submittedPoints;
  final int approvedPoints;
  final int verificationPoints;
  final int combined;
  final bool isVerifier;

  /// Fallback backward-compat untuk kode/UI lama.
  int get contributions => submittedPoints;
  int get verifications => verificationPoints;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    // Fallback: wire baru submitted_points/approved_points/verification_points,
    // fallback wire/snapshot CDN lama: contributions/verifications.
    final submitted = (json['submitted_points'] as num?)?.toInt() ??
        (json['contributions'] as num?)?.toInt() ??
        0;
    final approved = (json['approved_points'] as num?)?.toInt() ?? 0;
    final verif = (json['verification_points'] as num?)?.toInt() ??
        (json['verifications'] as num?)?.toInt() ??
        0;
    return LeaderboardEntry(
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      username: '${json['username'] ?? ''}',
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      submittedPoints: submitted,
      approvedPoints: approved,
      verificationPoints: verif,
      combined: (json['combined'] as num?)?.toInt() ?? 0,
      isVerifier: json['is_verifier'] == true,
    );
  }
}

class LeaderboardCdnMeta {
  const LeaderboardCdnMeta({this.current, this.weekly});

  final String? current;
  final String? weekly;

  factory LeaderboardCdnMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LeaderboardCdnMeta();
    return LeaderboardCdnMeta(
      current: json['current'] as String?,
      weekly: json['weekly'] as String?,
    );
  }
}

class LeaderboardWeekSnapshot {
  const LeaderboardWeekSnapshot({
    required this.weekId,
    required this.entries,
    this.startsAt,
    this.endsAt,
    this.finalized = false,
  });

  final String weekId;
  final List<LeaderboardEntry> entries;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool finalized;

  factory LeaderboardWeekSnapshot.fromCdnJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    final entries = <LeaderboardEntry>[];
    if (rawEntries is List) {
      for (final raw in rawEntries) {
        if (raw is Map) {
          entries.add(
            LeaderboardEntry.fromJson(Map<String, dynamic>.from(raw)),
          );
        }
      }
    }
    return LeaderboardWeekSnapshot(
      weekId: '${json['week_id'] ?? ''}',
      entries: entries,
      startsAt: DateTime.tryParse('${json['starts_at'] ?? ''}'),
      endsAt: DateTime.tryParse('${json['ends_at'] ?? ''}'),
      finalized: json['finalized'] == true,
    );
  }
}

class WeeklyLeaderboardViewData {
  const WeeklyLeaderboardViewData({
    required this.entries,
    this.weekId,
    this.resetsAt,
    this.cdnCurrentUrl,
    this.cdnWeeklyPatternUrl,
  });

  final List<LeaderboardEntry> entries;
  final String? weekId;
  final DateTime? resetsAt;
  final String? cdnCurrentUrl;
  final String? cdnWeeklyPatternUrl;
}