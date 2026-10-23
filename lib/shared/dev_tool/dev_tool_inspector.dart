import 'package:material_ui/material_ui.dart';

/// Base class untuk semua DevTool inspector.
///
/// Setiap inspector baru cukup meng-extend class ini dan mengimplementasi
/// semua getter serta [buildPage]. Inspector akan otomatis muncul di
/// DevTool dashboard. Untuk folder / submenu, pakai [DevToolGroup]
/// (atau override [children]).
///
/// Contoh:
/// ```dart
/// class NetworkInspector extends DevToolInspector {
///   @override
///   String get name => 'Network';
///
///   @override
///   String get description => 'Monitor API calls';
///
///   @override
///   IconData get icon => FLucideIcons.wifi;
///
///   @override
///   Color get color => const Color(0xFF1A73E8);
///
///   @override
///   Widget buildPage(BuildContext context) => const NetworkPage();
/// }
/// ```
abstract class DevToolInspector {
  /// Nama tampilan inspector.
  String get name;

  /// Deskripsi singkat yang ditampilkan di bawah nama.
  String get description;

  /// Icon yang ditampilkan di grid card.
  IconData get icon;

  /// Warna tema untuk icon background.
  Color get color;

  /// Sub-menu. Jika tidak kosong, tap membuka daftar anak (bukan [buildPage]).
  List<DevToolInspector> get children => const [];

  /// True jika inspector ini adalah folder / group.
  bool get isGroup => children.isNotEmpty;

  /// Halaman inspector yang ditampilkan saat card di-tap (hanya untuk leaf).
  Widget buildPage(BuildContext context);

  /// Aksi tambahan di pojok kanan AppBar saat inspector aktif.
  List<Widget>? get appBarActions => null;
}
