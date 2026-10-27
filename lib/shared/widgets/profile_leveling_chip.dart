import 'package:flutter/material.dart' show showModalBottomSheet;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../features/user_profile/domain/entities/public_profile.dart';
import '../../l10n/app_localizations.dart';

/// Chip level + progress di header profil. Tap → bottom sheet penjelasan.
class ProfileLevelingChip extends StatelessWidget {
  const ProfileLevelingChip({super.key, required this.leveling});

  final PublicProfileLeveling leveling;

  static String titleForCode(AppLocalizations l10n, String code) {
    return switch (code) {
      'peninjau' => l10n.levelingTitlePeninjau,
      'pencatat' => l10n.levelingTitlePencatat,
      'penyumbang' => l10n.levelingTitlePenyumbang,
      'pengumpul' => l10n.levelingTitlePengumpul,
      'penggiat' => l10n.levelingTitlePenggiat,
      'penjaga-jejak' => l10n.levelingTitlePenjagaJejak,
      'penghubung' => l10n.levelingTitlePenghubung,
      'pewaris' => l10n.levelingTitlePewaris,
      'penjaga-warisan' => l10n.levelingTitlePenjagaWarisan,
      'sesepuh' => l10n.levelingTitleSesepuh,
      'tetua' => l10n.levelingTitleTetua,
      'pengayom' => l10n.levelingTitlePengayom,
      'pelestari' => l10n.levelingTitlePelestari,
      'empu' => l10n.levelingTitleEmpu,
      'legenda' => l10n.levelingTitleLegenda,
      _ => code,
    };
  }

  Future<void> _openSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final title = titleForCode(l10n, leveling.titleCode);
    final next = leveling.nextLevelPoints;
    final progressLabel = next == null
        ? l10n.levelingMaxReached
        : l10n.levelingProgress(leveling.points, next);

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = sheetContext.theme;
        return Padding(
          padding: MediaQuery.viewInsetsOf(sheetContext),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.levelingSheetTitle(leveling.level, title),
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    progressLabel,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  if (next != null) ...[
                    const Gap(10),
                    _LevelProgressBar(
                      points: leveling.points,
                      next: next,
                      prevThreshold: _prevThreshold(leveling.level, leveling.points, next),
                    ),
                  ],
                  const Gap(12),
                  Text(
                    l10n.levelingSheetHint,
                    style: theme.typography.body.sm,
                  ),
                  if (leveling.streakDays > 0) ...[
                    const Gap(8),
                    Text(
                      l10n.levelingStreakDays(leveling.streakDays),
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      l10n.levelingStreakWindowHint,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                  const Gap(16),
                  FButton(
                    onPress: () => Navigator.of(sheetContext).pop(),
                    child: Text(l10n.infoSheetUnderstood),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Ambang level sekarang ≈ points floor ke threshold level (aproksimasi UI).
  static int _prevThreshold(int level, int points, int next) {
    // Progress bar relatif ke pita saat ini: pakai next - (next-points clamped)
    // sederhana: gunakan max(0, next - (next - points)) = points sebagai posisi
    // dan threshold bawah = next hanya jika level max; untuk bar pakai
    // (points - lower) / (next - lower). Lower diestimasi dari rasio umum.
    // Cukup: lower = max(0, 2 * points - next) jelek.
    // Lebih baik: lower = 0 bila level 1 else approximate from known table.
    const thresholds = [
      0, 20, 80, 200, 600, 1400, 2800, 5000, 8000, 12000, 18000, 27000, 40000,
      60000, 90000,
    ];
    final idx = (level - 1).clamp(0, thresholds.length - 1);
    return thresholds[idx];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final title = titleForCode(l10n, leveling.titleCode);
    final next = leveling.nextLevelPoints;

    return GestureDetector(
      onTap: () => _openSheet(context),
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.levelingChipLabel(leveling.level, title),
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (leveling.streakDays > 0)
                Text(
                  l10n.levelingStreakBadge(leveling.streakDays),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
            ],
          ),
          if (next != null) ...[
            const Gap(6),
            SizedBox(
              width: 160,
              child: _LevelProgressBar(
                points: leveling.points,
                next: next,
                prevThreshold: _prevThreshold(leveling.level, leveling.points, next),
              ),
            ),
            const Gap(2),
            Text(
              l10n.levelingProgress(leveling.points, next),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LevelProgressBar extends StatelessWidget {
  const _LevelProgressBar({
    required this.points,
    required this.next,
    required this.prevThreshold,
  });

  final int points;
  final int next;
  final int prevThreshold;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final span = (next - prevThreshold).clamp(1, 1 << 30);
    final value = ((points - prevThreshold) / span).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 6,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: theme.colors.muted),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: ColoredBox(color: theme.colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
