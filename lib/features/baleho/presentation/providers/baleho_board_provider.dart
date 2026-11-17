import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/baleho_api.dart';
import '../../domain/baleho_models.dart';

final balehoApiProvider = Provider<BalehoApi>(
  (ref) => BalehoApi(ref.watch(dioProvider)),
);

/// Slot tetap slide 2: curated deep link internal (tidak dijual).
class BalehoSlide2Labels {
  const BalehoSlide2Labels({
    required this.weeklyTitle,
    required this.weeklyCta,
    required this.usahaTitle,
    required this.usahaCta,
    required this.acaraTitle,
    required this.acaraCta,
    required this.wisataTitle,
    required this.wisataCta,
    required this.karyaTitle,
    required this.karyaCta,
    required this.ensiklopediaTitle,
    required this.ensiklopediaCta,
    required this.kamusTitle,
    required this.kamusCta,
  });

  final String weeklyTitle;
  final String weeklyCta;
  final String usahaTitle;
  final String usahaCta;
  final String acaraTitle;
  final String acaraCta;
  final String wisataTitle;
  final String wisataCta;
  final String karyaTitle;
  final String karyaCta;
  final String ensiklopediaTitle;
  final String ensiklopediaCta;
  final String kamusTitle;
  final String kamusCta;
}

BalehoPlacement _fixedTile({
  required String id,
  required int col,
  required int row,
  required int w,
  required int h,
  required String title,
  required String ctaLabel,
  required String path,
}) {
  return BalehoPlacement(
    id: id,
    col: col,
    row: row,
    w: w,
    h: h,
    status: 'live',
    frames: [
      BalehoFrame(
        id: '${id}_f0',
        mediaType: 'text_cta',
        title: title,
        ctaLabel: ctaLabel,
        actionType: 'in_app',
        actionPayload: path,
      ),
    ],
  );
}

List<BalehoPlacement> balehoSlide2Curated(BalehoSlide2Labels labels) {
  return [
    _fixedTile(
      id: BalehoBoard.weeklyLeaderboardPlacementId,
      col: 0,
      row: 0,
      w: 4,
      h: 1,
      title: labels.weeklyTitle,
      ctaLabel: labels.weeklyCta,
      path: BalehoBoard.weeklyLeaderboardPath,
    ),
    _fixedTile(
      id: 'baleho_fixed_usaha',
      col: 0,
      row: 1,
      w: 2,
      h: 1,
      title: labels.usahaTitle,
      ctaLabel: labels.usahaCta,
      path: '/usaha',
    ),
    _fixedTile(
      id: 'baleho_fixed_acara',
      col: 2,
      row: 1,
      w: 2,
      h: 1,
      title: labels.acaraTitle,
      ctaLabel: labels.acaraCta,
      path: '/acara',
    ),
    _fixedTile(
      id: 'baleho_fixed_wisata',
      col: 0,
      row: 2,
      w: 2,
      h: 1,
      title: labels.wisataTitle,
      ctaLabel: labels.wisataCta,
      path: '/explore/wisata',
    ),
    _fixedTile(
      id: 'baleho_fixed_karya',
      col: 2,
      row: 2,
      w: 2,
      h: 1,
      title: labels.karyaTitle,
      ctaLabel: labels.karyaCta,
      path: '/explore/karya',
    ),
    _fixedTile(
      id: 'baleho_fixed_ensiklopedia',
      col: 0,
      row: 3,
      w: 2,
      h: 1,
      title: labels.ensiklopediaTitle,
      ctaLabel: labels.ensiklopediaCta,
      path: '/explore/ensiklopedia',
    ),
    _fixedTile(
      id: 'baleho_fixed_kamus',
      col: 2,
      row: 3,
      w: 2,
      h: 1,
      title: labels.kamusTitle,
      ctaLabel: labels.kamusCta,
      path: '/words',
    ),
  ];
}

/// Rect curated slide 2 (tanpa label) - untuk filter overlap API.
const _kSlide2Rects = <(int col, int row, int w, int h)>[
  (0, 0, 4, 1),
  (0, 1, 2, 1),
  (2, 1, 2, 1),
  (0, 2, 2, 1),
  (2, 2, 2, 1),
  (0, 3, 2, 1),
  (2, 3, 2, 1),
];

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
