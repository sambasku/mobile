import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';

const _kChatPrivacyWarningDismissed = 'chat_privacy_warning_dismissed';

/// Cache sinkron di memori supaya masuk ulang ke halaman chat tidak
/// menunggu async SharedPreferences yang menyebabkan layout shift frame 1.
bool? _cachedPrivacyWarningDismissed;

/// Strip satu baris peringatan chat publik. Ketuk untuk teks lengkap.
/// Tutup = tidak tampil lagi (SharedPreferences).
class ChatPrivacyWarning extends HookWidget {
  const ChatPrivacyWarning({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dismissed = useState<bool?>(_cachedPrivacyWarningDismissed);

    useEffect(() {
      if (_cachedPrivacyWarningDismissed != null) return null;
      SharedPreferences.getInstance().then((prefs) {
        final val = prefs.getBool(_kChatPrivacyWarningDismissed) ?? false;
        _cachedPrivacyWarningDismissed = val;
        if (context.mounted) dismissed.value = val;
      });
      return null;
    }, const []);

    final visible = dismissed.value == false;
    final theme = FTheme.of(context);
    final destructive = theme.colors.destructive;

    Future<void> dismiss() async {
      _cachedPrivacyWarningDismissed = true;
      dismissed.value = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kChatPrivacyWarningDismissed, true);
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: !visible
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: destructive.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: destructive.withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 2, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _showPrivacyDetail(context),
                          child: Row(
                            children: [
                              Icon(
                                FLucideIcons.triangleAlert,
                                size: 14,
                                color: destructive,
                              ),
                              const Gap(6),
                              Expanded(
                                child: Text(
                                  l10n.chatPrivacyWarningHint,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.body.xs2.copyWith(
                                    color: destructive,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Semantics(
                        button: true,
                        label: l10n.chatPrivacyWarningDismiss,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: dismiss,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              FLucideIcons.x,
                              size: 14,
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

void _showPrivacyDetail(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      final theme = FTheme.of(sheetContext);
      final bottom = MediaQuery.paddingOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chatPrivacyWarningTitle,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(6),
            Text(
              l10n.chatPrivacyWarningBody,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    },
  );
}
