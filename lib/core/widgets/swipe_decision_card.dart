import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import '../gestures/soft_eager_pan_gesture_recognizer.dart';
import '../theme/f_colors_x.dart';

/// Kanan = positif, kiri = negatif, atas = lewati.
enum SwipeDecisionDirection { positive, negative, skip }

enum _AxisLock { none, horizontal, vertical }

/// Bagaimana overlay keputusan digambar saat drag.
enum SwipeDecisionOverlayStyle { label, icon }

/// Kartu swipe bersama: axis-lock + soft-eager pan vs scrollable.
///
/// [onSwiped] return `true` = kartu tetap keluar; `false` = spring back.
///
/// [allowNestedVerticalScroll]: pantau scroll anak; swipe-atas skip diklaim
/// hanya saat konten muat (maxScrollExtent ≈ 0). Isi panjang di-scroll biasa;
/// lewati lewat tombol supaya tidak perang gesture finger-up.
class SwipeDecisionCard extends StatefulWidget {
  const SwipeDecisionCard({
    super.key,
    required this.itemKey,
    required this.enabled,
    required this.onSwiped,
    required this.child,
    required this.positiveLabel,
    required this.negativeLabel,
    required this.skipLabel,
    this.overlayStyle = SwipeDecisionOverlayStyle.label,
    this.positiveIcon,
    this.negativeIcon,
    this.skipIcon,
    this.positiveColor,
    this.negativeColor,
    this.skipColor,
    this.allowNestedVerticalScroll = false,
    this.fallbackHeight = 240,
  });

  final Object itemKey;
  final bool enabled;
  final Future<bool> Function(SwipeDecisionDirection direction) onSwiped;
  final Widget child;
  final String positiveLabel;
  final String negativeLabel;
  final String skipLabel;
  final SwipeDecisionOverlayStyle overlayStyle;

  /// Ikon overlay saat [overlayStyle] == icon. Default: check / x / arrowUp.
  final IconData? positiveIcon;
  final IconData? negativeIcon;
  final IconData? skipIcon;

  /// Warna overlay ikon. Default: success / destructive / mutedForeground.
  final Color? positiveColor;
  final Color? negativeColor;
  final Color? skipColor;

  final bool allowNestedVerticalScroll;
  final double fallbackHeight;

  @override
  State<SwipeDecisionCard> createState() => SwipeDecisionCardState();
}

