import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../theme/theme_mode_controller.dart';
import 'header_action_icon.dart';

/// Tombol app bar: sun (saat dark → ke light) / moon (saat light → ke dark).
class ThemeToggleHeaderAction extends ConsumerWidget {
  const ThemeToggleHeaderAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FHeaderAction(
      icon: Icon(
        isDark ? FLucideIcons.sun : FLucideIcons.moon,
        size: kHeaderActionIconSize,
      ),
      onPress: () => ref
          .read(themeModeControllerProvider.notifier)
          .toggle(Theme.of(context).brightness),
    );
  }
}
