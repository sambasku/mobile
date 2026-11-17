import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/baleho_api.dart';
import '../../domain/baleho_models.dart';

final balehoApiProvider = Provider<BalehoApi>(
  (ref) => BalehoApi(ref.watch(dioProvider)),
);

/// Slot tetap slide 2: 4x1 Papan Peringkat Mingguan → coming soon.
BalehoPlacement balehoWeeklyLeaderboardPlacement({
  required String title,
  required String ctaLabel,
}) {
  return BalehoPlacement(
    id: BalehoBoard.weeklyLeaderboardPlacementId,
    col: 0,
    row: 0,
    w: 4,
    h: 1,
    status: 'live',
    frames: [
      BalehoFrame(
        id: '${BalehoBoard.weeklyLeaderboardPlacementId}_f0',
        mediaType: 'text_cta',
        title: title,
        ctaLabel: ctaLabel,
        actionType: 'in_app',
        actionPayload: BalehoBoard.weeklyLeaderboardPath,
      ),
    ],
  );
}

bool balehoOverlapsFixedWeeklySlot(BalehoPlacement p) {
  return p.row <= 0 && p.row + p.h > 0 && p.col < 4 && p.col + p.w > 0;
}

BalehoBoard balehoBoardWithSlide2Fixed(
  BalehoBoard board, {
  required String title,
  required String ctaLabel,
}) {
  if (board.slide != 2) return board;
  final fixed = balehoWeeklyLeaderboardPlacement(
    title: title,
    ctaLabel: ctaLabel,
  );
  final rest = [
    for (final p in board.placements)
      if (p.id != fixed.id && !balehoOverlapsFixedWeeklySlot(p)) p,
  ];
  return BalehoBoard(
    slide: board.slide,
    cols: board.cols,
    rows: board.rows,
    placements: [fixed, ...rest],
  );
}

/// Board dari API. Gagal jaringan/migrate → board kosong.
final balehoBoardProvider =
    FutureProvider.autoDispose.family<BalehoBoard, int>((ref, slide) async {
  final api = ref.watch(balehoApiProvider);
  try {
    return await api.fetchBoard(slide);
  } on DioException {
    return BalehoBoard.empty(slide);
  } catch (_) {
    return BalehoBoard.empty(slide);
  }
});
