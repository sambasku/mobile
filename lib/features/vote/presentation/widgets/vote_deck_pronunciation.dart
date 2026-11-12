import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/public_account_name.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../dictionary/dictionary_router.dart';
import '../../../dictionary/presentation/providers/pronunciation_providers.dart';
import '../../../dictionary/presentation/utils/ensure_microphone_ready.dart';
import '../../../dictionary/presentation/widgets/add_written_pronunciation_sheet.dart';
import '../../../dictionary/presentation/widgets/record_pronunciation_sheet.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../providers/vote_deck_providers.dart';

/// Kartu aktif deck (makna pertama antrean); null bila kosong / belum login.
VoteDeckItem? voteDeckActiveItem(WidgetRef ref) {
  final items = ref.read(voteDeckControllerProvider).value?.items;
  if (items == null || items.isEmpty) return null;
  return items.first;
}

/// Tulis IPA untuk kata di kartu deck (#260). Toast sukses dari sheet.
Future<void> openVoteDeckWrittenPronunciation({
  required BuildContext context,
  required WidgetRef ref,
  required VoteDeckItem item,
}) async {
  final saved = await showAddWrittenPronunciationSheet(
    context,
    wordId: item.wordId,
    lemma: item.lemma,
  );
  if (!context.mounted || saved == null || saved.isEmpty) return;
  ref
      .read(voteDeckControllerProvider.notifier)
      .patchPronunciation(item.id, pronunciationValue: saved);
}

/// Rekam audio lemma untuk kata di kartu deck (#260). Toast sukses dari sheet.
Future<void> openVoteDeckRecordPronunciation({
  required BuildContext context,
  required WidgetRef ref,
  required VoteDeckItem item,
}) async {
  if (ref.read(pronunciationUploadUnavailableProvider(item.wordId))) {
    return;
  }

  final auth = ref.read(authStatusProvider).value;
  final micReady = await ensureMicrophoneReady(context);
  if (!context.mounted || !micReady) return;

  final sent = await showRecordPronunciationSheet(
    context,
    ref: ref,
    wordId: item.wordId,
    languageId: item.languageId,
    spokenText: item.lemma,
    defaultSpeakerName: displayPublicAccountLabel(
      displayName: auth?.displayName,
      username: auth?.username,
    ),
  );
  if (!context.mounted || sent != true) return;
  ref
      .read(voteDeckControllerProvider.notifier)
      .patchPronunciation(item.id, hasAudio: true);
}

/// Menu kontribusi: tanpa kartu aktif → toast + pintasan Lengkapi kata.
Future<void> openVoteDeckPronunciationOrComplete({
  required BuildContext context,
  required WidgetRef ref,
  required bool record,
}) async {
  final item = voteDeckActiveItem(ref);
  if (item == null) {
    final l10n = AppLocalizations.of(context);
    showFToast(
      context: context,
      title: Text(l10n.voteDeckPronunciationNoCard),
    );
    if (context.mounted) {
      await context.push(DictionaryRouter.complete.path);
    }
    return;
  }
  if (record) {
    await openVoteDeckRecordPronunciation(
      context: context,
      ref: ref,
      item: item,
    );
  } else {
    await openVoteDeckWrittenPronunciation(
      context: context,
      ref: ref,
      item: item,
    );
  }
}
