import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../l10n/app_localizations.dart';

/// Toolbar format Markdown (undo/redo, bold, italic, heading, list, gambar, preview).
///
/// Dibungkus [ExcludeFocus] supaya tap tombol tidak merebut fokus dari TextField
/// (seleksi/handles tetap hidup). [onPreserveSelection] dipanggil di pointer-down
/// sebagai jaring pengaman.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    super.key,
    required this.previewing,
    required this.uploading,
    required this.canUndo,
    required this.canRedo,
    required this.onPreserveSelection,
    required this.onUndo,
    required this.onRedo,
    required this.onBold,
    required this.onItalic,
    required this.onHeading,
    required this.onList,
    required this.onLink,
    required this.onImage,
    required this.onTogglePreview,
    this.imageEnabled = true,
  });

  final bool previewing;
  final bool uploading;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onPreserveSelection;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onHeading;
  final VoidCallback onList;
  final VoidCallback onLink;
  final VoidCallback onImage;
  final VoidCallback onTogglePreview;
  final bool imageEnabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final writeEnabled = !previewing && !uploading;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colors.border),
        ),
      ),
      child: ExcludeFocus(
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => onPreserveSelection(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                _Tool(
                  icon: FLucideIcons.undo2,
                  label: l10n.mdEditorUndo,
                  onPress: writeEnabled && canUndo ? onUndo : null,
                ),
                _Tool(
                  icon: FLucideIcons.redo2,
                  label: l10n.mdEditorRedo,
                  onPress: writeEnabled && canRedo ? onRedo : null,
                ),
                _Tool(
                  icon: FLucideIcons.bold,
                  label: l10n.mdEditorBold,
                  onPress: writeEnabled ? onBold : null,
                ),
                _Tool(
                  icon: FLucideIcons.italic,
                  label: l10n.mdEditorItalic,
                  onPress: writeEnabled ? onItalic : null,
                ),
                _Tool(
                  icon: FLucideIcons.heading2,
                  label: l10n.mdEditorHeading,
                  onPress: writeEnabled ? onHeading : null,
                ),
                _Tool(
                  icon: FLucideIcons.list,
                  label: l10n.mdEditorList,
                  onPress: writeEnabled ? onList : null,
                ),
                _Tool(
                  icon: FLucideIcons.link,
                  label: l10n.mdEditorLink,
                  onPress: writeEnabled ? onLink : null,
                ),
                if (imageEnabled)
                  _Tool(
                    icon: FLucideIcons.image,
                    label: l10n.mdEditorImage,
                    onPress: writeEnabled ? onImage : null,
                    busy: uploading,
                  ),
                _Tool(
                  icon: previewing ? FLucideIcons.pencil : FLucideIcons.eye,
                  label: previewing ? l10n.mdEditorWrite : l10n.mdEditorPreview,
                  onPress: uploading ? null : onTogglePreview,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  const _Tool({
    required this.icon,
    required this.label,
    required this.onPress,
    this.busy = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPress;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final enabled = onPress != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: FButton.icon(
        variant: .ghost,
        size: .sm,
        onPress: onPress,
        semanticsLabel: label,
        child: busy
            ? const FCircularProgress(size: .sm)
            : Icon(
                icon,
                size: 18,
                color: enabled
                    ? theme.colors.foreground
                    : theme.colors.mutedForeground,
              ),
      ),
    );
  }
}
