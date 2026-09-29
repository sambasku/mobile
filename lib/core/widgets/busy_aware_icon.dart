import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Ikon tombol yang diganti spinner hanya saat [loading] true.
///
/// Aturan busy UI (login, action bar, dll.):
/// - Spinner / label loading **hanya** di tombol aksi yang memicu request.
/// - Tombol & input lain: **disabled**, tanpa spinner.
class BusyAwareIcon extends StatelessWidget {
  const BusyAwareIcon({
    super.key,
    required this.loading,
    required this.icon,
    this.size = 18,
  });

  final bool loading;
  final Widget icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (!loading) return icon;
    return SizedBox(
      width: size,
      height: size,
      child: const FCircularProgress(),
    );
  }
}
