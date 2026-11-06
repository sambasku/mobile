import 'package:go_router/go_router.dart';

import '../../core/router/route_definer.dart';
import 'presentation/pages/encyclopedia_article_list_page.dart';
import 'presentation/pages/encyclopedia_article_detail_page.dart';
import 'presentation/pages/encyclopedia_contribution_page.dart';
import 'presentation/pages/encyclopedia_markdown_editor_page.dart';
import 'presentation/pages/encyclopedia_my_contributions_page.dart';

class EncyclopediaRouter {
  EncyclopediaRouter._();

  /// Halaman daftar artikel (publik).
  static const list = RouteDefiner(
    path: '/encyclopedia',
    name: 'EncyclopediaRouter.list',
  );

  /// Detail artikel (publik).
  static const detail = RouteDefiner(
    path: '/encyclopedia/:slug',
    name: 'EncyclopediaRouter.detail',
  );

  /// Form usulan artikel baru / perbaikan (login).
  static const contribute = RouteDefiner(
    path: '/encyclopedia/usulan',
    name: 'EncyclopediaRouter.contribute',
  );

  /// Editor Markdown full-screen untuk field isi usulan.
  static const editor = RouteDefiner(
    path: '/encyclopedia/usulan/editor',
    name: 'EncyclopediaRouter.editor',
  );

  /// Riwayat usulan user (login).
  static const myContributions = RouteDefiner(
    path: '/encyclopedia/usulan/saya',
    name: 'EncyclopediaRouter.myContributions',
  );

  static String detailPath(String slug) => detail.path.replaceFirst(':slug', slug);

  /// Literal (`usulan/saya`, `usulan/editor`, `usulan`) WAJIB sebelum `/:slug`.
  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['category'];
        return EncyclopediaArticleListPage(initialCategoryId: categoryId);
      },
    ),
    GoRoute(
      path: myContributions.path,
      name: myContributions.name,
      builder: (context, state) => const EncyclopediaMyContributionsPage(),
    ),
    GoRoute(
      path: editor.path,
      name: editor.name,
      builder: (context, state) {
        final initial = state.extra is String ? state.extra as String : '';
        return EncyclopediaMarkdownEditorPage(initialMarkdown: initial);
      },
    ),
    GoRoute(
      path: contribute.path,
      name: contribute.name,
      builder: (context, state) {
        final articleSlug = state.uri.queryParameters['article_slug'];
        return EncyclopediaContributionPage(articleSlug: articleSlug);
      },
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return EncyclopediaArticleDetailPage(slug: slug);
      },
    ),
  ];
}