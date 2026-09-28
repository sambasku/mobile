import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/verifier_application.dart';
import '../../domain/providers/verifier_application_domain_providers.dart';
import '../../domain/usecases/submit_verifier_application_use_case.dart';
import '../models/verifier_application_state.dart';

part 'verifier_application_providers.g.dart';

@riverpod
class VerifierApplicationNotifier extends _$VerifierApplicationNotifier {
  @override
  VerifierApplicationState build() {
    Future.microtask(load);
    return const VerifierApplicationState();
  }

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    final result = await ref.read(getMyVerifierApplicationUseCaseProvider)();
    result.match(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (application) => state = state.copyWith(
        isLoading: false,
        application: application,
        clearApplication: application == null,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> submit({
    required String phone,
    required String address,
    required List<SocialLink> socialLinks,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    final isResubmit = state.application?.isRejected == true;
    final result = await ref.read(submitVerifierApplicationUseCaseProvider)(
      SubmitVerifierApplicationParams(
        phone: phone,
        address: address,
        socialLinks: socialLinks,
        isResubmit: isResubmit,
      ),
    );
    result.match(
      (failure) => state = state.copyWith(
        isSubmitting: false,
        errorMessage: failure.message,
      ),
      (application) {
        state = state.copyWith(
          isSubmitting: false,
          application: application,
          successMessage: isResubmit
              ? 'Pengajuan dikirim ulang. Menunggu review.'
              : 'Pengajuan terkirim. Menunggu review.',
        );
        AnalyticsService.instance.log(AnalyticsEvents.verifierApplySubmit);
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }
}
