/// Statistik dashboard - kontrak GET /api/v1/admin/dashboard/stats
/// (view model camelCase setelah normalisasi wire).
library;

typedef WordStatusKey = String;
typedef ContributionStatusKey = String;
typedef AppRoleKey = String;

class ActivityDailyPoint {
  const ActivityDailyPoint({
    required this.date,
    required this.contributions,
    required this.votes,
    required this.comments,
    required this.newUsers,
  });

  /// 'YYYY-MM-DD' WIB
  final String date;
  final int contributions;
  final int votes;
  final int comments;
  final int newUsers;
}

class ProblemSourceCounts {
  const ProblemSourceCounts({required this.open, required this.closed});

  final int open;
  final int closed;
}

class ProblemsStats {
  const ProblemsStats({
    required this.open,
    required this.closed,
    required this.bySource,
  });

  final int open;
  final int closed;
  final ProblemSourceByKind bySource;
}

class ProblemSourceByKind {
  const ProblemSourceByKind({
    required this.bugReports,
    required this.wordReports,
  });

  final ProblemSourceCounts bugReports;
  final ProblemSourceCounts wordReports;
}

class VerifierApplicationsStats {
  const VerifierApplicationsStats({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  final int pending;
  final int approved;
  final int rejected;
}

class WordsStats {
  const WordsStats({
    required this.total,
    required this.verified,
    required this.deleted,
    required this.byStatus,
  });

  final int total;
  final int verified;
  final int deleted;
  final Map<WordStatusKey, int> byStatus;
}

class ContributionsStats {
  const ContributionsStats({
    required this.total,
    required this.byStatus,
  });

  final int total;
  final Map<ContributionStatusKey, int> byStatus;
}

class UsersStats {
  const UsersStats({
    required this.active,
    required this.onlineRecently,
    required this.byRole,
  });

  final int active;

  /// Presence piggyback: last_seen dalam 15 menit.
  final int onlineRecently;
  final Map<AppRoleKey, int> byRole;
}

class ActivityStats {
  const ActivityStats({
    required this.auditLogsLast7Days,
    required this.dailyLast30Days,
  });

  final int auditLogsLast7Days;

  /// 30 hari WIB inklusif; hari kosong = 0.
  final List<ActivityDailyPoint> dailyLast30Days;
}

class DashboardStats {
  const DashboardStats({
    required this.words,
    required this.contributions,
    required this.users,
    required this.activity,
    required this.problems,
    required this.verifierApplications,
  });

  final WordsStats words;
  final ContributionsStats contributions;
  final UsersStats users;
  final ActivityStats activity;
  final ProblemsStats problems;
  final VerifierApplicationsStats verifierApplications;
}

const wordStatusLabels = <String, String>{
  'draft': 'Draft (tidak tayang)',
  'pending_review': 'Menunggu Review',
  'published': 'Published',
  'rejected': 'Ditolak',
};

const contributionStatusLabels = <String, String>{
  'pending': 'Menunggu',
  'approved': 'Disetujui',
  'rejected': 'Ditolak',
  'corrected': 'Dikoreksi',
};

const roleLabelsShort = <String, String>{
  'root': 'Root',
  'admin': 'Admin',
  'editor': 'Editor',
  'reviewer': 'Verifikator',
  'contributor': 'Kontributor',
};

const searchMissDirectionLabels = <String, String>{
  'lemma': 'Lemma',
  'meaning': 'Makna',
  'example': 'Contoh',
};
