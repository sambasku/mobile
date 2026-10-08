import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../domain/entities/feed_activity_item.dart';

/// Detail pengumuman by id (#102 deep link): dipakai saat `state.extra`
/// tidak ada (deep link / restore state). Feed tetap sumber utama (payload
/// beku); fetch ini hanya fallback.
final announcementDetailProvider = FutureProvider.autoDispose
    .family<FeedAnnouncement?, String>((ref, id) async {
      final dio = ref.watch(dioProvider);
      try {
        final res = await dio.get<dynamic>('/api/v1/announcements/$id');
        final body = res.data;
        if (body is! Map) throw StateError('Envelope pengumuman tidak valid');
        final data = body['data'];
        if (data is! Map) return null;
        final title = data['title'];
        final bodyText = data['body'];
        if (title is! String || title.trim().isEmpty || bodyText is! String) {
          return null;
        }
        return FeedAnnouncement(
          id: data['id'] is String ? data['id'] as String : id,
          title: title,
          body: bodyText,
          actionUrl: data['action_url'] is String
              ? data['action_url'] as String
              : null,
          actionLabel: data['action_label'] is String
              ? data['action_label'] as String
              : null,
          expired: data['expired'] == true,
        );
      } on DioException catch (e) {
        // 404 / offline: null → UI menampilkan fallback "tidak tersedia".
        if (e.response?.statusCode == 404) return null;
        rethrow;
      }
    });
