import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/contribution/contribution_router.dart';
import 'package:sambasku_mobile/features/contribution/presentation/utils/open_verifier_contribute.dart';

void main() {
  testWidgets(
    'pushVerifierContribute membuka /contribute tanpa query lemma (#342)',
    (tester) async {
      Uri? capturedUri;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Directionality(
              textDirection: TextDirection.ltr,
              child: GestureDetector(
                onTap: () => pushVerifierContribute(
                  context,
                  analyticsFrom: 'review_session_deck',
                  contributeFrom: 'review_session',
                ),
                child: const Text('Buka Usul'),
              ),
            ),
          ),
          GoRoute(
            path: ContributionRouter.contribute.path,
            builder: (_, state) {
              capturedUri = state.uri;
              return const Directionality(
                textDirection: TextDirection.ltr,
                child: Text('Form Usul'),
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(WidgetsApp.router(
        color: const Color(0xFFFFFFFF),
        routerConfig: router,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buka Usul'));
      await tester.pumpAndSettle();

      expect(find.text('Form Usul'), findsOneWidget);
      expect(capturedUri, isNotNull);
      expect(capturedUri!.path, ContributionRouter.contribute.path);
      expect(capturedUri!.queryParameters, {'from': 'review_session'});
      expect(capturedUri!.queryParameters.containsKey('lemma'), isFalse);
    },
  );
}
