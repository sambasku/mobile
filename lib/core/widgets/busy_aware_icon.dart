import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';

/// Ikon tombol yang diganti spinner hanya saat [loading] true.
///
/// Aturan busy UI (login, action bar, dll.):
/// - Spinner / label loading **hanya** di tombol aksi yang memicu request.
/// - Tombol & input lain: **disabled**, tanpa spinner.
class BusyAwareIcon extends StatelessWidget {
  const BusyAwareIcon({super.key, required this.loading, required this.icon});

  final bool loading;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    if (!loading) return icon;
    return const FCircularProgress(size: .md);
  }
}
