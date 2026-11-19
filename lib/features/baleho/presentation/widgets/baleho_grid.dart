import 'dart:async';

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/baleho_models.dart';

typedef BalehoCellTap = void Function(BalehoPlacement placement, BalehoFrame frame);
typedef BalehoSelectionChanged = void Function(BalehoSelection? selection);
typedef BalehoVacantTap = void Function(int col, int row);

/// Ukuran (w,h) yang muat dari sudut kiri-atas [col],[row] tanpa bentrok.
List<(int, int)> balehoValidSizes({
  required BalehoBoard board,
  required int col,
  required int row,
  required bool Function(int c, int r) isOccupied,
}) {
  final out = <(int, int)>[];
  for (var h = 1; h <= BalehoBoard.maxH; h++) {
    for (var w = 1; w <= BalehoBoard.maxW; w++) {
      if (col + w > board.cols || row + h > board.rows) continue;
      var ok = true;
      for (var r = row; r < row + h && ok; r++) {
        for (var c = col; c < col + w; c++) {
          if (isOccupied(c, r)) {
            ok = false;
            break;
          }
        }
      }
      if (ok) out.add((w, h));
    }
  }
  return out;
}

/// Papan 4xN: tap 1 = jangkar, tap 2 = perluas; drag dari jangkar; chip ukuran.
class BalehoGrid extends StatefulWidget {
  const BalehoGrid({
    super.key,
    required this.board,
    required this.sellable,
    this.selection,
    this.onSelectionChanged,
    this.onPlacementTap,
    this.onVacantTap,
    this.onHeldTap,
  });

  final BalehoBoard board;
  final bool sellable;
  final BalehoSelection? selection;
  final BalehoSelectionChanged? onSelectionChanged;
  final BalehoCellTap? onPlacementTap;
  /// Mode lihat: ketuk area kosong = aksi sama dengan "Ingin tampil di sini?".
  final BalehoVacantTap? onVacantTap;
  /// Ketuk sel "Dipesan" (pending/awaiting tanpa konten publik).
  final VoidCallback? onHeldTap;

  @override
  State<BalehoGrid> createState() => _BalehoGridState();
}

class _BalehoGridState extends State<BalehoGrid> {
  /// Sudut jangkar (tap pertama). Drag/tap kedua dihitung dari sini.
  int? _anchorCol;
  int? _anchorRow;
  BalehoSelection? _draft;
  var _dragging = false;

  bool _isOccupied(int col, int row) {
    for (final p in widget.board.placements) {
      if (col >= p.col &&
          col < p.col + p.w &&
          row >= p.row &&
          row < p.row + p.h) {
        return true;
      }
    }
    return false;
  }

  (int, int) _cellFromLocal(Offset local, Size size) {
    final cellW = size.width / widget.board.cols;
    final cellH = size.height / widget.board.rows;
    final col = (local.dx / cellW).floor().clamp(0, widget.board.cols - 1);
    final row = (local.dy / cellH).floor().clamp(0, widget.board.rows - 1);
    return (col, row);
  }

  BalehoSelection? _selectionFromCorners(int c0, int r0, int c1, int r1) {
    var col = c0 < c1 ? c0 : c1;
    var row = r0 < r1 ? r0 : r1;
    var w = (c0 - c1).abs() + 1;
    var h = (r0 - r1).abs() + 1;
    if (w > BalehoBoard.maxW) w = BalehoBoard.maxW;
    if (h > BalehoBoard.maxH) h = BalehoBoard.maxH;
    if (col + w > widget.board.cols) col = widget.board.cols - w;
    if (row + h > widget.board.rows) row = widget.board.rows - h;
    for (var r = row; r < row + h; r++) {
      for (var c = col; c < col + w; c++) {
        if (_isOccupied(c, r)) return null;
      }
    }
    return BalehoSelection(col: col, row: row, w: w, h: h);
  }

  void _emit(BalehoSelection? s) {
    widget.onSelectionChanged?.call(s);
  }

  void _clear() {
    setState(() {
      _anchorCol = null;
      _anchorRow = null;
      _draft = null;
      _dragging = false;
    });
    _emit(null);
  }

  void _setAnchor(int col, int row) {
    final s = BalehoSelection(col: col, row: row, w: 1, h: 1);
    setState(() {
      _anchorCol = col;
      _anchorRow = row;
      _draft = null;
      _dragging = false;
    });
    _emit(s);
  }

