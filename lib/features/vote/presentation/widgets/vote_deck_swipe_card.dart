import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../../core/theme/f_colors_x.dart';
import '../../../../core/widgets/swipe_decision_card.dart';

/// Arah aksi deck: kanan = upvote, kiri = downvote, atas = lewati.
enum VoteDeckSwipeDirection { agree, disagree, skip }

/// Kartu swipe untuk deck nilai kata (bukan sesi tinjau verifikator).
///
/// [onSwiped] return `true` = kartu tetap keluar; `false` = spring back.
class VoteDeckSwipeCard extends StatefulWidget {
  const VoteDeckSwipeCard({
    super.key,
    required this.itemKey,
    required this.enabled,
    required this.onSwiped,
    required this.child,
  });

  final Object itemKey;
  final bool enabled;
  final Future<bool> Function(VoteDeckSwipeDirection direction) onSwiped;
  final Widget child;

  @override
  State<VoteDeckSwipeCard> createState() => VoteDeckSwipeCardState();
}

class VoteDeckSwipeCardState extends State<VoteDeckSwipeCard> {
  final _cardKey = GlobalKey<SwipeDecisionCardState>();

  Future<void> swipeAway(VoteDeckSwipeDirection direction) {
    final mapped = switch (direction) {
      VoteDeckSwipeDirection.agree => SwipeDecisionDirection.positive,
      VoteDeckSwipeDirection.disagree => SwipeDecisionDirection.negative,
      VoteDeckSwipeDirection.skip => SwipeDecisionDirection.skip,
    };
    return _cardKey.currentState?.swipeAway(mapped) ?? Future<void>.value();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SwipeDecisionCard(
      key: _cardKey,
      itemKey: widget.itemKey,
      enabled: widget.enabled,
      // Tab Kontribusi: deck di luar scroll parent (lihat ActivityPage).
      allowNestedVerticalScroll: false,
      fallbackHeight: 240,
      positiveLabel: 'Masuk akal',
      negativeLabel: 'Kurang pas',
      skipLabel: 'Lewati',
      overlayStyle: SwipeDecisionOverlayStyle.icon,
      positiveIcon: FLucideIcons.arrowBigUp,
      negativeIcon: FLucideIcons.arrowBigDown,
      // Skip pakai skipForward supaya tidak bentrok visual dengan panah vote.
      skipIcon: FLucideIcons.skipForward,
      positiveColor: theme.colors.success,
      negativeColor: theme.colors.destructive,
      skipColor: theme.colors.mutedForeground,
      onSwiped: (direction) => widget.onSwiped(switch (direction) {
        SwipeDecisionDirection.positive => VoteDeckSwipeDirection.agree,
        SwipeDecisionDirection.negative => VoteDeckSwipeDirection.disagree,
        SwipeDecisionDirection.skip => VoteDeckSwipeDirection.skip,
      }),
      child: widget.child,
    );
  }
}
