import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Keluar dari layar tinjau: pop jika ada history, else ke Profil.
///
/// Dipakai app bar dan [PopScope] supaya system back tidak menutup app
/// saat stack kosong (mis. setelah deep link atau `go` sebelumnya).
void leaveReview(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/profile');
  }
}
