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

/// Repo palsu: mencatat flag excludeSelf + kategori per halaman.
class _FakeActivityRepository implements ActivityFeedRepository {
  final calls = <({String? cursor, bool excludeSelf, FeedCategory category})>[];

  @override
  Future<ActivityFeedPage> list({
    int limit = 20,
    String? cursor,
    bool forceRefresh = false,
    bool excludeSelf = false,
    FeedCategory category = FeedCategory.all,
  }) async {
    calls.add((cursor: cursor, excludeSelf: excludeSelf, category: category));
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

/// #167: identitas resolve setelah jeda async (simulasi cold-start: prefs +
/// storage belum terbaca saat notifier feed build).
class _DelayedAuthStatus extends AuthStatusNotifier {
  _DelayedAuthStatus(this.authState);

  final AuthStatusState authState;

  @override
  Future<AuthStatusState> build() async {
    for (var i = 0; i < 4; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    return authState;
  }
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
      container.read(activityFeedProvider(FeedCategory.all)); // instantiate notifier dulu
      await _flush();

      expect(container.read(activityFeedProvider(FeedCategory.all)).items.length, 1);
      await container.read(activityFeedProvider(FeedCategory.all).notifier).loadMore();

      expect(repo.calls.map((c) => c.excludeSelf), [false, false]);
      expect(repo.calls.last.cursor, 'page-2');
    });

    test('login: flag ikut di load DAN loadMore', () async {
      final container =
          makeContainer(const AuthStatusState(isAuth: true, userId: 'u1'));
      container.read(activityFeedProvider(FeedCategory.all));
      await _flush();

      await container.read(activityFeedProvider(FeedCategory.all).notifier).loadMore();

      expect(repo.calls.map((c) => c.excludeSelf), [true, true]);
      expect(repo.calls.last.cursor, 'page-2');
    });

    test('#167: fetch pertama menunggu authStatus resolve (tidak ada panggilan prematur)',
        () async {
      // Identitas baru resolve setelah jeda - sebelum fix, load() langsung
      // menembak repo dengan excludeSelf:false (data sendiri flash).
      final container = ProviderContainer(
        overrides: [
          activityFeedRepositoryProvider.overrideWithValue(repo),
          authStatusProvider.overrideWith(
            () => _DelayedAuthStatus(
              const AuthStatusState(isAuth: true, userId: 'u1'),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(activityFeedProvider(FeedCategory.all));
      // Double flush: jeda authStatus (4 tick) + chain await di load().
      await _flush();
      await _flush();

      // Semua panggilan ke repo terjadi SETELAH identitas diketahui.
      expect(repo.calls, isNotEmpty);
      expect(repo.calls.first.excludeSelf, isTrue);
    });
  });

  // #193: chips kategori feed beranda. Inti yang dijaga: kategori yang belum
  // di-tap TIDAK memanggil repo (hemat query Turso), dan tiap kategori punya
  // query sendiri yang independen.
  group('kategori chips (#193)', () {
    late _FakeActivityRepository repo;

    setUp(() => repo = _FakeActivityRepository());

    ProviderContainer makeContainer() {
      final container = ProviderContainer(
        overrides: [
          activityFeedRepositoryProvider.overrideWithValue(repo),
          authStatusProvider.overrideWith(
            () => _FakeAuthStatus(const AuthStatusState()),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('hanya kategori all yang auto-load; kategori lain nol request',
        () async {
      final container = makeContainer();
      container.read(activityFeedProvider(FeedCategory.all));
      await _flush();

      // Belum pernah menyentuh chip lain: hanya 1 panggilan (kategori all).
      expect(repo.calls, hasLength(1));
      expect(repo.calls.single.category, FeedCategory.all);

      // Instansiasi kategori lain TIDAK auto-load (state masih kosong).
      final joined = container.read(activityFeedProvider(FeedCategory.joined));
      await _flush();
      expect(joined.hasLoaded, isFalse);
      expect(repo.calls, hasLength(1));
    });

    test('ensureLoaded: fetch sekali, tap kedua nol request', () async {
      final container = makeContainer();
      final notifier =
          container.read(activityFeedProvider(FeedCategory.joined).notifier);

      notifier.ensureLoaded();
      await _flush();
      expect(repo.calls, hasLength(1));
      expect(repo.calls.single.category, FeedCategory.joined);

      // Tap ulang chip yang sama: hasLoaded true -> tidak fetch lagi.
      notifier.ensureLoaded();
      await _flush();
      expect(repo.calls, hasLength(1));
    });

    test('tiap kategori mengirim wire value sendiri', () async {
      final container = makeContainer();
      for (final category in FeedCategory.values) {
        container.read(activityFeedProvider(category).notifier).ensureLoaded();
        await _flush();
      }

      expect(
        repo.calls.map((c) => c.category).toSet(),
        FeedCategory.values.toSet(),
      );
    });

    test('loadMore ikut membawa kategori yang sama', () async {
      final container = makeContainer();
      // Kategori non-all LAZY: harus ensureLoaded dulu (bukan auto-load).
      container
          .read(activityFeedProvider(FeedCategory.correction).notifier)
          .ensureLoaded();
      await _flush();
      await container
          .read(activityFeedProvider(FeedCategory.correction).notifier)
          .loadMore();

      expect(repo.calls.map((c) => c.category), everyElement(FeedCategory.correction));
      expect(repo.calls.last.cursor, 'page-2');
    });
  });

  // Wire value enum = kontrak dengan API (#193). Salah ketik di sini membuat
  // server membalas 400 karena zod enum menolak nilai asing.
  group('FeedCategory wire values', () {
    test('sesuai kontrak API', () {
      expect(FeedCategory.all.wire, 'all');
      expect(FeedCategory.searchMiss.wire, 'search_miss');
      expect(FeedCategory.correction.wire, 'correction');
      expect(FeedCategory.announcement.wire, 'announcement');
      expect(FeedCategory.joined.wire, 'joined');
    });
  });
}