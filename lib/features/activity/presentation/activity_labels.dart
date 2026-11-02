import '../../../l10n/app_localizations.dart';
import '../data/activity_feed_repository.dart';

/// Label chip kategori feed beranda. Domain hanya menyimpan nilai wire.
String feedCategoryLabel(AppLocalizations l10n, FeedCategory category) =>
    switch (category) {
      FeedCategory.all => l10n.feedCategoryAll,
      FeedCategory.searchMiss => l10n.feedCategorySearchMiss,
      FeedCategory.correction => l10n.feedCategoryCorrection,
      FeedCategory.explore => l10n.feedCategoryExplore,
      FeedCategory.announcement => l10n.feedCategoryAnnouncement,
      FeedCategory.joined => l10n.feedCategoryJoined,
    };
