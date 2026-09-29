import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../dictionary_router.dart';
import '../providers/letter_words_providers.dart';

/// Strip A-Z untuk halaman `/huruf/:letter`.
///
/// Chip custom (bukan [FButton]) supaya ukuran tetap tanpa overflow
/// padding default Forui.
class AlphabetLetterStrip extends StatelessWidget {
  const AlphabetLetterStrip({
    super.key,
    this.activeLetter,
    this.replaceOnSelect = false,
  });

  /// Huruf aktif (a-z). Null = tidak ada yang terpilih.
  final String? activeLetter;

  /// true di halaman huruf: ganti route tanpa menumpuk stack.
  final bool replaceOnSelect;

  static const double _chipSize = 34;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final l in kAlphabetLetters.split(''))
          _LetterChip(
            letter: l,
            size: _chipSize,
            selected: l == activeLetter,
            theme: theme,
            onPress: () {
              final path = DictionaryRouter.letter.path.replaceFirst(
                ':letter',
                l,
              );
              if (replaceOnSelect) {
                if (l == activeLetter) return;
                context.pushReplacement(path);
              } else {
                context.push(path);
              }
            },
          ),
      ],
    );
  }
}

class _LetterChip extends StatelessWidget {
  const _LetterChip({
    required this.letter,
    required this.size,
    required this.selected,
    required this.theme,
    required this.onPress,
  });

  final String letter;
  final double size;
  final bool selected;
  final FThemeData theme;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? theme.colors.primary : theme.colors.background;
    final fg = selected
        ? theme.colors.primaryForeground
        : theme.colors.foreground;
    final border = selected ? theme.colors.primary : theme.colors.border;

    final radius = BorderRadius.circular(8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPress,
        borderRadius: radius,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: Border.all(color: border),
          ),
          child: Center(
            child: Text(
              letter.toUpperCase(),
              style: theme.typography.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: fg,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
