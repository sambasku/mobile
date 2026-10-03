import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/contribution_guide_providers.dart';

/// Full-screen overlay guide sekali di kunjungan pertama tab Kontribusi.
/// Satu-satunya cara menutup = tap tombol "Mengerti".
Future<void> showContributionGuideSheet(BuildContext context) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    barrierLabel: 'Guide kontribusi',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) => _GuideContent(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _GuideContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FTheme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Material(
                color: theme.colors.background,
                borderRadius: BorderRadius.circular(24),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FLucideIcons.moveHorizontal,
                        size: 72,
                        color: theme.colors.primary,
                      ),
                      const Gap(16),
                      Text(
                        'Kartu bisa digeser untuk menilai',
                        textAlign: TextAlign.center,
                        style: theme.typography.xl.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        'Gunakan jari untuk menggeser kartu kata:\n'
                        '• Geser kanan → "Sudah pas" (arti sudah benar)\n'
                        '• Geser kiri → "Perlu dicek ulang" (arti kurang tepat)\n'
                        '• Geser ke atas → "Lewati" (raju / belum yakin)',
                        textAlign: TextAlign.center,
                        style: theme.typography.md.copyWith(
                          color: theme.colors.mutedForeground,
                          height: 1.5,
                        ),
                      ),
                      const Gap(28),
                      FButton(
                        onPress: () {
                          markContributionGuideRead(ref);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Mengerti'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}