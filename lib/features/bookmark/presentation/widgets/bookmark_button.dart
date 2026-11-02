import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import '../../../../l10n/app_localizations.dart';

/// Tombol toggle bookmark (16-api-bookmark.md). Widget tampilan murni -
/// TIDAK mengambil data & TIDAK menjaga login guard; caller (adapter di
/// halaman detail) yang memegang state + guard login (pola VoteButtons).
class BookmarkButton extends StatefulWidget {
  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onPress,
    this.busy = false,
    this.size = 20,
  });

  final bool isBookmarked;

  /// Dipanggil saat ditekan. Async supaya tombol bisa menahan tekanan
  /// berikutnya sampai operasi selesai (guard double-tap).
  final Future<void> Function() onPress;

  /// Sedang memuat state awal (controller loading) - tampil redup,
  /// tekan diabaikan.
  final bool busy;
  final double size;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool _inFlight = false;

  Future<void> _handlePress() async {
    if (_inFlight || widget.busy) return;
    setState(() => _inFlight = true);
    try {
      await widget.onPress();
    } finally {
      if (mounted) setState(() => _inFlight = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final disabled = widget.busy || _inFlight;
    final l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: widget.isBookmarked ? l10n.bookmarkRemove : l10n.bookmarkAdd,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disabled ? null : _handlePress,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              widget.isBookmarked
                  ? FLucideIcons.bookmarkCheck
                  : FLucideIcons.bookmark,
              size: widget.size,
              color: disabled
                  ? theme.colors.mutedForeground.withValues(alpha: 0.5)
                  : widget.isBookmarked
                      ? theme.colors.primary
                      : theme.colors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
