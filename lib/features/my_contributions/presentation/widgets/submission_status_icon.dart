import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../../../core/widgets/pending_review_badge_icon.dart';
import '../../../../core/widgets/verified_badge_icon.dart';

/// Ikon status untuk tile list Kontribusi Saya. Semua status punya ikon
/// supaya tinggi tile seragam - tidak ada gap prefix kosong pada usulan
/// yang sudah diputuskan.
class SubmissionStatusIcon extends StatelessWidget {
  const SubmissionStatusIcon({super.key, required this.status, this.size = 16});

  final String status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return switch (status) {
      'approved' => VerifiedBadgeIcon(size: size),
      'rejected' => Icon(
        FLucideIcons.circleX,
        size: size,
        color: theme.colors.destructive,
      ),
      'corrected' => Icon(
        FLucideIcons.penLine,
        size: size,
        color: theme.colors.primary,
      ),
      _ => PendingReviewBadgeIcon(size: size),
    };
  }
}
