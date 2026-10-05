import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Controller collaps blok header yang ngikutin scroll: 0 terbuka, 1 tertutup.
///
/// Return [Animation] (bukan nilai double) supaya halaman TIDAK rebuild tiap
/// frame scroll. Yang rebuild hanya subtree yang dibungkus [AnimatedBuilder]
/// di sekitar blok collaps. Dulu hook ini pakai useListenableSelector di
/// level build halaman: seluruh ListView/grid ikut rebuild per frame dan
/// scroll jadi berat.
///
/// Scroll-proportional: header ngikutin jari 1:1 sejauh [distance], bukan
/// biner show/hide. Saat jari lepas, snap mulus ke 0 atau 1. Di paling atas
/// (pixels <= 0) selalu 0 (terbuka).
Animation<double> useScrollCollapse(
  ScrollController scroll, {
  double distance = 90,
  Duration duration = const Duration(milliseconds: 280),
}) {
  final collapse = useAnimationController(duration: duration, initialValue: 0);
  final lastPixels = useRef<double>(0);

  useEffect(() {
    void listener() {
      if (!scroll.hasClients) return;
      final pixels = scroll.position.pixels;
      final delta = pixels - lastPixels.value;
      lastPixels.value = pixels;
      if (pixels <= 0) {
        collapse.animateBack(0, curve: Curves.easeOutCubic);
        return;
      }
      collapse.stop();
      collapse.value = (collapse.value + delta / distance).clamp(0.0, 1.0);
    }

    void idleListener() {
      // Jari lepas dan ballistics selesai: snap ke ujung terdekat.
      if (scroll.position.isScrollingNotifier.value) return;
      if (collapse.isAnimating) return;
      if (collapse.value > 0 && collapse.value < 1) {
        collapse.animateTo(
          collapse.value > 0.5 ? 1 : 0,
          curve: Curves.easeOutCubic,
        );
      }
    }

    // `scroll.position` belum ada saat init hook; daftarkan idle listener
    // setelah scrollable terpasang (bisa beberapa frame).
    scroll.addListener(listener);
    void attachIdle() {
      if (!scroll.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) => attachIdle());
        return;
      }
      scroll.position.isScrollingNotifier.addListener(idleListener);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => attachIdle());
    return () {
      scroll.removeListener(listener);
      if (scroll.hasClients) {
        scroll.position.isScrollingNotifier.removeListener(idleListener);
      }
    };
  }, [scroll]);

  return collapse;
}
