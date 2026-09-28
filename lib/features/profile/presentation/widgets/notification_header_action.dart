import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/header_action_icon.dart';
import '../../../notification/notification_router.dart';
import '../../../notification/presentation/providers/notification_providers.dart';

class NotificationHeaderAction extends ConsumerWidget {
  const NotificationHeaderAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread =
        ref.watch(unreadNotificationCountControllerProvider).value ?? 0;
    return FHeaderAction(
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(unread > 99 ? '99+' : '$unread'),
        child: const Icon(FLucideIcons.bell, size: kHeaderActionIconSize),
      ),
      onPress: () => context.push(NotificationRouter.list.path),
    );
  }
}
