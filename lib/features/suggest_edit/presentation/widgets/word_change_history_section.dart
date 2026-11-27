import 'package:flutter/widgets.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/change_history/change_history_controller.dart';
import '../../../../shared/change_history/change_history_timeline.dart';

// Helper nilai riwayat dipindah ke shared; re-export agar import lama tetap jalan.
export '../../../../shared/change_history/change_history_values.dart'
    show friendlyChangeValue, isTechnicalChangeField;

/// Timeline riwayat perubahan kata (kata + arti, contoh, foto, rekaman).
/// Halaman penuh dibuka dari action AppBar di detail kata.
class WordChangeHistorySection extends StatelessWidget {
  const WordChangeHistorySection({super.key, required this.wordId});

  final String wordId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ChangeHistoryTimeline(
      path: wordChangeHistoryPath(wordId),
      notFoundTitle: l10n.historyWordNotFound,
      emptyHint: l10n.historyEmptyHint,
    );
  }
}
