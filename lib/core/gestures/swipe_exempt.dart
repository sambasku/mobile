import 'package:flutter/widgets.dart';

/// Pointer yang mulai di dalam [SwipeExemptRegion] tidak ikut geser kartu.
class SwipeExemptHub {
  SwipeExemptHub._();

  static final Set<int> _pointers = <int>{};

  static void add(int pointer) => _pointers.add(pointer);

  static void remove(int pointer) => _pointers.remove(pointer);

  static bool contains(int pointer) => _pointers.contains(pointer);
}

/// Bungkus radio / tombol di dalam kartu swipe. Tap dan geser di sini
/// tidak menggeser kartu induk.
class SwipeExemptRegion extends StatelessWidget {
  const SwipeExemptRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) => SwipeExemptHub.add(event.pointer),
      onPointerUp: (event) => SwipeExemptHub.remove(event.pointer),
      onPointerCancel: (event) => SwipeExemptHub.remove(event.pointer),
      child: child,
    );
  }
}
