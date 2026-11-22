class UserWeekPointHistory {
  const UserWeekPointHistory({
    required this.weekId,
    required this.submittedPoints,
    required this.approvedPoints,
    required this.verificationPoints,
    required this.combined,
    required this.xpAtWeekEnd,
    required this.createdAt,
  });

  final String weekId;
  final int submittedPoints;
  final int approvedPoints;
  final int verificationPoints;
  final int combined;
  final int xpAtWeekEnd;
  final DateTime createdAt;

  factory UserWeekPointHistory.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['created_at'] as String?;
    final createdAt = rawCreatedAt == null || rawCreatedAt.isEmpty
        ? DateTime.now()
        : (DateTime.tryParse(rawCreatedAt) ?? DateTime.now());

    return UserWeekPointHistory(
      weekId: (json['week_id'] as String?) ?? '',
      submittedPoints: (json['submitted_points'] as num?)?.toInt() ?? 0,
      approvedPoints: (json['approved_points'] as num?)?.toInt() ?? 0,
      verificationPoints: (json['verification_points'] as num?)?.toInt() ?? 0,
      combined: (json['combined'] as num?)?.toInt() ?? 0,
      xpAtWeekEnd: (json['xp_at_week_end'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
    );
  }
}

class UserPointsHistoryViewData {
  const UserPointsHistoryViewData({
    required this.username,
    required this.history,
  });

  final String username;
  final List<UserWeekPointHistory> history;

  factory UserPointsHistoryViewData.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'];
    final items = <UserWeekPointHistory>[];
    if (rawHistory is List) {
      for (final item in rawHistory) {
        if (item is Map) {
          items.add(UserWeekPointHistory.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return UserPointsHistoryViewData(
      username: (json['username'] as String?) ?? '',
      history: items,
    );
  }
}
