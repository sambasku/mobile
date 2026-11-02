import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

/// Label singkat "Dari KBBI" + ikon info; tap ikon buka penjelasan penuh.
///
/// Pakai [FPopover] (tap), sama seperti `_InfoTip` di form kontribusi -
/// lebih jelas di touch daripada [FTooltip] long-press.
class KbbiSourceNotice extends StatelessWidget {
  const KbbiSourceNotice({super.key});

  static const double _iconSize = 14;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final muted = theme.colors.mutedForeground;
    return Row(
      children: [
        Text(
          l10n.kbbiSourceNoticeShort,
          style: theme.typography.body.sm.copyWith(color: muted),
        ),
        const Gap(2),
        FPopover(
          constraints: const FPortalConstraints(maxWidth: 280),
          popoverBuilder: (context, _) => Padding(
            padding: const .fromLTRB(12, 10, 12, 10),
            child: Text(
              l10n.kbbiSourceNotice,
              style: theme.typography.body.sm.copyWith(height: 1.35),
            ),
          ),
          builder: (context, controller, child) => GestureDetector(
            behavior: .opaque,
            onTap: controller.toggle,
            child: child,
          ),
          child: Semantics(
            button: true,
            label: l10n.kbbiSourceNoticeInfoSemantics,
            hint: l10n.kbbiSourceNotice,
            child: Padding(
              padding: const .all(6),
              child: Icon(FLucideIcons.info, size: _iconSize, color: muted),
            ),
          ),
        ),
      ],
    );
  }
}
