import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/analytics_service.dart';
import '../../contribution_router.dart';

/// Verifikator membuka form usul kata baru (fresh/kosong) dari pintasan deck
/// (kontribusi / tinjau / periksa kata).
void pushVerifierContribute(
  BuildContext context, {
  required String analyticsFrom,
  required String contributeFrom,
}) {
  AnalyticsService.instance.log(
    AnalyticsEvents.contributeStart,
    params: {'from': analyticsFrom},
  );
  context.push(
    Uri(
      path: ContributionRouter.contribute.path,
      queryParameters: {'from': contributeFrom},
    ).toString(),
  );
}