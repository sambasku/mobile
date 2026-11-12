import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../dictionary/data/meaning_moderation_repository.dart';
import 'word_report_repository.dart';

final wordReportRepositoryProvider = Provider<WordReportRepository>(
  (ref) => WordReportRepository(ref.watch(dioProvider)),
);

final meaningModerationRepositoryProvider =
    Provider<MeaningModerationRepository>(
  (ref) => MeaningModerationRepository(ref.watch(dioProvider)),
);
