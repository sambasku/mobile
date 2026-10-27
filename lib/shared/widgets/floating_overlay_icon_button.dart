import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

/// Style tombol ikon mengambang di atas peta/cover.
///
/// Satu sumber untuk pins, wilayah, dan [ProfileHeroShell]: latar
/// `background`, `elevation: 2`, `shadowColor: black26`, padding IconButton
/// default (8). [fill] 1 = penuh (di atas media); 0 = tanpa isi/shadow
/// (bar solid sudah jadi latar).
ButtonStyle floatingOverlayIconButtonStyle(
  BuildContext context, {
  double fill = 1,
}) {
  final theme = context.theme;
  final t = fill.clamp(0.0, 1.0);
  return IconButton.styleFrom(
    backgroundColor: theme.colors.background.withValues(alpha: t),
    foregroundColor: theme.colors.foreground,
    elevation: 2 * t,
    shadowColor: Colors.black26,
  );
}
