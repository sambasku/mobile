import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/api_error_text.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/reference/reference_data.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../contribution/presentation/utils/invalidate_word_detail.dart';
import '../../../contribution/presentation/widgets/word_class_picker_sheet.dart';
import '../../../suggest_edit/domain/suggest_category.dart';
import '../../../suggest_edit/domain/suggest_edit_feedback.dart';
import '../../../suggest_edit/presentation/suggest_edit_labels.dart';
import '../../domain/entities/vote_deck_item.dart';
import '../providers/vote_deck_providers.dart';

/// Shortcut kartu vote: bottom sheet kelas → POST suggest-edit langsung
/// (tanpa buka form usulan penuh). Target = makna kartu ([item.id]).
Future<void> pickAndSubmitVoteDeckWordClass({
  required BuildContext context,
  required WidgetRef ref,
  required VoteDeckItem item,
}) async {
  final l10n = AppLocalizations.of(context);
  final List<ReferenceItem> classes;
  try {
    classes = await ref.read(referenceWordClassesProvider.future);
  } catch (_) {
    if (!context.mounted) return;
    showFToast(
      context: context,
      title: Text(l10n.voteDeckWordClassLoadFailed),
    );
    return;
  }
  if (!context.mounted) return;

  final picked = await showWordClassPickerSheet(
    context,
    items: [
      for (final c in classes)
        WordClassPickItem(
          id: c.id,
          name: c.name,
          alias: c.alias,
          code: c.code,
        ),
    ],
    selectedId: item.wordClass?.id,
  );
  if (!context.mounted || picked == null) return;
  if (picked.id == item.wordClass?.id) return;

  final proposal = buildChangeWordClass(
    meaningId: item.id,
    originalWordClassId: item.wordClass?.id,
    wordClassId: picked.id,
  );
  if (proposal == null) return;

  final dio = ref.read(dioProvider);
  try {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/v1/words/${item.wordId}/suggest-edit',
      data: {
        'proposed_changes': proposal,
        'reason_code': 'change_word_class',
        'reason_text': l10n.voteDeckWordClassReason,
      },
    );
    if (!context.mounted) return;

    final selfApplied = suggestEditWasSelfApplied(
      responseStatus: suggestEditStatusFromResponse(response.data),
      actorRole: ref.read(authStatusProvider).value?.role,
    );
    showFToast(
      context: context,
      title: Text(
        suggestEditSuccessToast(
          selfApplied: selfApplied,
          wordVerified: false,
          lemma: item.lemma,
          l10n: l10n,
        ),
      ),
    );
    AnalyticsService.instance.log(
      AnalyticsEvents.suggestEditSubmit,
      params: {
        'word_id': item.wordId,
        'category': 'change_word_class',
        'source': 'vote_deck',
      },
    );
    await invalidateWordDetailCaches(ref, item.wordId, item.lemma);
    // #263: jangan refresh() - itu reset antrean ke page 1 API dan kartu loncat.
    // Self-apply: patch chip lokal; pending usulan: chip tetap (server belum berubah).
    if (selfApplied) {
      ref.read(voteDeckControllerProvider.notifier).patchWordClass(
            item.id,
            VoteDeckWordClass(
              id: picked.id,
              code: picked.code ?? '',
              name: picked.name,
              alias: picked.alias,
            ),
          );
    }
  } on DioException catch (error) {
    if (!context.mounted) return;
    final data = error.response?.data;
    final code = data is Map ? data['error_code']?.toString() : null;
    final message = apiErrorText(data, l10n.voteDeckWordClassSubmitFailed);
    if (code == 'RATE_LIMITED') {
      showFToast(context: context, title: Text(message));
    } else {
      await showAppErrorSheet(context, message: message);
    }
  }
}
