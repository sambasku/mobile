// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationInboxListController)
final notificationInboxListControllerProvider =
    NotificationInboxListControllerProvider._();

final class NotificationInboxListControllerProvider
    extends
        $AsyncNotifierProvider<
          NotificationInboxListController,
          NotificationInboxState
        > {
  NotificationInboxListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationInboxListControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationInboxListControllerHash();

  @$internal
  @override
  NotificationInboxListController create() => NotificationInboxListController();
}

String _$notificationInboxListControllerHash() =>
    r'b9fcab5647732d740a3e9c54078a4c41337d8c65';

abstract class _$NotificationInboxListController
    extends $AsyncNotifier<NotificationInboxState> {
  FutureOr<NotificationInboxState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<NotificationInboxState>, NotificationInboxState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationInboxState>,
                NotificationInboxState
              >,
              AsyncValue<NotificationInboxState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(UnreadNotificationCountController)
final unreadNotificationCountControllerProvider =
    UnreadNotificationCountControllerProvider._();

final class UnreadNotificationCountControllerProvider
    extends $AsyncNotifierProvider<UnreadNotificationCountController, int> {
  UnreadNotificationCountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadNotificationCountControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$unreadNotificationCountControllerHash();

  @$internal
  @override
  UnreadNotificationCountController create() =>
      UnreadNotificationCountController();
}

String _$unreadNotificationCountControllerHash() =>
    r'860922302ba6611289890e8a8e9e4054e48a6e7e';

abstract class _$UnreadNotificationCountController extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
