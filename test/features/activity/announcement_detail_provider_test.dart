import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/core/network/network_providers.dart';
import 'package:sambasku_mobile/features/activity/presentation/providers/announcement_detail_provider.dart';

/// Adapter yang mengembalikan respons statis per test (tanpa network).
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.status, this.body);

  final int status;
  final Object? body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final payload = body == null ? '{}' : body.toString();
    return ResponseBody.fromString(
      payload,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

Dio _dio(int status, Object? body) =>
    Dio()..httpClientAdapter = _StubAdapter(status, body);

void main() {
  test('200 → FeedAnnouncement terparse dari endpoint publik', () async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(
            200,
            '{"success":true,"data":{"id":"01ANNCDEEPLINK0000000001",'
            '"title":"Deep link","body":"Tanpa login.",'
            '"action_url":"https://sambasku.com/blog",'
            '"action_label":"Baca","expires_at":null,"expired":false,'
            '"created_by":"01U","created_at":1799946600,"updated_at":null}}',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final detail = await container.read(
      announcementDetailProvider('01ANNCDEEPLINK0000000001').future,
    );
    expect(detail, isNotNull);
    expect(detail!.title, 'Deep link');
    expect(detail.actionLabel, 'Baca');
    expect(detail.expired, isFalse);
  });

  test('expired=true tetap terparse (konsisten feed)', () async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(
            200,
            '{"success":true,"data":{"id":"01ANNCDEEPLINK0000000002",'
            '"title":"Maintenance","body":"Besok.",'
            '"action_url":null,"action_label":null,"expires_at":1,'
            '"expired":true,"created_by":"01U","created_at":1,"updated_at":null}}',
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final detail = await container.read(
      announcementDetailProvider('01ANNCDEEPLINK0000000002').future,
    );
    expect(detail!.expired, isTrue);
    expect(detail.actionUrl, isNull);
  });

  test('404 → null (UI fallback "tidak tersedia")', () async {
    final container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(
          _dio(404, '{"error_code":"ANNOUNCEMENT_NOT_FOUND"}'),
        ),
      ],
    );
    addTearDown(container.dispose);

    final detail = await container.read(
      announcementDetailProvider('01JUNK').future,
    );
    expect(detail, isNull);
  });
}
