import 'package:flutter/widgets.dart';

class ImagePlaceholder256 extends StatelessWidget {
  const ImagePlaceholder256({super.key});

  static const _fallbackExtent = 256.0;

  @override
  Widget build(BuildContext context) {
    // Jangan paksa infinity di sumbu unbounded (mis. ListView markdown):
    // Image(height: infinity) di situ = RenderBox size Infinity / NaN paint.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _fallbackExtent;
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : _fallbackExtent;
        return Image.asset(
          'assets/images/placeholder_256.png',
          fit: BoxFit.cover,
          width: w,
          height: h,
        );
      },
    );
  }
}
