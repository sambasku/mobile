import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/auth_token_storage.dart';
import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/submit_word_result.dart';
import '../../domain/failures/contribution_failure.dart';
import '../../domain/providers/contribution_domain_providers.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../../domain/usecases/submit_anon_word_use_case.dart';
import '../models/submit_word_state.dart';

part 'submit_word_providers.g.dart';

@riverpod
class SubmitWordNotifier extends _$SubmitWordNotifier {
  @override
  SubmitWordState build() {
    ref.onDispose(() {});
    return const SubmitWordState();
  }

  void initPrefill({String? lemma, String? searchIn, String? searchMissId}) {
    state = state.copyWith(
      initialLemma: lemma,
      initialSearchIn: searchIn,
      initialSearchMissId: searchMissId,
    );
  }

  void clearFieldErrors() {
    if (state.failure is! ContributionFailure) return;
    state = state.copyWith(clearFailure: true, clearErrorMessage: true);
  }

  void clearError() {
    state = state.copyWith(clearFailure: true, clearErrorMessage: true);
  }

  /// Setelah sukses + "Tambah lagi": bersihkan result/search-miss supaya
  /// form kosong siap usulan berikutnya tanpa navigate.
  void resetForAnother() {
    state = const SubmitWordState();
  }

  Future<void> submit({
    required String lemma,
    required String languageId,
    required List<SubmitAnonWordMeaningParams> meanings,
    String? dialectId,
    String wordType = 'word',
    List<String> categoryIds = const [],
    List<String> usageLabels = const [],
    String? notes,
    List<String> spellingVariants = const [],
    List<SubmitWordRelation> relatedWords = const [],
    required String translationLanguageId,
    List<SubmitWordImage> images = const [],
    String? searchMissId,
  }) async {
    if (state.isSubmitting) return;

    state = state.copyWith(
      isSubmitting: true,
      clearFailure: true,
      clearErrorMessage: true,
      clearResult: true,
    );

    final guest = !(await AuthTokenStorage.instance.getIsAuth());
    await AnalyticsService.instance.logContributeSubmit(guest: guest);

    final usecase = ref.read(submitAnonWordUseCaseProvider);
    final result = await usecase(SubmitAnonWordParams(
      lemma: lemma,
      languageId: languageId,
      meanings: meanings,
      dialectId: dialectId,
      wordType: wordType,
      categoryIds: categoryIds,
      usageLabels: usageLabels,
      notes: notes,
      spellingVariants: spellingVariants,
      relatedWords: relatedWords,
      translationLanguageId: translationLanguageId,
      images: images,
      searchMissId: searchMissId ?? state.initialSearchMissId,
    ));

    result.match(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          failure: failure,
          errorMessage: failure.isValidationError ? null : failure.message,
        );
        AnalyticsService.instance.logContributeFail(
          guest: guest,
          errorCode: failure.errorCode,
        );
      },
      (success) {
        state = state.copyWith(
          isSubmitting: false,
          result: success,
          clearFailure: true,
          clearErrorMessage: true,
        );
        AnalyticsService.instance.logContributeSuccess(
          guest: guest,
          wordId: success.wordId,
        );
      },
    );
  }

  String? errorFor(String field) {
    final f = state.failure;
    if (f is! ContributionFailure) return null;
    return f.errorFor(field);
  }

  String? errorForMeaning(int index, String field) {
    final f = state.failure;
    if (f is! ContributionFailure) return null;
    return f.errorForMeaning(index, field);
  }

  SubmitWordResult? get successResult {
    final r = state.result;
    return r is SubmitWordResult ? r : null;
  }
}
