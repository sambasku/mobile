import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../explore/explore_router.dart';

void encyclopediaPopOrGoExplore(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(ExploreRouter.hub.path);
  }
}
