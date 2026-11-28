import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/features/auth/presentation/models/auth_status_state.dart';
import 'package:sambasku_mobile/features/auth/presentation/providers/auth_status_providers.dart';
import 'package:sambasku_mobile/shared/stickers/sticker_models.dart';
import 'package:sambasku_mobile/shared/stickers/sticker_providers.dart';
import 'package:sambasku_mobile/shared/stickers/sticker_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeStickerRepository extends StickerRepository {
  _FakeStickerRepository() : super(Dio());

  final List<CatalogSticker> serverFavs = [];
  final List<CatalogSticker> serverMine = [];
  StickerApiException? failAddWith;
  int addCalls = 0;
  int removeCalls = 0;

  @override
  Future<List<CatalogSticker>> fetchFavorites(String userId) async {
    return List.of(serverFavs);
  }

  @override
  Future<CatalogSticker> addFavorite(String stickerId) async {
    addCalls++;
    if (failAddWith != null) throw failAddWith!;
    final s = CatalogSticker(
      id: stickerId,
      imageUrl: 'https://cdn.example/$stickerId.webp',
    );
    serverFavs.removeWhere((e) => e.id == stickerId);
    serverFavs.insert(0, s);
    return s;
  }

  @override
  Future<void> removeFavorite(String stickerId) async {
    removeCalls++;
    serverFavs.removeWhere((e) => e.id == stickerId);
  }

  @override
  Future<List<CatalogSticker>> fetchMine(String userId) async {
    return List.of(serverMine);
  }

  @override
  Future<void> deleteMine(String stickerId) async {
    serverMine.removeWhere((e) => e.id == stickerId);
    serverFavs.removeWhere((e) => e.id == stickerId);
  }
}

class _ForkStickerRepository extends _FakeStickerRepository {
  @override
  Future<CatalogSticker> addFavorite(String stickerId) async {
    addCalls++;
    final copy = CatalogSticker(
      id: 'copy-$stickerId',
      imageUrl: 'https://cdn.example/$stickerId.webp',
      isCustom: true,
      sourceStickerId: stickerId,
    );
    serverFavs.insert(0, copy);
    return copy;
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('CatalogSticker parses display_name and is_custom', () {
    final s = CatalogSticker.fromJson({
      'id': 'kopi-01jabcdefghjkmnpqrstvwxyz1',
      'image_url': 'https://ik.imagekit.io/demo/kopi.webp',
      'play_once': false,
      'category_slug': null,
      'display_name': 'Kopi Pagi',
      'is_custom': true,
    });
    expect(s.isCustom, isTrue);
    expect(s.label, 'Kopi Pagi');
  });

  test('StickerFavoritesController toggles optimistic and rolls back on limit error', () async {
    final repo = _FakeStickerRepository();
    final container = ProviderContainer(
      overrides: [
        stickerRepositoryProvider.overrideWithValue(repo),
        authStatusProvider.overrideWith(
          () => _StaticAuthStatus(
            const AuthStatusState(isAuth: true, userId: 'user-1'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authStatusProvider.future);
    await container.read(stickerFavoritesProvider.notifier).load(force: true);
    const cheer = CatalogSticker(
      id: 'cheer',
      imageUrl: 'https://cdn.example/cheer.webp',
    );

    final addRes =
        await container.read(stickerFavoritesProvider.notifier).toggle(cheer);
    expect(addRes.ok, isTrue);
    expect(addRes.isFavorite, isTrue);
    expect(container.read(stickerFavoritesProvider).contains('cheer'), isTrue);

    final remRes =
        await container.read(stickerFavoritesProvider.notifier).toggle(cheer);
    expect(remRes.ok, isTrue);
    expect(remRes.isFavorite, isFalse);
    expect(container.read(stickerFavoritesProvider).contains('cheer'), isFalse);

    repo.failAddWith = const StickerApiException(
      errorCode: 'STICKER_FAVORITE_LIMIT_REACHED',
    );
    final limitRes =
        await container.read(stickerFavoritesProvider.notifier).toggle(cheer);
    expect(limitRes.ok, isFalse);
    expect(limitRes.errorCode, 'STICKER_FAVORITE_LIMIT_REACHED');
    expect(container.read(stickerFavoritesProvider).contains('cheer'), isFalse);
  });

  test('favorit stiker orang lain disimpan sebagai salinan dan dikenali lewat asal', () async {
    final repo = _ForkStickerRepository();
    final container = ProviderContainer(
      overrides: [
        stickerRepositoryProvider.overrideWithValue(repo),
        authStatusProvider.overrideWith(
          () => _StaticAuthStatus(
            const AuthStatusState(isAuth: true, userId: 'user-1'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(authStatusProvider.future);
    await container.read(stickerFavoritesProvider.notifier).load(force: true);
    const foreign = CatalogSticker(
      id: 'kopi-01jabcdefghjkmnpqrstvwxyz1',
      imageUrl: 'https://cdn.example/kopi.webp',
      isCustom: true,
    );
    final notifier = container.read(stickerFavoritesProvider.notifier);

    final addRes = await notifier.toggle(foreign);
    expect(addRes.isFavorite, isTrue);
    final afterAdd = container.read(stickerFavoritesProvider);
    expect(afterAdd.items.map((s) => s.id), ['copy-${foreign.id}']);
    expect(afterAdd.contains(foreign.id), isTrue);

    final remRes = await notifier.toggle(foreign);
    expect(remRes.isFavorite, isFalse);
    expect(repo.serverFavs, isEmpty);
    expect(container.read(stickerFavoritesProvider).contains(foreign.id), isFalse);
  });

  test('CatalogSticker membaca source_sticker_id dari salinan fork', () {
    final s = CatalogSticker.fromJson({
      'id': 'copy-1',
      'image_url': 'https://ik.imagekit.io/demo/kopi.webp',
      'play_once': false,
      'category_slug': null,
      'display_name': null,
      'is_custom': true,
      'source_sticker_id': 'kopi-01jabcdefghjkmnpqrstvwxyz1',
    });
    expect(s.sourceStickerId, 'kopi-01jabcdefghjkmnpqrstvwxyz1');
    expect(s.toJson()['source_sticker_id'], 'kopi-01jabcdefghjkmnpqrstvwxyz1');
  });

  test('Guest cannot toggle favorite and gets UNAUTHORIZED', () async {
    final repo = _FakeStickerRepository();
    final container = ProviderContainer(
      overrides: [
        stickerRepositoryProvider.overrideWithValue(repo),
        authStatusProvider.overrideWith(
          () => _StaticAuthStatus(const AuthStatusState(isAuth: false)),
        ),
      ],
    );
    addTearDown(container.dispose);

    const cheer = CatalogSticker(
      id: 'cheer',
      imageUrl: 'https://cdn.example/cheer.webp',
    );
    final res =
        await container.read(stickerFavoritesProvider.notifier).toggle(cheer);
    expect(res.ok, isFalse);
    expect(res.errorCode, 'UNAUTHORIZED');
    expect(repo.addCalls, 0);
  });
}

class _StaticAuthStatus extends AuthStatusNotifier {
  _StaticAuthStatus(this._status);
  final AuthStatusState _status;

  @override
  Future<AuthStatusState> build() async => _status;
}
