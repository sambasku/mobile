import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../widgets/word_change_history_section.dart';

/// Halaman penuh riwayat perubahan kata - GET /api/v1/words/:id/change-history.
/// Dibuka dari action AppBar di detail kata (bukan section inline).
class WordChangeHistoryPage extends StatelessWidget {
  const WordChangeHistoryPage({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Riwayat perubahan'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
        children: [WordChangeHistorySection(wordId: wordId)],
      ),
    );
  }
}
