import 'package:flutter/material.dart';

/// Nonaktifkan semantics halaman saat exit transition (back) berjalan.
///
/// Mencegah assertion "Invisible SemanticsNodes" dari widget yang rect-nya
/// negatif/keluar layar selama animasi pop - mis. tombol clear search
/// "Hapus" di FTextField yang ikut slide-out.
class ExcludeSemanticsOnExit extends StatelessWidget {
  const ExcludeSemanticsOnExit({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null) return child;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => ExcludeSemantics(
        // Saat pop, route.animation reverse dari 1 ke 0. Halaman yang
        // sedang keluar tidak relevan lagi untuk screen reader.
        excluding: animation.status == AnimationStatus.reverse,
        child: child,
      ),
    );
  }
}
