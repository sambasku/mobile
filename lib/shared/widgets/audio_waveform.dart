import 'dart:math' as math;

import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

/// Grafik batang waveform (pola sama editor audio lemma).
///
/// [progress] 0..1 mewarnai batang kiri (posisi putar). Null = semua
/// [selectedColor].
class AudioWaveform extends StatelessWidget {
  const AudioWaveform({
    super.key,
    required this.peaks,
    this.progress,
    this.height = 64,
    this.barColor,
    this.selectedColor,
    this.trackColor,
  });

  final List<double> peaks;
  final double? progress;
  final double height;
  final Color? barColor;
  final Color? selectedColor;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _AudioWaveformPainter(
          peaks: peaks,
          progress: progress,
          barColor: barColor ?? theme.colors.mutedForeground.withValues(alpha: 0.35),
          selectedColor: selectedColor ?? theme.colors.primary,
          trackColor: trackColor ?? theme.colors.secondary,
        ),
      ),
    );
  }
}

class _AudioWaveformPainter extends CustomPainter {
  _AudioWaveformPainter({
    required this.peaks,
    required this.progress,
    required this.barColor,
    required this.selectedColor,
    required this.trackColor,
  });

  final List<double> peaks;
  final double? progress;
  final Color barColor;
  final Color selectedColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = trackColor.withValues(alpha: 0.5),
    );

    if (peaks.isEmpty || size.width <= 0 || size.height <= 0) return;

    final n = peaks.length;
    const gap = 1.0;
    final barW = math.max(1.0, (size.width - gap * (n - 1)) / n);
    final midY = size.height / 2;
    final maxH = size.height * 0.85;
    final prog = progress;

    for (var i = 0; i < n; i++) {
      final t = (i + 0.5) / n;
      final active = prog == null ? true : t <= prog;
      final h = math.max(2.0, peaks[i] * maxH);
      final x = i * (barW + gap);
      final paint = Paint()
        ..color = active ? selectedColor : barColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x + barW / 2, midY),
            width: barW,
            height: h,
          ),
          const Radius.circular(1),
        ),
        paint,
      );
    }

    if (prog != null) {
      final x = prog.clamp(0.0, 1.0) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = selectedColor
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AudioWaveformPainter oldDelegate) {
    return oldDelegate.peaks != peaks ||
        oldDelegate.progress != progress ||
        oldDelegate.barColor != barColor ||
        oldDelegate.selectedColor != selectedColor ||
        oldDelegate.trackColor != trackColor;
  }
}