  @override
  void didUpdateWidget(covariant BalehoGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parent clear (Batalkan) → reset jangkar.
    if (widget.selection == null && oldWidget.selection != null) {
      _anchorCol = null;
      _anchorRow = null;
      _draft = null;
      _dragging = false;
    } else if (widget.selection != null &&
        _anchorCol == null &&
        _anchorRow == null) {
      // Seleksi dari chip ukuran di parent - jangkar = sudut kiri atas.
      _anchorCol = widget.selection!.col;
      _anchorRow = widget.selection!.row;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final sel = _draft ?? widget.selection;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cell = width / widget.board.cols;
        final height = cell * widget.board.rows;
        final size = Size(width, height);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) {
            if (_dragging) return;
            final (col, row) = _cellFromLocal(details.localPosition, size);
            final occupied = _isOccupied(col, row);
            if (occupied) {
              // Mode pilih: abaikan. Mode lihat: tap ditangani _PlacementCell.
              return;
            }
            if (!widget.sellable) {
              // Mode lihat: area kosong = sama dengan "Ingin tampil di sini?".
              widget.onVacantTap?.call(col, row);
              return;
            }

            // Belum ada jangkar → tap 1 = pilih 1x1.
            if (_anchorCol == null || _anchorRow == null) {
              _setAnchor(col, row);
              return;
            }

            // Ketuk ulang jangkar (masih 1x1) = batalkan.
            final current = widget.selection;
            if (current != null &&
                current.w == 1 &&
                current.h == 1 &&
                col == _anchorCol &&
                row == _anchorRow) {
              _clear();
              return;
            }

            // Tap 2: perluas dari jangkar ke sel ini.
            final next = _selectionFromCorners(_anchorCol!, _anchorRow!, col, row);
            if (next == null) return;
            setState(() => _draft = null);
            // Pakai sudut kiri atas hasil supaya chip ukuran konsisten.
            setState(() {
              _anchorCol = next.col;
              _anchorRow = next.row;
            });
            _emit(next);
          },
          onPanStart: widget.sellable
              ? (d) {
                  final (col, row) = _cellFromLocal(d.localPosition, size);
                  // Seret dari slot terisi diabaikan - jangan buka konten.
                  if (_isOccupied(col, row)) return;
                  _dragging = true;
                  // Drag mulai: jangkar = sel awal drag, atau jangkar yang ada.
                  if (_anchorCol == null || _anchorRow == null) {
                    _anchorCol = col;
                    _anchorRow = row;
                  }
                  final s = BalehoSelection(
                    col: _anchorCol!,
                    row: _anchorRow!,
                    w: 1,
                    h: 1,
                  );
                  setState(() => _draft = s);
                  _emit(s);
                }
              : null,
          onPanUpdate: widget.sellable
              ? (d) {
                  if (!_dragging || _anchorCol == null || _anchorRow == null) {
                    return;
                  }
                  final (c1, r1) = _cellFromLocal(d.localPosition, size);
                  final next = _selectionFromCorners(
                    _anchorCol!,
                    _anchorRow!,
                    c1,
                    r1,
                  );
                  if (next == null) return;
                  setState(() => _draft = next);
                  _emit(next);
                }
              : null,
          onPanEnd: widget.sellable
              ? (_) {
                  final finalSel = _draft ?? widget.selection;
                  setState(() {
                    _dragging = false;
                    _draft = null;
                    if (finalSel != null) {
                      _anchorCol = finalSel.col;
                      _anchorRow = finalSel.row;
                    }
                  });
                }
              : null,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                for (var r = 0; r < widget.board.rows; r++)
                  for (var c = 0; c < widget.board.cols; c++)
                    if (!_isOccupied(c, r))
                      Positioned(
                        left: c * cell,
                        top: r * cell,
                        width: cell,
                        height: cell,
                        child: Builder(
                          builder: (context) {
                            final covered = sel != null &&
                                c >= sel.col &&
                                c < sel.col + sel.w &&
                                r >= sel.row &&
                                r < sel.row + sel.h;
                            final dimOthers = sel != null && !covered;
                            return Opacity(
                              opacity: dimOthers ? 0.4 : 1,
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colors.border,
                                  ),
                                  color: theme.colors.secondary.withValues(
                                    alpha: covered ? 0.12 : 0.28,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                for (final p in widget.board.placements)
                  Positioned(
                    left: p.col * cell,
                    top: p.row * cell,
                    width: p.w * cell,
                    height: p.h * cell,
                    child: p.id == BalehoBoard.weeklyLeaderboardPlacementId
                        ? _WeeklyLeaderboardTile(
                            enabled: !widget.sellable,
                            onTap: () {
                              if (p.frames.isEmpty) return;
                              widget.onPlacementTap?.call(p, p.frames.first);
                            },
                          )
                        // Pending/awaiting tanpa frame = hold slot untuk orang
                        // lain. Jangan render seperti iklan "Promosi".
                        : p.frames.isEmpty
                            ? _HeldSlotCell(onTap: widget.onHeldTap)
                            : _PlacementCell(
                                placement: p,
                                enabled: !widget.sellable,
                                onPlacementTap: widget.onPlacementTap,
                              ),
                  ),
                if (sel != null)
                  Positioned(
                    left: sel.col * cell,
                    top: sel.row * cell,
                    width: sel.w * cell,
                    height: sel.h * cell,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colors.primary,
                          width: 2,
                        ),
                        color: theme.colors.primary.withValues(alpha: 0.18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${sel.w}x${sel.h}',
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Banner tetap 4x1: Peringkat Mingguan.
class _WeeklyLeaderboardTile extends StatelessWidget {
  const _WeeklyLeaderboardTile({
    required this.onTap,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final bool enabled;

  /// Samakan dengan [VersionBanner] (`Colors.orange`).
  static const _versionOrange = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colors.border),
          color: theme.colors.background,
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: _versionOrange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  FLucideIcons.crown,
                  size: 20,
                  color: Color(0xFFFFFFFF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.balehoWeeklyLeaderboardTitle,
                      softWrap: true,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.balehoWeeklyLeaderboardCta,
                      softWrap: true,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.foreground.withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FLucideIcons.chevronRight,
                size: 18,
                color: theme.colors.foreground.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sel terkunci tanpa konten (pending_review / awaiting_payment bagi viewer
/// lain). Harus beda visual dari iklan live supaya tidak dikira sudah tayang.
class _HeldSlotCell extends StatelessWidget {
  const _HeldSlotCell({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colors.border.withValues(alpha: 0.7),
          ),
          color: theme.colors.secondary.withValues(alpha: 0.18),
        ),
        alignment: Alignment.center,
        child: Text(
          l10n.balehoSlotHeld,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PlacementCell extends StatefulWidget {
  const _PlacementCell({
    required this.placement,
    this.enabled = true,
    this.onPlacementTap,
  });

  final BalehoPlacement placement;
  final bool enabled;
  final BalehoCellTap? onPlacementTap;

  @override
  State<_PlacementCell> createState() => _PlacementCellState();
}

class _PlacementCellState extends State<_PlacementCell> {
  int _frameIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _armTimer();
  }

  @override
  void didUpdateWidget(covariant _PlacementCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.placement.id != widget.placement.id) {
      _frameIndex = 0;
      _armTimer();
    }
  }

  void _armTimer() {
    _timer?.cancel();
    final frames = widget.placement.frames;
    if (frames.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _frameIndex = (_frameIndex + 1) % frames.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final frames = widget.placement.frames;
    final frame = frames.isEmpty ? null : frames[_frameIndex % frames.length];
    final parent = frames.isNotEmpty ? frames.first : frame;
    final pending = widget.placement.isOwnerPending;
    // Judul/CTA dari parent; child hanya media carousel.
    final copyText =
        parent?.title ?? parent?.ctaLabel ?? l10n.balehoPromoSlide;
    final titleRaw = parent?.title?.trim();
    final hasMedia = frame?.mediaUrl != null &&
        (frame!.mediaType == 'image' || frame.mediaType == 'video');
    final titleChip = hasMedia &&
            titleRaw != null &&
            titleRaw.isNotEmpty
        ? titleRaw
        : null;

    return GestureDetector(
      onTap: widget.enabled && frame != null
          ? () => widget.onPlacementTap?.call(widget.placement, frame)
          : null,
      child: Semantics(
        label: titleChip ?? copyText,
        button: widget.enabled && frame != null,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colors.border),
            color: theme.colors.background,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasMedia)
                Image.network(
                  frame!.mediaUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      copyText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (titleChip != null)
                Positioned(
                  left: 2,
                  right: 2,
                  bottom: 2,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        child: Text(
                          titleChip,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.body.xs.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (pending)
                Positioned(
                  right: 2,
                  top: 2,
                  // Chip compact: FBadge default terlalu besar untuk sel 1x1
                  // (terpotong Clip.antiAlias).
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      child: Text(
                        l10n.balehoPendingBadge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.secondaryForeground,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
