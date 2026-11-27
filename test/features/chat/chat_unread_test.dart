import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/features/chat/data/chat_providers.dart';
import 'package:sambasku_mobile/features/chat/data/chat_read_cursor_store.dart';
import 'package:sambasku_mobile/features/chat/data/chat_repository.dart';
import 'package:sambasku_mobile/features/chat/domain/chat_models.dart';
import 'package:sambasku_mobile/features/chat/domain/chat_unread.dart';
import 'package:sambasku_mobile/features/chat/presentation/providers/chat_unread_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

ChatMessage msg(
  String id, {
  required Duration ago,
  String userId = 'other',
  String? body = 'halo',
  String? replyUsername,
  ChatMessageKind kind = ChatMessageKind.text,
  String? deletedAt,
}) => ChatMessage(
  id: id,
  channel: 'public',
  userId: userId,
  kind: kind,
  body: body,
  replyUsername: replyUsername,
  deletedAt: deletedAt,
  createdAt: DateTime.now().toUtc().subtract(ago).toIso8601String(),
);

class FakeChatRepo extends ChatRepository {
  FakeChatRepo(this.items) : super(Dio());

  List<ChatMessage> items;
  bool fail = false;

  @override
  Future<Either<ChatFailure, ChatMessagePage>> listMessages({
    int limit = 50,
    String? beforeCreatedAt,
    String? beforeId,
    String? afterCreatedAt,
    String? afterId,
  }) async {
    if (fail) return Either.left(const ChatFailure('x'));
    final after = afterCreatedAt == null
        ? null
        : DateTime.parse(afterCreatedAt).toUtc();
    final out = items.where((m) {
      if (after == null) return true;
      return DateTime.parse(m.createdAt).toUtc().isAfter(after);
    }).toList();
    return Either.right(ChatMessagePage(items: out, hasMore: false));
  }
}

class FakeAuth extends AuthStatusNotifier {
  FakeAuth(this.userId, this.username);

  final String? userId;
  final String? username;

  @override
  Future<AuthStatusState> build() async => AuthStatusState(
    isAuth: userId != null,
    userId: userId,
    username: username,
  );
}

ProviderContainer makeContainer(
  FakeChatRepo repo, {
  String? userId = 'me',
  String? username = 'budi',
}) {
  final c = ProviderContainer(
    overrides: [
      chatRepositoryProvider.overrideWithValue(repo),
      chatRealtimeProvider.overrideWithValue(null),
      authStatusProvider.overrideWith(() => FakeAuth(userId, username)),
    ],
  );
  addTearDown(c.dispose);
  c.listen(authStatusProvider, (_, _) {});
  c.listen(chatUnreadProvider, (_, _) {});
  return c;
}

Future<ChatUnreadState> settle(ProviderContainer c) async {
  await c.read(authStatusProvider.future);
  await pumpEventQueue();
  await pumpEventQueue();
  return c.read(chatUnreadProvider);
}

