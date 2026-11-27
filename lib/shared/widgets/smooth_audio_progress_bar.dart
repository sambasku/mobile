import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Progress bar audio 60fps berbasis [Ticker] yang menginterpolasi posisi
/// di antara tick `just_audio` tanpa memicu rebuild Riverpod per frame.
class SmoothAudioProgressBar extends StatefulWidget {
  const SmoothAudioProgressBar({
    super.key,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.color,
    required this.trackColor,
    required this.enabled,
    this.onSeek,
    this.semanticsLabel,
  });

  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final Color color;
  final Color trackColor;
  final bool enabled;
  final ValueChanged<double>? onSeek;
  final String? semanticsLabel;

  @override
  State<SmoothAudioProgressBar> createState() => _SmoothAudioProgressBarState();
}

class _SmoothAudioProgressBarState extends State<SmoothAudioProgressBar>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastTickElapsed = Duration.zero;
  double _displayMs = 0;
  double? _draggingRatio;

  double get _totalMs => widget.duration.inMilliseconds.toDouble();

  @override
  void initState() {
    super.initState();
    _displayMs = widget.position.inMilliseconds.toDouble();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant SmoothAudioProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.position != oldWidget.position && _draggingRatio == null) {
      final incomingMs = widget.position.inMilliseconds.toDouble();
      final drift = incomingMs - _displayMs;
      // Snap langsung saat tidak sedang play, mundur jauh (seek/reset), atau drift > 250ms.
      if (!widget.isPlaying || drift.abs() > 250 || drift < -80) {
        _displayMs = incomingMs;
      } else {
        // Koreksi halus agar tidak mundur patah-patah di antara tick stream.
        _displayMs = (_displayMs + drift * 0.35).clamp(
          0.0,
          _totalMs > 0 ? _totalMs : incomingMs,
        );
      }
    }

    if (!widget.isPlaying && oldWidget.isPlaying && _draggingRatio == null) {
      _displayMs = widget.position.inMilliseconds.toDouble();
    }

    _syncTicker();
  }

  void _syncTicker() {
    final disableAnim = MediaQuery.disableAnimationsOf(context);
    final shouldRun =
        widget.isPlaying &&
        !disableAnim &&
        _totalMs > 0 &&
        _draggingRatio == null;
    if (shouldRun && !_ticker.isActive) {
      _lastTickElapsed = Duration.zero;
      _ticker.start();
    } else if (!shouldRun && _ticker.isActive) {
      _ticker.stop();
      _lastTickElapsed = Duration.zero;
    }
  }

  void _onTick(Duration elapsed) {
    final dtMs = (elapsed - _lastTickElapsed).inMicroseconds / 1000.0;
    _lastTickElapsed = elapsed;
    if (dtMs <= 0 || _totalMs <= 0 || _draggingRatio != null) return;
    final next = (_displayMs + dtMs).clamp(0.0, _totalMs);
    if ((next - _displayMs).abs() < 0.01) return;
    setState(() {
      _displayMs = next;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get _progress {
    if (_draggingRatio != null) return _draggingRatio!.clamp(0.0, 1.0);
    if (_totalMs <= 0) return 0.0;
    return (_displayMs / _totalMs).clamp(0.0, 1.0);
  }

  void _seekTo(double dx, double width, {bool dragging = false}) {
    if (!widget.enabled || widget.onSeek == null || width <= 0) return;
    final ratio = (dx / width).clamp(0.0, 1.0);
    setState(() {
      if (dragging) _draggingRatio = ratio;
      if (_totalMs > 0) _displayMs = ratio * _totalMs;
    });
    widget.onSeek!(ratio);
  }

  @override
  Widget build(BuildContext context) {
    final ratio = _progress;
    final bar = LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.enabled && widget.onSeek != null
              ? (d) => _seekTo(d.localPosition.dx, w)
              : null,
          onHorizontalDragStart: widget.enabled && widget.onSeek != null
              ? (d) {
                  _syncTicker();
                  _seekTo(d.localPosition.dx, w, dragging: true);
                }
              : null,
          onHorizontalDragUpdate: widget.enabled && widget.onSeek != null
              ? (d) => _seekTo(d.localPosition.dx, w, dragging: true)
              : null,
          onHorizontalDragEnd: widget.enabled && widget.onSeek != null
              ? (_) {
                  setState(() => _draggingRatio = null);
                  _syncTicker();
                }
              : null,
          onHorizontalDragCancel: widget.enabled && widget.onSeek != null
              ? () {
                  setState(() => _draggingRatio = null);
                  _syncTicker();
                }
              : null,
          child: SizedBox(
            height: 14,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 3,
                  width: w,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ColoredBox(color: widget.trackColor),
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: ratio,
                        child: ColoredBox(color: widget.color),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.semanticsLabel == null) return bar;
    return Semantics(
      label: widget.semanticsLabel,
      value: '${(ratio * 100).round()}%',
      slider: widget.enabled,
      child: bar,
    );
  }
}
