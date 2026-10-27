import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../domain/entities/achievement.dart';
import '../../domain/failures/achievement_failure.dart';
import '../../domain/providers/achievement_domain_providers.dart';
import '../providers/achievement_providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Bottom sheet pilih bingkai profil (aturan mobile-use-bottom-sheet).
///
/// Baris pertama = "Tanpa bingkai" (PATCH border_id null). Grid = border
/// yang dimiliki (GET /me/achievements?reward_type=profile_border) dengan
/// tanda centang di bingkai aktif. Tap = PATCH lalu toast + refresh.
Future<void> showBorderPickerSheet(
  BuildContext context, {
  String? displayName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _BorderPickerSheet(),
  );
}

class _BorderPickerSheet extends HookConsumerWidget {
  const _BorderPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final bordersAsync = ref.watch(
      myAchievementsProvider(rewardType: 'profile_border'),
    );
    final applying = useState<String?>(null);

    Future<void> apply(Achievement? border) async {
      if (applying.value != null) return;
      applying.value = border?.userAchievementId ?? '';
      try {
        final result = await ref
            .read(setActiveBorderUseCaseProvider)
            .call(border?.userAchievementId);
        if (!context.mounted) return;
        result.match((failure) => Navigator.of(context).pop(), (_) {
          ref.invalidate(myAchievementsProvider);
          ref.invalidate(myActiveBorderProvider);
          Navigator.of(context).pop();
          showFToast(
            context: context,
            title: Text(AppLocalizations.of(context).achievementBorderUpdated),
          );
        });
      } finally {
        if (context.mounted) applying.value = null;
      }
    }

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Icon(FLucideIcons.frame, size: 18, color: theme.colors.primary),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Ubah bingkai profil',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              'Pilih bingkai yang sudah kamu miliki',
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: bordersAsync.when(
              loading: () => const Center(child: FCircularProgress()),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FAlert(
                      variant: FAlertVariant.destructive,
                      title: Text(
                        err is AchievementFailure
                            ? err.message
                            : 'Gagal memuat bingkai',
                      ),
                    ),
                    const Gap(8),
                    FButton(
                      variant: FButtonVariant.outline,
                      onPress: () => ref.invalidate(
                        myAchievementsProvider(rewardType: 'profile_border'),
                      ),
                      child: Text(AppLocalizations.of(context).commonRetry),
                    ),
                  ],
                ),
              ),
              data: (borders) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  FTileGroup(
                    children: [
                      FTile(
                        prefix: const Icon(FLucideIcons.circleSlash),
                        title: Text(AppLocalizations.of(context).achievementBorderNone),
                        subtitle: Text(AppLocalizations.of(context).achievementBorderNoneSubtitle),
                        suffix: borders.any((b) => b.isActiveBorder)
                            ? const Icon(FLucideIcons.check)
                            : null,
                        enabled: applying.value == null,
                        onPress: () => apply(null),
                      ),
                    ],
                  ),
                  const Gap(12),
                  if (borders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Kamu belum punya bingkai. Ikuti program berikutnya '
                        'untuk mendapatkannya.',
                        textAlign: TextAlign.center,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: borders.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                      itemBuilder: (context, index) {
                        final border = borders[index];
                        final busy = applying.value == border.userAchievementId;
                        return _BorderCell(
                          border: border,
                          busy: busy,
                          enabled: applying.value == null,
                          onTap: () => apply(border),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BorderCell extends StatelessWidget {
  const _BorderCell({
    required this.border,
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final Achievement border;
  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final url = displayImageUrl(border.badgeUrl, width: 256) ?? border.badgeUrl;
    return Semantics(
      button: true,
      label: border.title,
      child: InkWell(
        onTap: enabled && !busy ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: border.isActiveBorder
                  ? theme.colors.primary
                  : theme.colors.border,
              width: border.isActiveBorder ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: busy
                    ? const Center(child: FCircularProgress())
                    : url == null
                    ? Icon(
                        FLucideIcons.frame,
                        size: 32,
                        color: theme.colors.mutedForeground,
                      )
                    : Image.network(
                        url,
                        fit: BoxFit.contain,
                        gaplessPlayback: true,
                        errorBuilder: (_, _, _) => Icon(
                          FLucideIcons.frame,
                          size: 32,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
              ),
              const Gap(4),
              Text(
                border.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.typography.body.xs.copyWith(
                  fontWeight: border.isActiveBorder ? FontWeight.w700 : null,
                  color: border.isActiveBorder
                      ? theme.colors.primary
                      : theme.colors.foreground,
                ),
              ),
              if (border.isActiveBorder)
                Icon(FLucideIcons.check, size: 14, color: theme.colors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
