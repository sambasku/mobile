import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dev_tool_inspector.dart';

class SharedPrefInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFFE67E22);

  @override
  String get description => 'Lihat isi SharedPreferences';

  @override
  IconData get icon => FLucideIcons.database;

  @override
  String get name => 'Shared Pref';

  @override
  Widget buildPage(BuildContext context) => const _SharedPrefPage();
}

class _SharedPrefPage extends StatefulWidget {
  const _SharedPrefPage();

  @override
  State<_SharedPrefPage> createState() => _SharedPrefPageState();
}

class _SharedPrefPageState extends State<_SharedPrefPage> {
  Map<String, dynamic> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    _data = prefs.getKeys().fold<Map<String, dynamic>>({}, (map, key) {
      map[key] = prefs.get(key);
      return map;
    });
    setState(() => _loading = false);
  }

  Future<void> _clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: FCircularProgress.loader());
    }

    return Column(
      children: [
        // Tanpa horizontal - childPad FScaffold DevTool sudah pad.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              FButton(
                size: FButtonSizeVariant.xs,
                onPress: _load,
                child: const Text('Refresh'),
              ),
              const Gap(8),
              FButton(
                size: FButtonSizeVariant.xs,
                onPress: _data.isEmpty ? null : _clear,
                child: const Text('Clear'),
              ),
              const Gap(8),
              Text(
                '${_data.length} entries',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _data.isEmpty
              ? const Center(child: Text('Kosong'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _data.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = _data.entries.elementAt(index);
                    return _EntryTile(
                      keyValue: entry.key,
                      value: entry.value?.toString() ?? 'null',
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.keyValue, required this.value});

  final String keyValue;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: '$keyValue: $value'));
        showFToast(
          context: context,
          variant: FToastVariant.primary,
          icon: const Icon(Icons.check, size: 16),
          title: const Text('Disalin'),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              keyValue,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const Gap(2),
            Text(
              value,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
