import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import 'dev_tool_inspector.dart';

class DevToolPage extends StatefulWidget {
  const DevToolPage({
    super.key,
    required this.inspectors,
    this.onClose,
  });

  final List<DevToolInspector> inspectors;
  final VoidCallback? onClose;

  @override
  State<DevToolPage> createState() => _DevToolPageState();
}

class _DevToolPageState extends State<DevToolPage> {
  /// Stack folder yang sedang dibuka (root = kosong).
  final List<DevToolInspector> _groupPath = [];

  /// Leaf inspector yang sedang menampilkan [DevToolInspector.buildPage].
  DevToolInspector? _activeLeaf;

  List<DevToolInspector> get _currentList =>
      _groupPath.isEmpty ? widget.inspectors : _groupPath.last.children;

  String get _title {
    if (_activeLeaf != null) return _activeLeaf!.name;
    if (_groupPath.isNotEmpty) return _groupPath.last.name;
    return 'Dev Tools';
  }

  bool get _canGoBack => _activeLeaf != null || _groupPath.isNotEmpty;

  void _close() {
    if (_activeLeaf != null) {
      setState(() => _activeLeaf = null);
    } else if (_groupPath.isNotEmpty) {
      setState(() => _groupPath.removeLast());
    } else {
      widget.onClose?.call();
    }
  }

  void _open(DevToolInspector inspector) {
    if (inspector.isGroup) {
      setState(() => _groupPath.add(inspector));
    } else {
      setState(() => _activeLeaf = inspector);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaf = _activeLeaf;
    final theme = context.theme;

    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: FScaffold(
        childPad: true,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _close,
                      child: Icon(
                        _canGoBack ? FLucideIcons.arrowLeft : FLucideIcons.x,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Text(
                        _title,
                        style: theme.typography.body.xl.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (leaf != null) ...leaf.appBarActions ?? [],
                  ],
                ),
              ),
              const Gap(16),
              Expanded(
                child: leaf != null
                    ? Material(
                        type: MaterialType.transparency,
                        child: leaf.buildPage(context),
                      )
                    : _currentList.isEmpty
                        ? const _EmptyState()
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
                            children: [
                              FTileGroup(
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  for (final inspector in _currentList)
                                    _InspectorTile(
                                      inspector: inspector,
                                      onPress: () => _open(inspector),
                                    ),
                                ],
                              ),
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InspectorTile extends StatelessWidget with FTileMixin {
  const _InspectorTile({
    required this.inspector,
    required this.onPress,
  });

  final DevToolInspector inspector;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return FTile(
      title: Text(inspector.name),
      subtitle: Text(inspector.description),
      prefix: Icon(inspector.icon, color: inspector.color),
      suffix: const Icon(FLucideIcons.chevronRight),
      onPress: onPress,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FLucideIcons.wrench,
            size: 40,
            color: theme.colors.mutedForeground,
          ),
          const Gap(10),
          Text(
            'Belum ada inspector',
            style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(4),
          Text(
            'Tambahkan DevToolInspector ke daftar inspectors',
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
