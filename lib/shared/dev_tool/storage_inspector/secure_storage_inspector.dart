import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../dev_tool_inspector.dart';

class SecureStorageInspector extends DevToolInspector {
  @override
  Color get color => const Color(0xFF27AE60);

  @override
  String get description => 'Lihat isi FlutterSecureStorage';

  @override
  IconData get icon => FLucideIcons.lock;

  @override
  String get name => 'Secure Storage';

  @override
  Widget buildPage(BuildContext context) => const _SecureStoragePage();
}

class _SecureStoragePage extends StatefulWidget {
  const _SecureStoragePage();

  @override
  State<_SecureStoragePage> createState() => _SecureStoragePageState();
}

class _SecureStoragePageState extends State<_SecureStoragePage> {
  final _storage = const FlutterSecureStorage();
  Map<String, String> _data = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _data = await _storage.readAll();
    setState(() => _loading = false);
  }

  Future<void> _clear() async {
    await _storage.deleteAll();
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
                    return _EntryTile(keyValue: entry.key, value: entry.value);
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
