import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/dictionary/dictionary_router.dart';
import '../../features/encyclopedia/encyclopedia_router.dart';
import '../../features/event/event_router.dart';
import '../../features/explore/explore_router.dart';
import '../../features/karya/karya_router.dart';
import '../../features/layanan/layanan_router.dart';
import '../../features/usaha/usaha_router.dart';
import '../../l10n/app_localizations.dart';
import '../models/content_related_link.dart';

/// Buka detail entitas dari kartu `content_links`.
void openContentRelatedLink(BuildContext context, ContentRelatedLink row) {
  final slug = row.slug;
  switch (row.kind) {
    case 'word':
      context.push(DictionaryRouter.detail.path.replaceFirst(':id', row.id));
      return;
    case 'article':
      if (slug != null && slug.isNotEmpty) {
        context.push(EncyclopediaRouter.detailPath(slug));
      }
      return;
    case 'place':
      if (slug != null && slug.isNotEmpty) {
        context.push(ExploreRouter.place.path.replaceFirst(':slug', slug));
      }
      return;
    case 'event':
      if (slug != null && slug.isNotEmpty) {
        context.push(EventRouter.detailPath(slug));
      }
      return;
    case 'usaha':
      if (slug != null && slug.isNotEmpty) {
        context.push(UsahaRouter.detailPath(slug));
      }
      return;
    case 'karya':
      if (slug != null && slug.isNotEmpty) {
        context.push(KaryaRouter.detailPath(slug));
      }
      return;
    case 'kreator':
      if (slug != null && slug.isNotEmpty) {
        context.push(KaryaRouter.kreatorPath(slug));
      }
      return;
    case 'cuisine':
      if (slug != null && slug.isNotEmpty) {
        context.push(
          ExploreRouter.cuisineDetail.path.replaceFirst(':slug', slug),
        );
      }
      return;
    case 'layanan':
      if (slug != null && slug.isNotEmpty) {
        context.push(LayananRouter.detailPath(slug));
      }
      return;
    default:
      return;
  }
}

String contentRelatedKindLabel(AppLocalizations l10n, String kind) =>
    switch (kind) {
      'place' => l10n.karyaRelatedKindPlace,
      'word' => l10n.karyaRelatedKindWord,
      'article' => l10n.karyaRelatedKindArticle,
      'event' => l10n.karyaRelatedKindEvent,
      'usaha' => l10n.karyaRelatedKindUsaha,
      'kreator' => l10n.karyaRelatedKindKreator,
      'karya' => l10n.karyaRelatedKindKarya,
      'cuisine' => l10n.contentRelatedKindCuisine,
      'layanan' => l10n.contentRelatedKindLayanan,
      _ => kind,
    };
