import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../domain/entities/word_detail.dart';
import '../utils/pronunciation_format.dart';
import 'add_written_pronunciation_sheet.dart';

/// Baris pelafalan tertulis di bawah lemma (Charis SIL, wrapped `/.../`),
/// atau CTA tambah bila kosong.
class WrittenPronunciationLine extends ConsumerWidget {
  const WrittenPronunciationLine({
    super.key,
    required this.wordId,
    required this.detail,
  });

  final String wordId;
  final WordDetail detail;

  TextStyle _ipaStyle(FThemeData theme) {
    return GoogleFonts.charisSil(
      fontSize: theme.typography.body.sm.fontSize,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      height: 1.3,
      color: theme.colors.mutedForeground,
    );
  }

  Future<void> _openAdd(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final auth = ref.read(authStatusProvider).value;
    if (!(auth?.isAuth ?? false)) {
      showFToast(
        context: context,
        title: Text(l10n.dictLoginToAddPronunciation),
      );
      context.push('/login');
      return;
    }
    await showAddWrittenPronunciationSheet(
      context,
      wordId: wordId,
      lemma: detail.lemma,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final line = pronunciationsDisplayLine(
      detail.pronunciations.map((p) => p.value),
    );

    if (line.isNotEmpty) {
      return Text(line, style: _ipaStyle(theme));
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: FButton(
        variant: FButtonVariant.ghost,
        onPress: () => _openAdd(context, ref),
        child: Text(l10n.dictAddPronunciation),
      ),
    );
  }
}
