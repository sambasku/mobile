import 'package:flutter/gestures.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/jinye_models.dart';

/// Body Jinye dengan highlight span lemma. Tap span → detail kata.
/// Long-press → [onLinkLongPress] (koreksi / hapus / resolve).
class JinyeLemmaBody extends StatefulWidget {
  const JinyeLemmaBody({
    super.key,
    required this.body,
    required this.links,
    this.style,
    this.onLinkLongPress,
  });

  final String body;
  final List<JinyeLemmaLink> links;
  final TextStyle? style;
  final void Function(JinyeLemmaLink link)? onLinkLongPress;

  @override
  State<JinyeLemmaBody> createState() => _JinyeLemmaBodyState();
}

class _JinyeLemmaBodyState extends State<JinyeLemmaBody> {
  final List<TapGestureRecognizer> _recognizers = [];

  List<JinyeLemmaLink> get _active {
    final list = widget.links
        .where((l) => l.status == 'active' || l.status == 'pending_correction')
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return list;
  }

  void _rebuildRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    for (final link in _active) {
      _recognizers.add(
        TapGestureRecognizer()
          ..onTap = () {
            if (!mounted) return;
            context.push('/words/${link.wordId}');
          },
      );
    }
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant JinyeLemmaBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.body != widget.body || oldWidget.links != widget.links) {
      _rebuildRecognizers();
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
    if (active.isEmpty) {
      return Text(widget.body, style: base);
    }

    if (_recognizers.length != active.length) {
      _rebuildRecognizers();
    }

    final spans = <InlineSpan>[];
    var cursor = 0;
    var ri = 0;
    for (final link in active) {
      final start = link.start.clamp(0, widget.body.length);
      final end = link.end.clamp(0, widget.body.length);
      if (end <= start || start < cursor) {
        ri++;
        continue;
      }
      if (start > cursor) {
        spans.add(TextSpan(text: widget.body.substring(cursor, start)));
      }
      final pending = link.isPendingCorrection;
      final recognizer = ri < _recognizers.length ? _recognizers[ri] : null;
      ri++;
      spans.add(
        TextSpan(
          text: widget.body.substring(start, end),
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
      cursor = end;
    }
    if (cursor < widget.body.length) {
      spans.add(TextSpan(text: widget.body.substring(cursor)));
    }

    return GestureDetector(
      onLongPress: widget.onLinkLongPress == null
          ? null
          : () {
              // ponytail: long-press tanpa hit-test char → sheet pilih span
              // jika >1 link; kalau 1 langsung aksi.
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
