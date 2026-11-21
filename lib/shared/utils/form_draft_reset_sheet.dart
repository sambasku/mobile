import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

import '../../l10n/app_localizations.dart';

Future<bool> confirmFormDraftReset(
  BuildContext context,
  AppLocalizations l10n,
) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => Padding(
      padding: MediaQuery.of(sheetContext).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FTileGroup(
            children: [
              FTile(
                title: Text(l10n.contributeFormResetTitle),
                subtitle: Text(l10n.contributeFormResetBody),
              ),
              FTile(
                title: const SizedBox.shrink(),
                suffix: FButton(
                  variant: FButtonVariant.destructive,
                  onPress: () => Navigator.of(sheetContext).pop(true),
                  child: Text(l10n.contributeFormResetConfirm),
                ),
              ),
              FTile(
                title: const SizedBox.shrink(),
                suffix: FButton(
                  onPress: () => Navigator.of(sheetContext).pop(false),
                  child: Text(l10n.commonCancel),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  return result == true;
}