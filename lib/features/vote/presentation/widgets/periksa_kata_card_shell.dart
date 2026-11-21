import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Kartu Periksa: zona konten + vote, masing-masing full-bleed dengan warna soft.
class PeriksaKataCardShell extends StatelessWidget {
  const PeriksaKataCardShell({
    super.key,
    required this.content,
    required this.voteRail,
    this.cornerRadius = 10,
  });

  final Widget content;
  final Widget voteRail;
  final double cornerRadius;

  /// Latar konten (lemma, makna, progress) - lebih terang.
  static Color contentFill(FThemeData theme) =>
      theme.colors.muted.withValues(alpha: 0.22);

  /// Latar kolom vote - sedikit lebih pekat, masih soft.
  static Color voteFill(FThemeData theme) =>
      theme.colors.muted.withValues(alpha: 0.38);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final r = Radius.circular(cornerRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(r),
        border: Border(
          left: BorderSide(color: theme.colors.border),
          top: BorderSide(color: theme.colors.border),
          bottom: BorderSide(color: theme.colors.border),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: contentFill(theme),
                  borderRadius: BorderRadius.only(topLeft: r, bottomLeft: r),
                ),
                child: content,
              ),
            ),
            voteRail,
          ],
        ),
      ),
    );
  }
}