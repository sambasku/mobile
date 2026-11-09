import 'package:flutter/gestures.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/jinye_models.dart';
import 'jinye_link_lemma_sheet.dart';

/// Body Jinye dengan highlight span lemma.
///
/// - Tap span ter-link → detail kata
/// - Long-press span → [onLinkLongPress]
/// - Tap kata belum ter-link (bila [onUnlinkedWordTap] ada) → callback span kata itu
class JinyeLemmaBody extends StatefulWidget {
  const JinyeLemmaBody({
    super.key,
    required this.body,
    required this.links,
    this.style,
    this.onLinkLongPress,
    this.onUnlinkedWordTap,
  });

  final String body;
  final List<JinyeLemmaLink> links;
  final TextStyle? style;
  final void Function(JinyeLemmaLink link)? onLinkLongPress;

  /// Owner: tap kata belum tertaut → aksi tautkan untuk span itu.
  final void Function(JinyeSpanSelection span)? onUnlinkedWordTap;

  @override
  State<JinyeLemmaBody> createState() => _JinyeLemmaBodyState();
}

enum _PieceKind { link, token, plain }

class _Piece {
  const _Piece({
    required this.kind,
    required this.start,
    required this.end,
    this.link,
    this.token,
  });

  final _PieceKind kind;
  final int start;
  final int end;
  final JinyeLemmaLink? link;
  final JinyeSpanSelection? token;
}

class _JinyeLemmaBodyState extends State<JinyeLemmaBody> {
  final List<TapGestureRecognizer> _recognizers = [];
  List<_Piece> _pieces = const [];

  List<JinyeLemmaLink> get _active {
    final list = widget.links
        .where((l) => l.status == 'active' || l.status == 'pending_correction')
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  bool _overlapsLink(int start, int end, List<JinyeLemmaLink> active) {
    for (final link in active) {
      final ls = link.start.clamp(0, widget.body.length);
      final le = link.end.clamp(0, widget.body.length);
      if (le <= ls) continue;
      if (start < le && end > ls) return true;
    }
    return false;
  }

  void _rebuildPieces() {
    _clearRecognizers();
    final body = widget.body;
    final active = _active;
    if (body.isEmpty) {
      _pieces = const [];
      return;
    }

    final raw = <_Piece>[];
    for (final link in active) {
      final start = link.start.clamp(0, body.length);
      final end = link.end.clamp(0, body.length);
      if (end <= start) continue;
      raw.add(
        _Piece(kind: _PieceKind.link, start: start, end: end, link: link),
      );
    }

    if (widget.onUnlinkedWordTap != null) {
      for (final m in RegExp(r'\S+').allMatches(body)) {
        if (_overlapsLink(m.start, m.end, active)) continue;
        raw.add(
          _Piece(
            kind: _PieceKind.token,
            start: m.start,
            end: m.end,
            token: JinyeSpanSelection(
              start: m.start,
              end: m.end,
              text: m.group(0)!,
            ),
          ),
        );
      }
    }

    raw.sort((a, b) => a.start.compareTo(b.start));

    final filled = <_Piece>[];
    var cursor = 0;
    for (final p in raw) {
      if (p.start < cursor) continue;
      if (p.start > cursor) {
        filled.add(
          _Piece(kind: _PieceKind.plain, start: cursor, end: p.start),
        );
      }
      filled.add(p);
      cursor = p.end;
    }
    if (cursor < body.length) {
      filled.add(
        _Piece(kind: _PieceKind.plain, start: cursor, end: body.length),
      );
    }
    _pieces = filled;
  }

  @override
  void initState() {
    super.initState();
    _rebuildPieces();
  }

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant JinyeLemmaBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body ||
        oldWidget.links != widget.links ||
        (oldWidget.onUnlinkedWordTap == null) !=
            (widget.onUnlinkedWordTap == null)) {
      _rebuildPieces();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final base =
        widget.style ??
        theme.typography.body.lg.copyWith(color: theme.colors.foreground);

    if (widget.body.isEmpty) {
      return Text('-', style: base);
    }

    final active = _active;
    if (_pieces.isEmpty ||
        (active.isEmpty && widget.onUnlinkedWordTap == null)) {
      return Text(widget.body, style: base);
    }

    // Recognizer dibuat ulang tiap build supaya closure pakai callback terbaru.
    _clearRecognizers();
    final spans = <InlineSpan>[];
    for (final piece in _pieces) {
      final text = widget.body.substring(piece.start, piece.end);
      switch (piece.kind) {
        case _PieceKind.link:
          final link = piece.link!;
          final pending = link.isPendingCorrection;
          final recognizer = TapGestureRecognizer()
            ..onTap = () {
              if (!mounted) return;
              context.push('/words/${link.wordId}');
            };
          _recognizers.add(recognizer);
          spans.add(
            TextSpan(
              text: text,
              style: base.copyWith(
                color: theme.colors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationStyle: pending
                    ? TextDecorationStyle.dashed
                    : TextDecorationStyle.solid,
              ),
              recognizer: recognizer,
            ),
          );
        case _PieceKind.token:
          final span = piece.token!;
          final recognizer = TapGestureRecognizer()
            ..onTap = () {
              if (!mounted) return;
              widget.onUnlinkedWordTap?.call(span);
            };
          _recognizers.add(recognizer);
          spans.add(
            TextSpan(
              text: text,
              style: base.copyWith(
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dotted,
                decorationColor: theme.colors.mutedForeground,
              ),
              recognizer: recognizer,
            ),
          );
        case _PieceKind.plain:
          spans.add(TextSpan(text: text));
      }
    }

    return GestureDetector(
      onLongPress: widget.onLinkLongPress == null || active.isEmpty
          ? null
          : () {
              if (active.length == 1) {
                widget.onLinkLongPress!(active.first);
                return;
              }
              _pickLinkForAction(context, active);
            },
      child: Text.rich(TextSpan(style: base, children: spans)),
    );
  }

  Future<void> _pickLinkForAction(
    BuildContext context,
    List<JinyeLemmaLink> active,
  ) async {
    final chosen = await showModalBottomSheet<JinyeLemmaLink>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FTileGroup(
              children: [
                for (final link in active)
                  FTile(
                    title: Text(
                      link.lemma ??
                          (link.start < widget.body.length &&
                                  link.end <= widget.body.length
                              ? widget.body.substring(link.start, link.end)
                              : link.wordId),
                    ),
                    subtitle: link.isPendingCorrection
                        ? Text(l10n.jinyeLemmaPendingCorrection)
                        : null,
                    onPress: () => Navigator.pop(ctx, link),
                  ),
              ],
            ),
          ],
        );
      },
    );
    if (chosen != null) widget.onLinkLongPress!(chosen);
  }
}
