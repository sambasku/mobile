import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../utils/leave_review.dart';

/// Layar penuh ketika peran tidak boleh meninjau. Bukan toast:
/// form keputusan tidak ikut tergambar.
class ReviewForbiddenPage extends StatelessWidget {
  const ReviewForbiddenPage({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leaveReview(context);
      },
      child: FScaffold(
        header: FHeader.nested(
          title: const Text('Tinjau usulan'),
          prefixes: [
            FHeaderAction.back(onPress: () => leaveReview(context)),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FLucideIcons.shieldOff, size: 36, color: theme.colors.mutedForeground),
                const Gap(12),
                Text(
                  'Kamu tidak berwenang meninjau usulan.',
                  textAlign: TextAlign.center,
                  style: theme.typography.lg.copyWith(fontWeight: FontWeight.w700),
                ),
                const Gap(8),
                Text(
                  message ?? 'Role tidak diizinkan mengakses endpoint ini',
                  textAlign: TextAlign.center,
                  style: theme.typography.sm.copyWith(color: theme.colors.mutedForeground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
