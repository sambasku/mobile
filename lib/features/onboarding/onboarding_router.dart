import 'package:flutter/material.dart' show BuildContext;
import 'package:go_router/go_router.dart';
import '../../core/router/route_definer.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/onboarding_language_page.dart';

class OnboardingRouter {
  OnboardingRouter._();

  static const onboarding = RouteDefiner(
    path: '/onboarding',
    name: 'OnboardingRouter.onboarding',
  );
  static const language = RouteDefiner(
    path: '/onboarding/language',
    name: 'OnboardingRouter.language',
  );

  static final List<GoRoute> routes = [
    GoRoute(
      path: onboarding.path,
      name: onboarding.name,
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: language.path,
      name: language.name,
      builder: (context, state) =>
          const OnboardingLanguagePage(onDone: OnboardingRouter.goOnboarding),
    ),
  ];

  static void goOnboarding(BuildContext context) =>
      context.go(onboarding.path);
}
