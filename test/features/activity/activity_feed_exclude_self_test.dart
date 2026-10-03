import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/activity/data/activity_feed_repository.dart';
import 'package:sambasku_mobile/features/activity/domain/entities/feed_activity_item.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/activity_feed_providers.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';

FeedActivityItem _item(String id) => FeedActivityItem(
      id: id,
      kind: FeedActivityKind.comment,
      createdAt: '2026-01-01T00:00:00Z',
      body: 'komentar',
    );

/// Adapter yang mencatat query tiap request lalu mengembalikan feed kosong
/// dengan cursor, supaya bisa diuji tanpa network.
class _RecordingAdapter implements HttpClientAdapter {
  final queries = <Map<String, dynamic>>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    queries.add(Map<String, dynamic>.from(options.queryParameters));
    return ResponseBody.fromString(
      '{"success":true,"data":[],"meta":{"limit":20,"next_cursor":null,"has_more":false}}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// Repo palsu: mencatat flag excludeSelf per halaman.
class _FakeActivityRepository implements ActivityFeedRepository {
  final calls = <({String? cursor, bool excludeSelf})>[];

  @override
  Future<ActivityFeedPage> list({
    int limit = 20,
    String? cursor,
    bool forceRefresh = false,
    bool excludeSelf = false,
  }) async {
    calls.add((cursor: cursor, excludeSelf: excludeSelf));
    if (cursor == 'page-2') {
      return ActivityFeedPage(items: [_item('b2')], nextCursor: null, hasMore: false);
    }
    return ActivityFeedPage(
      items: [_item('a1')],
      nextCursor: 'page-2',
      hasMore: true,
    );
  }
}

class _FakeAuthStatus extends AuthStatusNotifier {
  _FakeAuthStatus(this.authState);

  final AuthStatusState authState;

  @override
  Future<AuthStatusState> build() async => authState;
}

Future<void> _flush() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  group('repository: exclude_self', () {
    late Dio dio;
    late _RecordingAdapter adapter;

    setUp(() {
      adapter = _RecordingAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
        ..httpClientAdapter = adapter;
    });

    test('default tidak mengirim exclude_self (back-compat tamu)', () async {
      await ActivityFeedRepository(dio).list();

      expect(adapter.queries.single.containsKey('exclude_self'), isFalse);
    });

    test('excludeSelf: true mengirim flag sebagai string "1"', () async {
      await ActivityFeedRepository(dio).list(excludeSelf: true);

      expect(adapter.queries.single['exclude_self'], '1');
    });

    test('flag ikut pada halaman berikutnya (loadMore tidak bocorkan karya)',
        () async {
      final repo = ActivityFeedRepository(dio);
      await repo.list(excludeSelf: true, cursor: 'page-2');

      expect(adapter.queries.single['exclude_self'], '1');
      expect(adapter.queries.single['cursor'], 'page-2');
    });

    test('limit tetap terkirim dan tidak tertimpa flag', () async {
      await ActivityFeedRepository(dio).list(limit: 50, excludeSelf: true);

      expect(adapter.queries.single['limit'], 50);
      expect(adapter.queries.single['exclude_self'], '1');
    });
  });

  group('excludeSelfFeedProvider: keputusan filter', () {
    Future<bool> resolve(AuthStatusState auth) async {
      final container = ProviderContainer(
        overrides: [authStatusProvider.overrideWith(() => _FakeAuthStatus(auth))],
      );
      addTearDown(container.dispose);
      await container.read(authStatusProvider.future);
      return container.read(excludeSelfFeedProvider);
    }

    test('tamu → false', () async {
      expect(await resolve(const AuthStatusState()), isFalse);
      expect(
        await resolve(const AuthStatusState(isAuth: false, userId: 'u1')),
        isFalse,
      );
    });

    test('login + userId → true', () async {
      expect(
        await resolve(const AuthStatusState(isAuth: true, userId: 'u1')),
        isTrue,
      );
    });

    test('login tanpa userId → false (tampilkan semua, jangan feed kosong)',
        () async {
      expect(
        await resolve(const AuthStatusState(isAuth: true, username: 'saya')),
        isFalse,
      );
      expect(
        await resolve(const AuthStatusState(isAuth: true, userId: '   ')),
        isFalse,
      );
    });
  });

  group('notifier: propagate flag + reload saat identitas berubah', () {
    late _FakeActivityRepository repo;

    setUp(() => repo = _FakeActivityRepository());

    ProviderContainer makeContainer(AuthStatusState auth) {
      final container = ProviderContainer(
        overrides: [
          activityFeedRepositoryProvider.overrideWithValue(repo),
          authStatusProvider.overrideWith(() => _FakeAuthStatus(auth)),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('tamu: load halaman 1 tanpa flag, loadMore juga tanpa flag',
        () async {
      final container = makeContainer(const AuthStatusState());
      container.read(activityFeedProvider); // instantiate notifier dulu
      await _flush();

      expect(container.read(activityFeedProvider).items.length, 1);
      await container.read(activityFeedProvider.notifier).loadMore();

      expect(repo.calls.map((c) => c.excludeSelf), [false, false]);
      expect(repo.calls.last.cursor, 'page-2');
    });

    test('login: flag ikut di load DAN loadMore', () async {
      final container =
          makeContainer(const AuthStatusState(isAuth: true, userId: 'u1'));
      container.read(activityFeedProvider);
      await _flush();

      await container.read(activityFeedProvider.notifier).loadMore();

      expect(repo.calls.map((c) => c.excludeSelf), [true, true]);
      expect(repo.calls.last.cursor, 'page-2');
    });
  });
}