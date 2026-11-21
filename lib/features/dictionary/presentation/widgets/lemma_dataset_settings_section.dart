import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../data/dataset/lemma_dataset_providers.dart';
import '../../data/dataset/lemma_dataset_updater.dart';

/// Grup Settings: versi kamus lokal + tombol OTA manual.
class LemmaDatasetSettingsSection extends ConsumerStatefulWidget {
  const LemmaDatasetSettingsSection({super.key});

  @override
  ConsumerState<LemmaDatasetSettingsSection> createState() =>
      _LemmaDatasetSettingsSectionState();
}

class _LemmaDatasetSettingsSectionState
    extends ConsumerState<LemmaDatasetSettingsSection> {
  var _busy = false;

  Future<void> _onUpdate() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context);
    try {
      final updater = ref.read(lemmaDatasetUpdaterProvider);
      final result = await updater.update();
      if (!mounted) return;
      switch (result.outcome) {
        case LemmaDatasetUpdateOutcome.updated:
          showFToast(
            context: context,
            title: Text(l10n.lemmaDatasetUpdated),
          );
        case LemmaDatasetUpdateOutcome.alreadyLatest:
          showFToast(
            context: context,
            title: Text(l10n.lemmaDatasetAlreadyLatest),
          );
        case LemmaDatasetUpdateOutcome.offline:
          await showAppErrorSheet(
            context,
            message: l10n.lemmaDatasetNeedInternet,
          );
        case LemmaDatasetUpdateOutcome.hashMismatch:
          await showAppErrorSheet(
            context,
            message: l10n.lemmaDatasetHashFailed,
          );
        case LemmaDatasetUpdateOutcome.appUpdateRequired:
          await showAppErrorSheet(
            context,
            message: l10n.lemmaDatasetAppUpdateRequired,
          );
        case LemmaDatasetUpdateOutcome.incompatibleSchema:
          await showAppErrorSheet(
            context,
            message: l10n.lemmaDatasetIncompatible,
          );
        case LemmaDatasetUpdateOutcome.busy:
          break;
        case LemmaDatasetUpdateOutcome.downloadFailed:
        case LemmaDatasetUpdateOutcome.swapFailed:
        case LemmaDatasetUpdateOutcome.invalidPointer:
          await showAppErrorSheet(
            context,
            message: l10n.lemmaDatasetUpdateFailed,
          );
      }
      ref.invalidate(lemmaInstalledMetaProvider);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metaAsync = ref.watch(lemmaInstalledMetaProvider);
    final versionLabel = metaAsync.maybeWhen(
      data: (meta) => meta == null
          ? l10n.lemmaDatasetVersionUnknown
          : l10n.lemmaDatasetVersion(meta.releaseVersion),
      orElse: () => l10n.lemmaDatasetVersionUnknown,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTileGroup(
          label: Text(l10n.lemmaDatasetGroup),
          children: [
            FTile(
              prefix: _busy
                  ? const FCircularProgress()
                  : const Icon(FLucideIcons.database, size: 18),
              title: Text(
                _busy ? l10n.lemmaDatasetUpdating : l10n.lemmaDatasetUpdate,
              ),
              subtitle: Text(versionLabel),
              onPress: _busy ? null : _onUpdate,
            ),
          ],
        ),
        const Gap(8),
      ],
    );
  }
}
