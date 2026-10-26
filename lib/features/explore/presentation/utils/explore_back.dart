import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Back kanonik halaman fitur Eksplorasi.
///
/// `context.pop()` bila ada stack; selain itu (dibuka dari deep link /
/// share link langsung) kembali ke tab Eksplorasi, bukan menutup app.
/// Dipakai juga oleh `PopScope` supaya tombol back sistem berperilaku sama
/// dengan tombol back di header.
void popOrGoExplore(BuildContext context) {
  if (exploreCanPop(context)) {
    context.pop();
    return;
  }
  context.go('/explore');
}

/// `context.canPop()` versi aman untuk `build`: `GoRouter.of` melempar bila
/// tidak ada GoRouter di pohon (mis. widget test halaman tunggal), jadi
/// jatuh ke Navigator terdekat.
bool exploreCanPop(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router != null) return router.canPop();
  return Navigator.maybeOf(context)?.canPop() ?? false;
}
