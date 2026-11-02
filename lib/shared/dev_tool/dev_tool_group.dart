import 'package:material_ui/material_ui.dart';

import 'dev_tool_inspector.dart';

/// Folder di dashboard Dev Tools. Tap membuka daftar [children].
class DevToolGroup extends DevToolInspector {
  DevToolGroup({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required List<DevToolInspector> children,
  }) : children = List.unmodifiable(children);

  @override
  final String name;

  @override
  final String description;

  @override
  final IconData icon;

  @override
  final Color color;

  @override
  final List<DevToolInspector> children;

  @override
  Widget buildPage(BuildContext context) {
    throw UnsupportedError(
      'DevToolGroup("$name") memakai children, bukan buildPage',
    );
  }
}
