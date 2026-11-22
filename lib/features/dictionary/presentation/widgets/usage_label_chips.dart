import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../dictionary_labels.dart';

/// Multi-select register / peringatan (`usage_labels`).
class UsageLabelChips extends StatelessWidget {
  const UsageLabelChips({
    required this.options,
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final code in options)
          GestureDetector(
            onTap: () => onToggle(code),
            child: FBadge(
              variant: selected.contains(code)
                  ? FBadgeVariant.primary
                  : FBadgeVariant.secondary,
              child: Text(usageLabelLabel(code, l10n)),
            ),
          ),
      ],
    );
  }
}