class SwipeDecisionCardState extends State<SwipeDecisionCard>
    with SingleTickerProviderStateMixin {
  static const _thresholdFraction = 0.28;
  static const _flingVelocity = 700.0;
  static const _axisLockSlop = 12.0;
  static const _overlayMaxOpacity = 0.75;
  static const _overlayMinScale = 0.72;
  static const _overlayMaxScale = 1.08;
  static const _overlayVisibleFloor = 0.05;

  late final AnimationController _anim;
  double _dx = 0;
  double _dy = 0;
  double _width = 1;
  double _height = 1;
  _AxisLock _lock = _AxisLock.none;
  bool _busyGesture = false;
  bool _hapticFired = false;
  Animation<Offset>? _tween;

  /// Pixels scroll anak (hanya relevan jika [allowNestedVerticalScroll]).
  double _childScrollPixels = 0;
  double _childMaxScrollExtent = 0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final t = _tween;
        if (t == null) return;
        setState(() {
          _dx = t.value.dx;
          _dy = t.value.dy;
        });
      });
  }

  @override
  void didUpdateWidget(covariant SwipeDecisionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemKey != widget.itemKey) {
      _anim.stop();
      _tween = null;
      _dx = 0;
      _dy = 0;
      _lock = _AxisLock.none;
      _busyGesture = false;
      _hapticFired = false;
      _childScrollPixels = 0;
      _childMaxScrollExtent = 0;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> swipeAway(SwipeDecisionDirection direction) =>
      _commit(direction);

  double get _hProgress {
    final denom = _width * _thresholdFraction;
    if (denom <= 0) return 0;
    return (_dx / denom).clamp(-1.5, 1.5);
  }

  double get _vProgress {
    final denom = _height * _thresholdFraction;
    if (denom <= 0) return 0;
    return (-_dy / denom).clamp(0.0, 1.5);
  }

  bool _canClaimVerticalSkip() {
    if (!widget.allowNestedVerticalScroll) return true;
    // Konten muat → swipe atas = lewati (tidak ada scroll yang bermakna).
    // Konten panjang → biarkan ListView; lewati lewat tombol action bar.
    // (Klaim di puncak/dasar bertabrakan dengan arah scroll finger-up.)
    return _childMaxScrollExtent <= 0.5;
  }

  Future<void> _animateTo(Offset target, {Duration? duration}) async {
    _anim.duration = duration ?? const Duration(milliseconds: 220);
    _tween = Tween<Offset>(begin: Offset(_dx, _dy), end: target).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
    _anim.reset();
    await _anim.forward();
  }

  Future<void> _springBack() async {
    await _animateTo(Offset.zero, duration: const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() {
      _busyGesture = false;
      _hapticFired = false;
      _lock = _AxisLock.none;
    });
  }

  Future<void> _commit(SwipeDecisionDirection direction) async {
    if (_busyGesture) return;
    if (!widget.enabled) return;
    setState(() => _busyGesture = true);

    final target = switch (direction) {
      SwipeDecisionDirection.positive => Offset(_width * 1.35, 0),
      SwipeDecisionDirection.negative => Offset(-_width * 1.35, 0),
      SwipeDecisionDirection.skip => Offset(0, -_height * 1.35),
    };
    await _animateTo(target, duration: const Duration(milliseconds: 200));
    if (!mounted) return;

    final keepDismissed = await widget.onSwiped(direction);
    if (!mounted) return;
    if (keepDismissed) {
      setState(() => _busyGesture = false);
      return;
    }
    await _springBack();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _busyGesture) return;
    final d = details.delta;
    setState(() {
      if (_lock == _AxisLock.none) {
        _dx += d.dx;
        _dy += d.dy;
        final ax = _dx.abs();
        final ay = _dy.abs();
        if (ax > _axisLockSlop || ay > _axisLockSlop) {
          if (ax >= ay) {
            _lock = _AxisLock.horizontal;
            _dy = 0;
          } else {
            _lock = _AxisLock.vertical;
            _dx = 0;
            if (_dy > 0) _dy = 0;
          }
        }
      } else if (_lock == _AxisLock.horizontal) {
        _dx += d.dx;
      } else {
        _dy = (_dy + d.dy).clamp(-_height * 1.5, 0);
      }

      final crossed = _lock == _AxisLock.horizontal
          ? _hProgress.abs() >= 1.0
          : _vProgress >= 1.0;
      if (crossed && !_hapticFired) {
        _hapticFired = true;
        HapticFeedback.selectionClick();
      } else if (!crossed) {
        _hapticFired = false;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.enabled || _busyGesture) return;
    final vx = details.velocity.pixelsPerSecond.dx;
    final vy = details.velocity.pixelsPerSecond.dy;
    final hThresh = _width * _thresholdFraction;
    final vThresh = _height * _thresholdFraction;

    if (_lock == _AxisLock.horizontal) {
      final positive = _dx > hThresh || (_dx > 0 && vx > _flingVelocity);
      final negative = _dx < -hThresh || (_dx < 0 && vx < -_flingVelocity);
      if (positive) {
        _commit(SwipeDecisionDirection.positive);
      } else if (negative) {
        _commit(SwipeDecisionDirection.negative);
      } else {
        _springBack();
      }
      return;
    }

    if (_lock == _AxisLock.vertical) {
      final skip = _dy < -vThresh || vy < -_flingVelocity;
      if (skip) {
        _commit(SwipeDecisionDirection.skip);
      } else {
        _springBack();
      }
      return;
    }

    _springBack();
  }

  void _syncChildScrollMetrics(ScrollMetrics metrics) {
    if (metrics.axis != Axis.vertical) return;
    final pixels = metrics.pixels;
    final max = metrics.maxScrollExtent;
    if ((pixels - _childScrollPixels).abs() > 0.5 ||
        (max - _childMaxScrollExtent).abs() > 0.5) {
      _childScrollPixels = pixels;
      _childMaxScrollExtent = max;
    }
  }

  bool _onChildScroll(ScrollNotification notification) {
    if (!widget.allowNestedVerticalScroll) return false;
    _syncChildScrollMetrics(notification.metrics);
    return false;
  }

  bool _onChildMetrics(ScrollMetricsNotification notification) {
    if (!widget.allowNestedVerticalScroll) return false;
    _syncChildScrollMetrics(notification.metrics);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final h = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : widget.fallbackHeight;
        if (w != _width) _width = w;
        if (h != _height) _height = h;

        final hProg = _hProgress;
        final positiveT = hProg.clamp(0.0, 1.0);
        final negativeT = (-hProg).clamp(0.0, 1.0);
        final skipT = _vProgress.clamp(0.0, 1.0);
        final angle = (_dx / _width) * 0.22;

        final canPan = widget.enabled && !_busyGesture;
        Widget body = widget.child;
        if (widget.allowNestedVerticalScroll) {
          body = NotificationListener<ScrollMetricsNotification>(
            onNotification: _onChildMetrics,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onChildScroll,
              child: body,
            ),
          );
        }

        return RawGestureDetector(
          gestures: {
            SoftEagerPanGestureRecognizer: GestureRecognizerFactoryWithHandlers<
                SoftEagerPanGestureRecognizer>(
              () => SoftEagerPanGestureRecognizer(
                claimSlop: _axisLockSlop,
                shouldClaimVertical: _canClaimVerticalSkip,
              ),
              (instance) {
                instance
                  ..shouldClaimVertical = _canClaimVerticalSkip
                  ..onUpdate = canPan ? _onPanUpdate : null
                  ..onEnd = canPan ? _onPanEnd : null
                  ..onCancel = canPan ? () => _springBack() : null;
              },
            ),
          },
          behavior: HitTestBehavior.translucent,
          child: Transform.translate(
            offset: Offset(_dx, _dy),
            child: Transform.rotate(
              angle: angle,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      body,
                      if (widget.overlayStyle == SwipeDecisionOverlayStyle.label) ...[
                        _SwipeLabelOverlay(
                          t: positiveT,
                          label: widget.positiveLabel,
                          color: theme.colors.success,
                        ),
                        _SwipeLabelOverlay(
                          t: negativeT,
                          label: widget.negativeLabel,
                          color: theme.colors.destructive,
                        ),
                        _SwipeLabelOverlay(
                          t: skipT,
                          label: widget.skipLabel,
                          color: theme.colors.mutedForeground,
                        ),
                      ] else ...[
                        _SwipeIconOverlay(
                          t: positiveT,
                          icon: widget.positiveIcon ?? FLucideIcons.check,
                          color: widget.positiveColor ?? theme.colors.success,
                          semanticsLabel: widget.positiveLabel,
                        ),
                        _SwipeIconOverlay(
                          t: negativeT,
                          icon: widget.negativeIcon ?? FLucideIcons.x,
                          color:
                              widget.negativeColor ?? theme.colors.destructive,
                          semanticsLabel: widget.negativeLabel,
                        ),
                        _SwipeIconOverlay(
                          t: skipT,
                          icon: widget.skipIcon ?? FLucideIcons.arrowUp,
                          color: widget.skipColor ??
                              theme.colors.mutedForeground,
                          semanticsLabel: widget.skipLabel,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SwipeLabelOverlay extends StatelessWidget {
  const _SwipeLabelOverlay({
    required this.t,
    required this.label,
    required this.color,
  });

  final double t;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (t < SwipeDecisionCardState._overlayVisibleFloor) {
      return const SizedBox.shrink();
    }
    final opacity = (t * SwipeDecisionCardState._overlayMaxOpacity)
        .clamp(0.0, SwipeDecisionCardState._overlayMaxOpacity);
    final scale = lerpDouble(
      SwipeDecisionCardState._overlayMinScale,
      SwipeDecisionCardState._overlayMaxScale,
      t,
    )!;
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: context.theme.typography.sm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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

class _SwipeIconOverlay extends StatelessWidget {
  const _SwipeIconOverlay({
    required this.t,
    required this.icon,
    required this.color,
    required this.semanticsLabel,
  });

  final double t;
  final IconData icon;
  final Color color;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final opacity = t * SwipeDecisionCardState._overlayMaxOpacity;
    if (opacity < SwipeDecisionCardState._overlayVisibleFloor) {
      return const SizedBox.shrink();
    }
    final scale = lerpDouble(
      SwipeDecisionCardState._overlayMinScale,
      SwipeDecisionCardState._overlayMaxScale,
      t,
    )!;
    return Positioned.fill(
      child: IgnorePointer(
        child: Semantics(
          label: semanticsLabel,
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Icon(icon, size: 96, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
