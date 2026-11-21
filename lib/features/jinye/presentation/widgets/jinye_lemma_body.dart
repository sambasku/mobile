import 'package:flutter/gestures.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/thread_reply_draft.dart';
import '../../../../shared/widgets/thread_message.dart';
import '../../domain/jinye_models.dart';
import 'jinye_link_lemma_sheet.dart';

/// Body Jinye dengan highlight span lemma + tap per kata.
///
/// - Tap kata (ter-link / belum) → [onWordTap] bila ada
/// - Tanpa [onWordTap]: tap span ter-link → detail kata (fallback)
/// - Long-press span → [onLinkLongPress]
class JinyeLemmaBody extends StatefulWidget {
  const JinyeLemmaBody({
    super.key,
    required this.body,
    required this.links,
    this.style,
    this.onLinkLongPress,
    this.onWordTap,
  });

  final String body;
  final List<JinyeLemmaLink> links;
  final TextStyle? style;
  final void Function(JinyeLemmaLink link)? onLinkLongPress;

  /// Tap satu kata (token whitespace). [link] non-null bila span sudah tertaut.
  final void Function(JinyeSpanSelection span, JinyeLemmaLink? link)?
  onWordTap;

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

    // Selalu tokenisasi kata belum tertaut supaya semua pembaca bisa tap.
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
    if (oldWidget.body != widget.body || oldWidget.links != widget.links) {
      _rebuildPieces();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final base =
        widget.style ??
        theme.typography.body.md.copyWith(color: theme.colors.foreground);

    if (widget.body.isEmpty) {
      return Text('-', style: base);
    }

    final active = _active;
    if (_pieces.isEmpty) {
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
          final span = JinyeSpanSelection(
            start: piece.start,
            end: piece.end,
            text: text,
          );
          final recognizer = TapGestureRecognizer()
            ..onTap = () {
              if (!mounted) return;
              final tap = widget.onWordTap;
              if (tap != null) {
                tap(span, link);
                return;
              }
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
          final tap = widget.onWordTap;
          if (tap == null) {
            spans.add(TextSpan(text: text));
            break;
          }
          final recognizer = TapGestureRecognizer()
            ..onTap = () {
              if (!mounted) return;
              tap(span, null);
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

List<JinyeLemmaLink> jinyeLemmaLinksInRest(
  List<JinyeLemmaLink> links,
  String body,
  int restStart,
) {
  final restLen = body.length - restStart;
  if (restStart <= 0 || restLen <= 0) return links;

  final remapped = <JinyeLemmaLink>[];
  for (final link in links) {
    if (link.start < restStart || link.end > body.length) continue;
    if (link.end <= restStart) continue;
    remapped.add(
      JinyeLemmaLink(
        id: link.id,
        start: link.start - restStart,
        end: link.end - restStart,
        wordId: link.wordId,
        status: link.status,
        jinyeId: link.jinyeId,
        commentId: link.commentId,
        lemma: link.lemma,
        source: link.source,
        proposedWordId: link.proposedWordId,
        proposedLemma: link.proposedLemma,
        proposedBy: link.proposedBy,
      ),
    );
  }
  return remapped;
}

/// Body komentar/balasan Jinye: blockquote balasan (#205) + lemma pada teks
/// balasan saja (span link mengacu ke [body] penuh dari API).
class ThreadLemmaBody extends StatelessWidget {
  const ThreadLemmaBody({
    super.key,
    required this.body,
    required this.links,
    this.style,
    this.onLinkLongPress,
    this.onWordTap,
    this.onMentionTap,
    this.isRedacted = false,
  });

  final String body;
  final List<JinyeLemmaLink> links;
  final TextStyle? style;
  final void Function(JinyeLemmaLink link)? onLinkLongPress;
  final void Function(JinyeSpanSelection span, JinyeLemmaLink? link)? onWordTap;
  final ValueChanged<String>? onMentionTap;
  final bool isRedacted;

  @override
  Widget build(BuildContext context) {
    final split = splitLeadingBlockquote(body);

    if (split.quote.isEmpty) {
      return JinyeLemmaBody(
        body: body,
        links: links,
        style: style,
        onLinkLongPress: onLinkLongPress,
        onWordTap: onWordTap,
      );
    }

    final rest = split.rest;
    final baseStyle = style ?? context.theme.typography.body.md;
    final restLinks = jinyeLemmaLinksInRest(links, body, split.restStart);
    final offset = split.restStart;

    // Lemma di wilayah quote jarang; tampil sebagai teks biasa di quote.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (split.quote.trim().isNotEmpty)
          ThreadReplyQuoteBlock(
            quote: split.quote,
            style: baseStyle,
            isRedacted: isRedacted,
            onMentionTap: onMentionTap,
          ),
        if (rest.trim().isNotEmpty) ...[
          if (split.quote.trim().isNotEmpty) const Gap(6),
          JinyeLemmaBody(
            body: rest,
            links: restLinks,
            style: style,
            onLinkLongPress: onLinkLongPress == null
                ? null
                : (link) =>
                    onLinkLongPress!(_offsetLemmaLink(link, offset)),
            onWordTap: onWordTap == null
                ? null
                : (span, link) => onWordTap!(
                      JinyeSpanSelection(
                        start: span.start + offset,
                        end: span.end + offset,
                        text: span.text,
                      ),
                      link != null ? _offsetLemmaLink(link, offset) : null,
                    ),
          ),
        ],
      ],
    );
  }
}

JinyeLemmaLink _offsetLemmaLink(JinyeLemmaLink link, int offset) {
  return JinyeLemmaLink(
    id: link.id,
    start: link.start + offset,
    end: link.end + offset,
    wordId: link.wordId,
    status: link.status,
    jinyeId: link.jinyeId,
    commentId: link.commentId,
    lemma: link.lemma,
    source: link.source,
    proposedWordId: link.proposedWordId,
    proposedLemma: link.proposedLemma,
    proposedBy: link.proposedBy,
  );
}
