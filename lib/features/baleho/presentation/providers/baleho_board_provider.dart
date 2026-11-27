import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/baleho_api.dart';
import '../../domain/baleho_models.dart';

final balehoApiProvider = Provider<BalehoApi>(
  (ref) => BalehoApi(ref.watch(dioProvider)),
);

/// Slot tetap slide 2: peringkat 4x1.
class BalehoSlide2Labels {
  const BalehoSlide2Labels({
    required this.weeklyTitle,
    required this.weeklyCta,
  });

  final String weeklyTitle;
  final String weeklyCta;
}

BalehoPlacement _weeklyLeaderboardTile(BalehoSlide2Labels labels) {
  const id = BalehoBoard.weeklyLeaderboardPlacementId;
  return BalehoPlacement(
    id: id,
    col: 0,
    row: 0,
    w: 4,
    h: 1,
    status: 'live',
    frames: [
      BalehoFrame(
        id: '${id}_f0',
        mediaType: 'text_cta',
        title: labels.weeklyTitle,
        ctaLabel: labels.weeklyCta,
        actionType: 'in_app',
        actionPayload: BalehoBoard.weeklyLeaderboardPath,
      ),
    ],
  );
}

List<BalehoPlacement> balehoSlide2Curated(BalehoSlide2Labels labels) {
  return [_weeklyLeaderboardTile(labels)];
}

/// Rect curated slide 2 - banner peringkat 4x1.
const _kSlide2Rects = <(int col, int row, int w, int h)>[(0, 0, 4, 1)];

bool balehoOverlapsSlide2Curated(BalehoPlacement p) {
  for (final (col, row, w, h) in _kSlide2Rects) {
    final overlapCol = p.col < col + w && p.col + p.w > col;
    final overlapRow = p.row < row + h && p.row + p.h > row;
    if (overlapCol && overlapRow) return true;
  }
  return false;
}

BalehoBoard balehoBoardWithSlide2Fixed(
  BalehoBoard board, {
  required BalehoSlide2Labels labels,
}) {
  if (board.slide != 2) return board;
  final curated = balehoSlide2Curated(labels);
  final curatedIds = {for (final p in curated) p.id};
  final rest = [
    for (final p in board.placements)
      if (!curatedIds.contains(p.id) && !balehoOverlapsSlide2Curated(p)) p,
  ];
  return BalehoBoard(
    slide: board.slide,
    cols: board.cols,
    rows: board.rows,
    placements: [...curated, ...rest],
  );
}

/// Board dari API. Gagal jaringan/migrate → board kosong.
final balehoBoardProvider = FutureProvider.autoDispose.family<BalehoBoard, int>(
  (ref, slide) async {
    final api = ref.watch(balehoApiProvider);
    try {
      return await api.fetchBoard(slide);
    } on DioException {
      return BalehoBoard.empty(slide);
    } catch (_) {
      return BalehoBoard.empty(slide);
    }
  },
);

/// Tarif IDR per sel 1x1 per hari (app_settings, default 3000).
final balehoPricePerCellPerDayProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  return ref.watch(balehoApiProvider).fetchPricePerCellPerDay();
});
