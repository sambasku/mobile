import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sambasku_mobile/features/explore/data/culinary_contribution_api.dart';
import 'package:sambasku_mobile/features/explore/explore_router.dart';

void main() {
  test('mine() memetakan payload usulan -> CulinaryProposal', () async {
    final dio = Dio()
      ..httpClientAdapter = _FakeAdapter({
        'success': true,
        'data': {
          'items': [
            {
              'id': '01HXAMPLE000000000000000A',
              'kind': 'cuisine_edit',
              'status': 'rejected',
              'cuisine_name': 'Bubur Pedas',
              'place_name': null,
              'payload': {'name': 'Bubur Pedas'},
              'revision_note': null,
              'reject_reason_code': 'stale',
              'reject_reason_text': 'data dasar sudah berubah',
              'created_at': '2026-10-20T10:00:00.000Z',
            },
            {
              'id': '01HXAMPLE000000000000000B',
              'kind': 'new_place',
              'status': 'pending',
              'cuisine_name': null,
              'place_name': null,
              'payload': {'name': 'Warung Kopi Sari'},
              'created_at': '2026-10-21T10:00:00.000Z',
            },
          ],
        },
      });

    final items = await CulinaryContributionApi(dio).mine();

    expect(items, hasLength(2));
    expect(items.first.title, 'Bubur Pedas');
    expect(items.first.canCancel, isFalse);
    expect(items.first.rejectReasonText, 'data dasar sudah berubah');
    // Nama target jatuh ke payload.name saat entitas belum terbit.
    expect(items.last.title, 'Warung Kopi Sari');
    expect(items.last.canCancel, isTrue);
  });

  test('/explore/cuisine/usulan = usulan, bukan detail slug "usulan"', () {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SizedBox()),
        ...ExploreRouter.routes,
      ],
    );
    addTearDown(router.dispose);

    final match = router.configuration
        .findMatch(Uri.parse(ExploreRouter.cuisineProposals.path))
        .last;
    expect(match.route.name, ExploreRouter.cuisineProposals.name);
  });
}

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.body);

  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
