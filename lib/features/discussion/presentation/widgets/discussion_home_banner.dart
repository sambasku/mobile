import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../discussion_router.dart';

/// CTA utama di Home (di bawah Kata Hari Ini / di atas feed).
class DiscussionHomeBanner extends StatelessWidget {
  const DiscussionHomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final accent = theme.colors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colors.secondary,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
        ),
        child: InkWell(
          onTap: () => context.push(DiscussionRouter.feed.path),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Icon(FLucideIcons.languages, color: accent, size: 22),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ruang Diskusi',
                        style: theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        'Cerita apa saja lewat teks, foto, atau tautan. Warga bantu jawab.',
                        style: theme.typography.sm.copyWith(
                          color: theme.colors.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  FLucideIcons.chevronRight,
                  size: 18,
                  color: theme.colors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
