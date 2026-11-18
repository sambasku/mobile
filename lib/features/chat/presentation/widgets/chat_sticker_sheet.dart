import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/chat_models.dart';
import 'chat_sticker_view.dart';

Future<String?> showChatStickerSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.chatStickerSheetTitle,
                  style: theme.typography.body.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final sticker in kChatStickers)
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(sheetContext, sticker.id),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colors.secondary.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ChatStickerView(
                            stickerId: sticker.id,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Gap(4),
          ],
        ),
      );
    },
  );
}