void main() {
  group('logika murni', () {
    test('mention utuh, bukan awalan username lain atau email', () {
      expect(chatBodyMentions('halo @budi', 'budi'), isTrue);
      expect(chatBodyMentions('@budi, apa kabar', 'budi'), isTrue);
      expect(chatBodyMentions('halo @budi.', 'budi'), isTrue);
      expect(chatBodyMentions('halo @BUDI!', 'budi'), isTrue);
      expect(chatBodyMentions('halo @budisantoso', 'budi'), isFalse);
      expect(chatBodyMentions('halo @budi.santoso', 'budi'), isFalse);
      expect(chatBodyMentions('x@budi', 'budi'), isFalse);
      expect(chatBodyMentions('halo budi', 'budi'), isFalse);
    });

    test('personal: reply ke saya atau mention; tamu tidak pernah', () {
      expect(
        isPersonalChatMessage(
          msg('1', ago: Duration.zero, replyUsername: 'Budi'),
          'budi',
        ),
        isTrue,
      );
      expect(
        isPersonalChatMessage(
          msg('2', ago: Duration.zero, body: 'hai @budi'),
          'budi',
        ),
        isTrue,
      );
      expect(
        isPersonalChatMessage(msg('3', ago: Duration.zero), 'budi'),
        isFalse,
      );
      expect(
        isPersonalChatMessage(
          msg('4', ago: Duration.zero, body: '@budi'),
          null,
        ),
        isFalse,
      );
    });

    test(
      'eligible: buang milik sendiri, terhapus, pending, system selain ping',
      () {
        bool ok(ChatMessage m) => isChatUnreadEligible(m, myUserId: 'me');
        expect(ok(msg('1', ago: Duration.zero)), isTrue);
        expect(ok(msg('2', ago: Duration.zero, userId: 'me')), isFalse);
        expect(
          ok(msg('3', ago: Duration.zero, deletedAt: '2026-01-01T00:00:00Z')),
          isFalse,
        );
        expect(
          ok(
            msg(
              '4',
              ago: Duration.zero,
              kind: ChatMessageKind.system,
              body: 'join',
            ),
          ),
          isFalse,
        );
        expect(
          ok(
            msg(
              '5',
              ago: Duration.zero,
              kind: ChatMessageKind.system,
              body: kChatPingBody,
            ),
          ),
          isTrue,
        );
      },
    );

    test('cursor korup di prefs = null (tidak crash)', () async {
      SharedPreferences.setMockInitialValues({
        ChatReadCursorStore.keyFor('me'): '{bukan json',
        ChatReadCursorStore.keyFor('u2'): '{"t":"bukan-tanggal","i":"x"}',
      });
      final store = ChatReadCursorStore(await SharedPreferences.getInstance());
      expect(store.read('me'), isNull);
      expect(store.read('u2'), isNull);
      expect(store.read(null), isNull);
    });
  });

  group('ChatUnreadController', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test(
      'run pertama: hitung 24 jam, buang milik sendiri, pisah personal',
      () async {
        final repo = FakeChatRepo([
          msg('old', ago: const Duration(hours: 30)),
          msg('a', ago: const Duration(hours: 2)),
          msg('mine', ago: const Duration(hours: 1), userId: 'me'),
          msg('rep', ago: const Duration(minutes: 30), replyUsername: 'budi'),
          msg('men', ago: const Duration(minutes: 20), body: 'cek @budi'),
        ]);
        final s = await settle(makeContainer(repo));
        expect(s.total, 3);
        expect(s.personal, 2);
      },
    );

    test('tap = hilang; pesan baru = muncul lagi', () async {
      final repo = FakeChatRepo([msg('a', ago: const Duration(hours: 1))]);
      final c = makeContainer(repo);
      expect((await settle(c)).total, 1);

      await c.read(chatUnreadProvider.notifier).markAsRead();
      expect(c.read(chatUnreadProvider).hasUnread, isFalse);

      repo.items = [...repo.items, msg('b', ago: const Duration(seconds: 1))];
      await c.read(chatUnreadProvider.notifier).refresh(force: true);
      expect(c.read(chatUnreadProvider).total, 1);
    });

    test('state beda tiap akun (key per userId)', () async {
      final repo = FakeChatRepo([msg('a', ago: const Duration(hours: 1))]);

      final a = makeContainer(repo, userId: 'u-a', username: 'ani');
      expect((await settle(a)).total, 1);
      await a.read(chatUnreadProvider.notifier).markAsRead();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(ChatReadCursorStore.keyFor('u-a')), isNotNull);
      expect(prefs.getString(ChatReadCursorStore.keyFor('u-b')), isNull);

      final b = makeContainer(repo, userId: 'u-b', username: 'bobi');
      expect((await settle(b)).total, 1);

      final a2 = makeContainer(repo, userId: 'u-a', username: 'ani');
      expect((await settle(a2)).hasUnread, isFalse);
    });

    test('gagal fetch: state terakhir dipertahankan', () async {
      final repo = FakeChatRepo([msg('a', ago: const Duration(hours: 1))]);
      final c = makeContainer(repo);
      expect((await settle(c)).total, 1);

      repo.fail = true;
      await c.read(chatUnreadProvider.notifier).refresh(force: true);
      expect(c.read(chatUnreadProvider).total, 1);
    });

    test('chat terbuka: tidak menghitung, cursor maju', () async {
      final repo = FakeChatRepo([msg('a', ago: const Duration(hours: 1))]);
      final c = makeContainer(repo);
      expect((await settle(c)).total, 1);

      final n = c.read(chatUnreadProvider.notifier);
      n.chatViewOpened();
      await pumpEventQueue();
      expect(c.read(chatUnreadProvider).hasUnread, isFalse);

      repo.items = [...repo.items, msg('b', ago: const Duration(seconds: 1))];
      await n.refresh(force: true);
      expect(c.read(chatUnreadProvider).hasUnread, isFalse);

      n.chatViewClosed();
      await n.refresh(force: true);
      expect(c.read(chatUnreadProvider).hasUnread, isFalse);
    });
  });
}
