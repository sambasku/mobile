import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/analytics_service.dart';
import '../../contribution_router.dart';

/// Verifikator membuka form usul kata dari pintasan deck (kontribusi / tinjau).
void pushVerifierContribute(
  BuildContext context, {
  required String analyticsFrom,
  required String contributeFrom,
  String? initialLemma,
}) {
  AnalyticsService.instance.log(
    AnalyticsEvents.contributeStart,
    params: {'from': analyticsFrom},
  );
  final params = <String, String>{'from': contributeFrom};
  final lemma = initialLemma?.trim();
  if (lemma != null && lemma.isNotEmpty) {
    params['lemma'] = lemma;
  }
  context.push(
    Uri(
      path: ContributionRouter.contribute.path,
      queryParameters: params,
    ).toString(),
  );
}