import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/widgets/swipe_decision_card.dart';

/// Arah keputusan setelah swipe melewati ambang.
enum ReviewSwipeDirection { approve, reject, skip }

/// Kartu tinjau: kanan = setuju, kiri = tolak, atas = lewati.
///
/// [onSwiped] dipanggil setelah kartu animasi keluar. Return `true` agar kartu
/// tetap tersembunyi; `false` mengembalikan kartu ke tengah.
///
/// Deck ala Tinder: tanpa scroll bersarang supaya swipe (termasuk atas/lewati)
/// tidak perang gesture. Lewati juga lewat tombol di action bar.
class ReviewSwipeCard extends StatelessWidget {
  const ReviewSwipeCard({
    super.key,
    required this.itemKey,
    required this.enabled,
    required this.onSwiped,
    required this.child,
  });

  final Object itemKey;
  final bool enabled;
  final Future<bool> Function(ReviewSwipeDirection direction) onSwiped;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SwipeDecisionCard(
      itemKey: itemKey,
      enabled: enabled,
      allowNestedVerticalScroll: false,
      fallbackHeight: MediaQuery.sizeOf(context).height * 0.6,
      hintId: 'review-session',
      positiveLabel: 'Setujui',
      negativeLabel: 'Tolak',
      skipLabel: 'Lewati',
      overlayStyle: SwipeDecisionOverlayStyle.icon,
      // Beda dari deck vote (↑↓): tinjau = setuju/tolak, bukan vote.
      positiveIcon: FLucideIcons.check,
      negativeIcon: FLucideIcons.x,
      skipIcon: FLucideIcons.skipForward,
      positiveColor: theme.colors.success,
      negativeColor: theme.colors.destructive,
      skipColor: theme.colors.mutedForeground,
      onSwiped: (direction) => onSwiped(switch (direction) {
        SwipeDecisionDirection.positive => ReviewSwipeDirection.approve,
        SwipeDecisionDirection.negative => ReviewSwipeDirection.reject,
        SwipeDecisionDirection.skip => ReviewSwipeDirection.skip,
      }),
      child: child,
    );
  }
}
