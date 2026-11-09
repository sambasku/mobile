import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';

/// Sheet usul terjemahan ID. Pop String body atau null.
Future<String?> showJinyeTranslationSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const _JinyeTranslationSheet(),
  );
}

class _JinyeTranslationSheet extends StatefulWidget {
  const _JinyeTranslationSheet();

  @override
  State<_JinyeTranslationSheet> createState() => _JinyeTranslationSheetState();
}

class _JinyeTranslationSheetState extends State<_JinyeTranslationSheet> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final canSubmit = _ctrl.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.jinyeTranslateTitle,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FTextField(
              control: FTextFieldControl.managed(
                controller: _ctrl,
                onChange: (_) => setState(() {}),
              ),
              hint: l10n.jinyeTranslateHint,
              maxLines: 4,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: FButton(
                onPress: canSubmit
                    ? () => Navigator.pop(context, _ctrl.text.trim())
                    : null,
                child: Text(l10n.jinyeTranslateSubmit),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
