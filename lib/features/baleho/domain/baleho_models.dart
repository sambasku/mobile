/// Model wire Baleho (selaras docs/BALEHO.md + API).
class BalehoBoard {
  const BalehoBoard({
    required this.slide,
    required this.cols,
    required this.rows,
    required this.placements,
  });

  final int slide;
  final int cols;
  final int rows;
  final List<BalehoPlacement> placements;

  static const prototypeCols = 4;
  static const prototypeRows = 6;
  static const maxW = 4;
  static const maxH = 2;

  /// Path coming soon papan peringkat (slide 2, slot 4x1 tetap).
  static const weeklyLeaderboardPath = '/baleho/peringkat-mingguan';
  static const weeklyLeaderboardPlacementId = 'baleho_fixed_weekly_leaderboard';

  /// Detail snapshot riwayat satu minggu ISO (`YYYY-Www`).
  static String weeklyLeaderboardHistoryWeekPath(String weekId) =>
      '$weeklyLeaderboardPath/riwayat/$weekId';

  factory BalehoBoard.fromJson(Map<String, dynamic> json) {
    final items = json['placements'];
    // Ukuran papan = konstanta klien (4x6). Jangan ikut `rows`/`cols` API
    // lama yang masih 5 - sel ekstra harus tetap bisa dipilih.
    return BalehoBoard(
      slide: (json['slide'] as num?)?.toInt() ?? 1,
      cols: prototypeCols,
      rows: prototypeRows,
      placements: [
        for (final raw in (items is List ? items : const []))
          if (raw is Map)
            BalehoPlacement.fromJson(Map<String, dynamic>.from(raw)),
      ],
    );
  }

  /// Board kosong saat API gagal / belum migrate - sel tetap bisa dipilih.
  factory BalehoBoard.empty(int slide) => BalehoBoard(
        slide: slide,
        cols: prototypeCols,
        rows: prototypeRows,
        placements: const [],
      );

  /// True jika setiap sel tertutup placement (tidak ada ruang pesan).
  bool get isFullyOccupied {
    final taken = List.generate(rows, (_) => List<bool>.filled(cols, false));
    for (final p in placements) {
      for (var r = p.row; r < p.row + p.h; r++) {
        for (var c = p.col; c < p.col + p.w; c++) {
          if (r >= 0 && r < rows && c >= 0 && c < cols) {
            taken[r][c] = true;
          }
        }
      }
    }
    for (final row in taken) {
      for (final cell in row) {
        if (!cell) return false;
      }
    }
    return true;
  }
}

class BalehoPlacement {
  const BalehoPlacement({
    required this.id,
    required this.col,
    required this.row,
    required this.w,
    required this.h,
    required this.status,
    required this.frames,
    this.isOwnerPending = false,
  });

  final String id;
  final int col;
  final int row;
  final int w;
  final int h;
  final String status;
  final bool isOwnerPending;
  final List<BalehoFrame> frames;

  factory BalehoPlacement.fromJson(Map<String, dynamic> json) {
    final frames = json['frames'];
    return BalehoPlacement(
      id: '${json['id']}',
      col: (json['col'] as num?)?.toInt() ?? 0,
      row: (json['row'] as num?)?.toInt() ?? 0,
      w: (json['w'] as num?)?.toInt() ?? 1,
      h: (json['h'] as num?)?.toInt() ?? 1,
      status: '${json['status'] ?? 'live'}',
      isOwnerPending: json['is_owner_pending'] == true,
      frames: [
        for (final raw in (frames is List ? frames : const []))
          if (raw is Map) BalehoFrame.fromJson(Map<String, dynamic>.from(raw)),
      ],
    );
  }
}

class BalehoFrame {
  const BalehoFrame({
    required this.id,
    required this.mediaType,
    required this.actionType,
    required this.actionPayload,
    this.mediaUrl,
    this.title,
    this.body,
    this.ctaLabel,
  });

  final String id;
  final String mediaType;
  final String? mediaUrl;
  final String? title;
  final String? body;
  final String? ctaLabel;
  final String actionType;
  final String actionPayload;

  factory BalehoFrame.fromJson(Map<String, dynamic> json) {
    return BalehoFrame(
      id: '${json['id']}',
      mediaType: '${json['media_type'] ?? 'text_cta'}',
      mediaUrl: json['media_url'] as String?,
      title: json['title'] as String?,
      body: json['body'] as String?,
      ctaLabel: json['cta_label'] as String?,
      actionType: '${json['action_type'] ?? 'in_app'}',
      actionPayload: '${json['action_payload'] ?? ''}',
    );
  }
}

class BalehoSelection {
  const BalehoSelection({
    required this.col,
    required this.row,
    required this.w,
    required this.h,
  });

  final int col;
  final int row;
  final int w;
  final int h;
}
