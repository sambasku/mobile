import 'package:flutter/gestures.dart';

/// Pan that competes with scrollables, but only steals the arena once the
/// gesture looks intentional (past [claimSlop] on a claimable axis).
///
/// - Horizontal past slop → always claim (approve / reject).
/// - Vertical **up** past slop → claim only if [shouldClaimVertical] is null
///   or returns `true` (e.g. nested list is scrolled to top).
/// - Vertical **down** → never claim; let the scrollable keep the drag.
class SoftEagerPanGestureRecognizer extends PanGestureRecognizer {
  SoftEagerPanGestureRecognizer({
    this.claimSlop = 12.0,
    this.shouldClaimVertical,
    super.debugOwner,
    super.supportedDevices,
  });

  final double claimSlop;

  /// When upward vertical intent dominates, return `false` to yield to a
  /// nested / parent scrollable (e.g. review body not at scroll offset 0).
  /// Mutable so [RawGestureDetector] can refresh the gate on rebuild.
  bool Function()? shouldClaimVertical;

  double _accumDx = 0;
  double _accumDy = 0;
  bool _claimed = false;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _accumDx = 0;
    _accumDy = 0;
    _claimed = false;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!_claimed && event is PointerMoveEvent) {
      _accumDx += event.delta.dx;
      _accumDy += event.delta.dy;
      if (_shouldClaimNow()) {
        _claimed = true;
        resolve(GestureDisposition.accepted);
      }
    }
    super.handleEvent(event);
  }

  bool _shouldClaimNow() {
    final ax = _accumDx.abs();
    final ay = _accumDy.abs();
    if (ax < claimSlop && ay < claimSlop) return false;
    if (ax >= ay) return true;
    // Vertical: only upward skip may steal; downward belongs to scroll.
    if (_accumDy >= 0) return false;
    return _verticalSkipAllowed();
  }

  /// Gate terbuka + gerakan naik melewati slop → boleh rebut arena dari scroll.
  bool _verticalSkipAllowed() {
    final gate = shouldClaimVertical;
    if (gate != null && !gate()) return false;
    return true;
  }

  @override
  void rejectGesture(int pointer) {
    // Jika scrollable menang arena dulu, rebut balik saat intent naik jelas
    // dan gate mengizinkan (Kontribusi: selalu; Tinjauan: list di atas).
    final upwardPastSlop =
        _accumDy < 0 && _accumDy.abs() >= claimSlop && _verticalSkipAllowed();
    if (_claimed || _shouldClaimNow() || upwardPastSlop) {
      _claimed = true;
      acceptGesture(pointer);
    } else {
      super.rejectGesture(pointer);
    }
  }
}
