import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:sambasku_mobile/l10n/app_localizations.dart';

/// Info singkat di bawah field terjemahan: definisi diambil dari KBBI pihak
/// ketiga, dan pilihan user mengisi definisi + terjemahan sekaligus.
class KbbiSourceNotice extends StatelessWidget {
  const KbbiSourceNotice({super.key});

  @override
  Widget build(BuildContext context) => FAlert(
    icon: const Icon(FLucideIcons.info),
    title: Text(AppLocalizations.of(context).kbbiSourceNotice),
  );
}
