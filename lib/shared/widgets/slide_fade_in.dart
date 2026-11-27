import 'package:flutter/widgets.dart';

/// Animasi masuk ringan (slide + fade, opsional scale) untuk item baru
/// seperti komentar atau pesan chat yang baru terkirim.
///
/// Set [animate] = false untuk item lama (initial load / pagination) agar
/// tidak memicu animasi ulang saat scroll.
class SlideFadeIn extends StatefulWidget {
  const SlideFadeIn({
    super.key,
    required this.child,
    this.animate = true,
    this.duration = const Duration(milliseconds: 220),
    this.offset = const Offset(0, 0.08),
    this.scaleBegin = 1.0,
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final bool animate;
  final Duration duration;
  final Offset offset;
  final double scaleBegin;
  final Curve curve;

  @override
  State<SlideFadeIn> createState() => _SlideFadeInState();
}

class _SlideFadeInState extends State<SlideFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: widget.animate ? 0.0 : 1.0,
  );

  late final Animation<double> _curved = CurvedAnimation(
    parent: _ctrl,
    curve: widget.curve,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!widget.animate || MediaQuery.disableAnimationsOf(context)) {
      _ctrl.value = 1.0;
    } else {
      _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) return widget.child;

    Widget content = FadeTransition(
      opacity: _curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.offset,
          end: Offset.zero,
        ).animate(_curved),
        child: widget.child,
      ),
    );

    if (widget.scaleBegin != 1.0) {
      content = ScaleTransition(
        scale: Tween<double>(begin: widget.scaleBegin, end: 1.0).animate(
          _curved,
        ),
        child: content,
      );
    }

    return content;
  }
}
