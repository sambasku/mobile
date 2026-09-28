import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/discussion_review_detail_page.dart';
import 'presentation/pages/discussion_review_queue_page.dart';
import 'presentation/pages/review_history_detail_page.dart';
import 'presentation/pages/review_history_page.dart';
import 'presentation/pages/review_home_page.dart';
import 'presentation/pages/review_queue_page.dart';
import 'presentation/pages/review_session_page.dart';
import 'presentation/pages/review_suggestion_detail_page.dart';
import 'presentation/pages/review_suggestions_page.dart';
import 'presentation/widgets/review_gate.dart';

class ReviewRouter {
  ReviewRouter._();

  /// Hub: Mulai tinjau | Usulan edit | Tinjauan Diskusi | Riwayat tinjauan.
  static const list = RouteDefiner(path: '/review', name: 'ReviewRouter.list');
  static const queue = RouteDefiner(
    path: '/review/queue',
    name: 'ReviewRouter.queue',
  );
  static const discussions = RouteDefiner(
    path: '/review/discussions',
    name: 'ReviewRouter.discussions',
  );
  static const discussionDetail = RouteDefiner(
    path: '/review/discussions/:id',
    name: 'ReviewRouter.discussionDetail',
  );
  static const suggestions = RouteDefiner(
    path: '/review/suggestions',
    name: 'ReviewRouter.suggestions',
  );
  static const suggestionDetail = RouteDefiner(
    path: '/review/suggestions/:id',
    name: 'ReviewRouter.suggestionDetail',
  );
  static const history = RouteDefiner(
    path: '/review/history',
    name: 'ReviewRouter.history',
  );
  static const historyDetail = RouteDefiner(
    path: '/review/history/:id',
    name: 'ReviewRouter.historyDetail',
  );
  static const session = RouteDefiner(
    path: '/review/session',
    name: 'ReviewRouter.session',
  );
  static const detail = RouteDefiner(
    path: '/review/:id',
    name: 'ReviewRouter.detail',
  );
  static const correct = RouteDefiner(
    path: '/review/:id/correct',
    name: 'ReviewRouter.correct',
  );

  static String detailPath(String id) => sessionPath(startId: id);

  static String historyDetailPath(String id) => '/review/history/$id';

  static String suggestionDetailPath(String id) => '/review/suggestions/$id';

  static String discussionDetailPath(String id) => '/review/discussions/$id';

  static String queuePath({String? wordId}) {
    if (wordId == null || wordId.isEmpty) return queue.path;
    return '${queue.path}?wordId=${Uri.encodeQueryComponent(wordId)}';
  }

  static String sessionPath({
    String? startId,
    String? wordId,
    bool openCorrect = false,
  }) {
    final params = <String, String>{};
    if (startId != null && startId.isNotEmpty) {
      params['startId'] = startId;
    }
    if (wordId != null && wordId.isNotEmpty) {
      params['wordId'] = wordId;
    }
    if (openCorrect) {
      params['mode'] = 'correct';
    }
    if (params.isEmpty) return session.path;
    final query = params.entries
        .map(
          (entry) =>
              '${Uri.encodeQueryComponent(entry.key)}=${Uri.encodeQueryComponent(entry.value)}',
        )
        .join('&');
    return '${session.path}?$query';
  }

  static final List<GoRoute> routes = [
    GoRoute(
      path: list.path,
      name: list.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      redirect: (context, state) {
        final wordId = state.uri.queryParameters['wordId'];
        if (wordId != null && wordId.isNotEmpty) {
          return queuePath(wordId: wordId);
        }
        return null;
      },
      builder: (context, state) => const ReviewGate(
        child: ReviewHomePage(),
      ),
    ),
    GoRoute(
      path: queue.path,
      name: queue.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => ReviewGate(
        mode: ReviewGateMode.contribution,
        child: ReviewQueuePage(wordId: state.uri.queryParameters['wordId']),
      ),
    ),
    GoRoute(
      path: discussions.path,
      name: discussions.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const ReviewGate(
        mode: ReviewGateMode.discussion,
        child: DiscussionReviewQueuePage(),
      ),
    ),
    GoRoute(
      path: discussionDetail.path,
      name: discussionDetail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ReviewGate(
          mode: ReviewGateMode.discussion,
          child: DiscussionReviewDetailPage(id: id),
        );
      },
    ),
    GoRoute(
      path: suggestions.path,
      name: suggestions.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const ReviewGate(
        mode: ReviewGateMode.contribution,
        child: ReviewSuggestionsPage(),
      ),
    ),
    GoRoute(
      path: suggestionDetail.path,
      name: suggestionDetail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ReviewGate(
          mode: ReviewGateMode.contribution,
          child: ReviewSuggestionDetailPage(id: id),
        );
      },
    ),
    GoRoute(
      path: history.path,
      name: history.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) => const ReviewGate(
        mode: ReviewGateMode.contribution,
        child: ReviewHistoryPage(),
      ),
    ),
    GoRoute(
      path: historyDetail.path,
      name: historyDetail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ReviewGate(
          mode: ReviewGateMode.contribution,
          child: ReviewHistoryDetailPage(id: id),
        );
      },
    ),
    // Harus sebelum /review/:id supaya "session" / "queue" tidak tertangkap sebagai id.
    GoRoute(
      path: session.path,
      name: session.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return ReviewGate(
          mode: ReviewGateMode.contribution,
          child: ReviewSessionPage(
            startId: params['startId'],
            wordId: params['wordId'],
            openCorrect: params['mode'] == 'correct',
          ),
        );
      },
    ),
    GoRoute(
      path: detail.path,
      name: detail.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      redirect: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        if (id.isEmpty ||
            id == 'session' ||
            id == 'history' ||
            id == 'queue' ||
            id == 'suggestions' ||
            id == 'discussions') {
          return list.path;
        }
        return sessionPath(
          startId: id,
          wordId: state.uri.queryParameters['wordId'],
        );
      },
    ),
    GoRoute(
      path: correct.path,
      name: correct.name,
      parentNavigatorKey: AppRouter.rootNavigatorKey,
      redirect: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        if (id.isEmpty) return list.path;
        return sessionPath(
          startId: id,
          wordId: state.uri.queryParameters['wordId'],
          openCorrect: true,
        );
      },
    ),
  ];
}
