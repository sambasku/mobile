import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';

class JinyeSpanSelection {
  const JinyeSpanSelection({
    required this.start,
    required this.end,
    required this.text,
  });

  final int start;
  final int end;
  final String text;
}

/// Pilih rentang kata di body Jinye (token whitespace). Pop [JinyeSpanSelection].
Future<JinyeSpanSelection?> showJinyeLinkLemmaSheet(
  BuildContext context, {
  required String body,
}) {
  return showModalBottomSheet<JinyeSpanSelection>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _JinyeLinkLemmaSheet(body: body),
  );
}

class _Token {
  const _Token({required this.start, required this.end, required this.text});
  final int start;
  final int end;
  final String text;
}

List<_Token> _tokenize(String body) {
  final out = <_Token>[];
  for (final m in RegExp(r'\S+').allMatches(body)) {
    out.add(_Token(start: m.start, end: m.end, text: m.group(0)!));
  }
  return out;
}

class _JinyeLinkLemmaSheet extends StatefulWidget {
  const _JinyeLinkLemmaSheet({required this.body});

  final String body;

  @override
  State<_JinyeLinkLemmaSheet> createState() => _JinyeLinkLemmaSheetState();
}

class _JinyeLinkLemmaSheetState extends State<_JinyeLinkLemmaSheet> {
  late final List<_Token> _tokens;
  int? _from;
  int? _to;

  @override
  void initState() {
    super.initState();
    _tokens = _tokenize(widget.body);
  }

  void _tapToken(int index) {
    setState(() {
      if (_from == null) {
        _from = index;
        _to = index;
        return;
      }
      if (_to == index && _from == index) {
        _from = null;
        _to = null;
        return;
      }
      if (index < _from!) {
        _from = index;
      } else {
        _to = index;
      }
    });
  }

  bool _selected(int i) {
    if (_from == null || _to == null) return false;
    return i >= _from! && i <= _to!;
  }

  JinyeSpanSelection? get _selection {
    if (_from == null || _to == null) return null;
    final a = _tokens[_from!];
    final b = _tokens[_to!];
    return JinyeSpanSelection(
      start: a.start,
      end: b.end,
      text: widget.body.substring(a.start, b.end),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final sel = _selection;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.jinyeLemmaSelectSpanTitle,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.jinyeLemmaSelectSpanHint,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
          const Gap(12),
          if (_tokens.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l10n.jinyeLemmaSelectSpanEmpty),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < _tokens.length; i++)
                    FButton(
                      variant: _selected(i)
                          ? FButtonVariant.primary
                          : FButtonVariant.outline,
                      onPress: () => _tapToken(i),
                      child: Text(_tokens[i].text),
                    ),
                ],
              ),
            ),
          const Gap(16),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: FButton(
                onPress: sel == null
                    ? null
                    : () => Navigator.pop(context, sel),
                child: Text(l10n.jinyeLemmaSelectSpanContinue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
