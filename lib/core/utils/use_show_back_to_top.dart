import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Visibility tombol "kembali ke atas" dari [ScrollController].
///
/// Return [ValueNotifier] supaya halaman TIDAK rebuild tiap frame scroll -
/// hanya subtree yang listen (tombol) yang update. Threshold default 480
/// (~satu viewport pendek) supaya tombol tidak berkedip di scroll kecil.
ValueNotifier<bool> useShowBackToTop(
  ScrollController scroll, {
  double threshold = 480,
}) {
  final visible = useValueNotifier(false);

  useEffect(() {
    void listener() {
      if (!scroll.hasClients) return;
      final next = scroll.position.pixels > threshold;
      if (visible.value != next) visible.value = next;
    }

    scroll.addListener(listener);
    // Sync awal: controller bisa sudah punya offset (restore / jump).
    WidgetsBinding.instance.addPostFrameCallback((_) => listener());
    return () => scroll.removeListener(listener);
  }, [scroll, threshold]);

  return visible;
}
