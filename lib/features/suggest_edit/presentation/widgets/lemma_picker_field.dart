import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';

/// Field lemma dengan saran ketik (typeahead). User boleh menulis lemma baru
/// yang belum ada di kamus - API membuatnya sebagai kata baru saat usulan
/// disetujui verifikator.
class LemmaPickerField extends ConsumerStatefulWidget {
  const LemmaPickerField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.error,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Widget? error;

  @override
  ConsumerState<LemmaPickerField> createState() => _LemmaPickerFieldState();
}

class _LemmaPickerFieldState extends ConsumerState<LemmaPickerField> {
  Timer? _debounce;
  int _seq = 0;
  List<String> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _search);
  }

  Future<void> _search() async {
    // Ambil kata terakhir yang belum berkoma - itu yang sedang diketik.
    final parts = widget.controller.text.split(',');
    final query = parts.last.trim();
    if (query.length < 2) {
      if (mounted) setState(() => _suggestions = const []);
      return;
    }
    final seq = ++_seq;
    try {
      final res = await ref
          .read(dioProvider)
          .get<Map<String, dynamic>>(
            '/api/v1/words/search',
            queryParameters: {'q': query, 'limit': 8},
          );
      if (!mounted || seq != _seq) return; // respons usang
      final data = res.data?['data'];
      final picked = <String>{
        for (final item in data is List ? data : const [])
          if (item is Map && item['lemma'] is String) (item['lemma'] as String).trim(),
      };
      final typed = parts.map((e) => e.trim().toLowerCase()).toSet();
      setState(() => _suggestions = picked
          .where((l) => l.isNotEmpty && !typed.contains(l.toLowerCase()))
          .toList(growable: false));
    } on Object {
      // Saran bersifat opsional - gagal cari tidak boleh memblokir submit.
      if (mounted && seq == _seq) setState(() => _suggestions = const []);
    }
  }

  void _pick(String lemma) {
    final parts = widget.controller.text.split(',').map((e) => e.trim()).toList();
    parts[parts.length - 1] = lemma;
    widget.controller.text = '${parts.join(', ')}, ';
    widget.controller.selection =
        TextSelection.collapsed(offset: widget.controller.text.length);
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTextField(
          control: FTextFieldControl.managed(controller: widget.controller),
          label: Text(widget.label),
          hint: widget.hint,
          error: widget.error,
        ),
        if (_suggestions.isNotEmpty) ...[
          const Gap(8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final lemma in _suggestions)
                FButton(
                  variant: FButtonVariant.outline,
                  size: FButtonSizeVariant.sm,
                  onPress: () => _pick(lemma),
                  child: Text(lemma),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
