import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Layar penuh ketika peran bukan root/admin.
class AdminAnalyticsForbiddenPage extends StatelessWidget {
  const AdminAnalyticsForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Analitik'),
        prefixes: [
          FHeaderAction.back(onPress: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          }),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FLucideIcons.shieldOff,
                size: 36,
                color: theme.colors.mutedForeground,
              ),
              const Gap(12),
              Text(
                'Akses terbatas',
                textAlign: TextAlign.center,
                style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
              ),
              const Gap(8),
              Text(
                'Hanya admin dan root yang boleh membuka Analitik.',
                textAlign: TextAlign.center,
                style: theme.typography.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
