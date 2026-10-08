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
        final bodyTypeRaw = data['body_type']?.toString();
        final bodyType = parseAnnouncementBodyType(bodyTypeRaw);
        return FeedAnnouncement(
          id: data['id'] is String ? data['id'] as String : id,
          title: title,
          body: bodyText,
          bodyType: bodyType,
          actionUrl: data['action_url'] is String
              ? data['action_url'] as String
              : null,
          actionLabel: data['action_label'] is String
              ? data['action_label'] as String
              : null,
          expired: data['expired'] == true,
          pinnedAt: data['pinned_at'] != null
              ? DateTime.tryParse(data['pinned_at'].toString())
              : null,
        );
      } on DioException catch (e) {
        // 404 / offline: null → UI menampilkan fallback "tidak tersedia".
        if (e.response?.statusCode == 404) return null;
        rethrow;
      }
    });

/// Pinned announcements list (mobile carousel / halaman pinned).
/// GET /api/v1/announcements/pinned - publik, tidak butuh auth.
final pinnedAnnouncementsProvider = FutureProvider.autoDispose
    .family<List<FeedAnnouncement>, void>((ref, _) async {
      final dio = ref.watch(dioProvider);
      try {
        final res = await dio.get<dynamic>('/api/v1/announcements/pinned');
        final body = res.data;
        if (body is! Map) {
          throw StateError('Envelope pinned announcements tidak valid');
        }
        final data = body['data'];
        if (data is! List) return <FeedAnnouncement>[];
        return data
            .map((item) {
              final map = item as Map<String, dynamic>;
              final id = map['id']?.toString() ?? '';
              final title = map['title']?.toString() ?? '';
              final bodyText = map['body']?.toString() ?? '';
              if (id.isEmpty || title.isEmpty || bodyText.isEmpty) return null;
              final bodyTypeRaw = map['body_type']?.toString();
              final bodyType = parseAnnouncementBodyType(bodyTypeRaw);
              return FeedAnnouncement(
                id: id,
                title: title,
                body: bodyText,
                bodyType: bodyType,
                actionUrl: _nonEmptyUrl(map['action_url']),
                actionLabel: _nonEmptyUrl(map['action_label']),
                expired: map['expired'] == true,
                pinnedAt: map['pinned_at'] != null
                    ? DateTime.tryParse(map['pinned_at'].toString())
                    : null,
              );
            })
            .whereType<FeedAnnouncement>()
            .toList();
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) return <FeedAnnouncement>[];
        rethrow;
      }
    });

/// Helper extract non-empty URL from map value.
String? _nonEmptyUrl(Object? raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty || s == 'null') return null;
  return s;
}
