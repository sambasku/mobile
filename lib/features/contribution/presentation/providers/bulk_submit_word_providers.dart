import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/auth_token_storage.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/failures/contribution_failure.dart';
import '../../domain/providers/contribution_domain_providers.dart';
import '../../domain/usecases/submit_anon_word_use_case.dart';
import '../models/bulk_submit_word_state.dart';

part 'bulk_submit_word_providers.g.dart';

@riverpod
class BulkSubmitWordNotifier extends _$BulkSubmitWordNotifier {
  var _nextId = 0;

  String _newId() => 'row_${_nextId++}';

  List<BulkContributeRow> _initialRows() => List.generate(
    BulkSubmitWordState.initialRowCount,
    (_) => BulkContributeRow(id: _newId()),
    growable: false,
  );

  @override
  BulkSubmitWordState build() {
    return BulkSubmitWordState(rows: _initialRows());
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  void clearBatchFinished() {
    state = state.copyWith(clearBatchFinished: true);
  }

  void addRow() {
    if (state.isSubmitting) return;
    if (state.rows.length >= BulkSubmitWordState.maxRows) return;
    state = state.copyWith(
      rows: [...state.rows, BulkContributeRow(id: _newId())],
      clearBatchFinished: true,
    );
  }

  void removeRow(String id) {
    if (state.isSubmitting) return;
    if (state.rows.length <= 1) return;
    final target = state.rows.where((r) => r.id == id).firstOrNull;
    if (target == null || !target.canRemove) return;
    state = state.copyWith(
      rows: state.rows.where((r) => r.id != id).toList(growable: false),
      clearBatchFinished: true,
    );
  }

  void updateRow(String id, {String? lemma, String? translation}) {
    if (state.isSubmitting) return;
    final rows = state.rows.map((r) {
      if (r.id != id) return r;
      if (!r.isEditable) return r;
      final next = r.copyWith(
        lemma: lemma,
        translation: translation,
        status: BulkRowSubmitStatus.idle,
        clearError: true,
      );
      return next;
    }).toList(growable: false);
    state = state.copyWith(rows: rows, clearBatchFinished: true);
  }

  /// Kirim berurutan semua baris lengkap yang belum `sent`.
  Future<void> submitPending({
    required String languageId,
    required String translationLanguageId,
    required String wordClassId,
    String? dialectId,
  }) async {
    if (state.isSubmitting) return;

    if (languageId.isEmpty ||
        translationLanguageId.isEmpty ||
        wordClassId.isEmpty) {
      state = state.copyWith(
        errorMessage:
            'Data referensi belum siap. Tunggu sebentar lalu coba lagi.',
      );
      return;
    }

    final pendingIds = state.rows
        .where((r) => r.shouldSubmit)
        .map((r) => r.id)
        .toList(growable: false);

    if (pendingIds.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Isi minimal satu baris kata dan terjemahan.',
      );
      return;
    }

    state = state.copyWith(
      isSubmitting: true,
      progressDone: 0,
      progressTotal: pendingIds.length,
      clearErrorMessage: true,
      clearBatchFinished: true,
    );

    final guest = !(await AuthTokenStorage.instance.getIsAuth());
    final usecase = ref.read(submitAnonWordUseCaseProvider);

    var done = 0;
    for (final id in pendingIds) {
      final row = state.rows.where((r) => r.id == id).firstOrNull;
      if (row == null || !row.shouldSubmit) continue;

      state = state.copyWith(
        rows: _mapRow(
          id,
          (r) => r.copyWith(
            status: BulkRowSubmitStatus.sending,
            clearError: true,
          ),
        ),
        progressDone: done,
      );

      await AnalyticsService.instance.logContributeSubmit(guest: guest);

      final result = await usecase(
        SubmitAnonWordParams(
          lemma: row.lemma.trim(),
          languageId: languageId,
          dialectId: dialectId,
          wordType: 'word',
          translationLanguageId: translationLanguageId,
          meanings: [
            SubmitAnonWordMeaningParams(
              wordClassId: wordClassId,
              definition: '-',
              isHaveDefinition: false,
              isHaveTranslation: true,
              meaningSource: 'manual',
              translationTexts: [row.translation.trim()],
            ),
          ],
        ),
      );

      done += 1;

      final failedStop = result.fold<bool>(
        (failure) {
          AnalyticsService.instance.logContributeFail(
            guest: guest,
            errorCode: failure.errorCode,
          );
          final message = _rowErrorMessage(failure);
          state = state.copyWith(
            rows: _mapRow(
              id,
              (r) => r.copyWith(
                status: BulkRowSubmitStatus.failed,
                errorMessage: message,
              ),
            ),
            progressDone: done,
          );
          // Hentikan sisa antrean jika rate-limit supaya tidak memukul API.
          return failure.isRateLimited;
        },
        (success) {
          AnalyticsService.instance.logContributeSuccess(
            guest: guest,
            wordId: success.wordId,
          );
          state = state.copyWith(
            rows: _mapRow(
              id,
              (r) => r.copyWith(
                status: BulkRowSubmitStatus.sent,
                wordId: success.wordId,
                clearError: true,
              ),
            ),
            progressDone: done,
          );
          return false;
        },
      );

      if (failedStop) break;
    }

    state = state.copyWith(
      isSubmitting: false,
      batchFinished: true,
      progressDone: done,
    );
  }

  List<BulkContributeRow> _mapRow(
    String id,
    BulkContributeRow Function(BulkContributeRow) map,
  ) {
    return state.rows
        .map((r) => r.id == id ? map(r) : r)
        .toList(growable: false);
  }

  String _rowErrorMessage(ContributionFailure failure) {
    if (failure.isValidationError) {
      return failure.errorFor('lemma') ??
          failure.errorForMeaning(0, 'translation_texts') ??
          failure.errorForMeaning(0, 'definition') ??
          failure.errorFor('word_class_id') ??
          failure.message;
    }
    return failure.message;
  }
}
