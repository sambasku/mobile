import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/report_bug_page.dart';

class ReportBugRouter {
  ReportBugRouter._();

  static const reportBug = RouteDefiner(
    path: '/report-bug',
    name: 'ReportBugRouter.reportBug',
  );

  static const feedback = RouteDefiner(
    path: '/feedback',
    name: 'ReportBugRouter.feedback',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: reportBug.path,
      name: reportBug.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const ReportBugPage(),
    ),
    GoRoute(
      path: feedback.path,
      name: feedback.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) =>
          const ReportBugPage(mode: ReportBugMode.feedback),
    ),
  ];
}
