import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/pronunciation_audio_upload_service.dart';
import '../../data/written_pronunciation_service.dart';

part 'pronunciation_providers.g.dart';

@riverpod
PronunciationAudioUploadService pronunciationAudioUploadService(Ref ref) {
  return PronunciationAudioUploadService(ref.watch(dioProvider));
}

final writtenPronunciationServiceProvider =
    Provider<WrittenPronunciationService>((ref) {
      return WrittenPronunciationService(ref.watch(dioProvider));
    });

/// Set true setelah 503 - sembunyikan tombol rekam di halaman ini.
@riverpod
class PronunciationUploadUnavailable extends _$PronunciationUploadUnavailable {
  @override
  bool build(String wordId) => false;

  void markUnavailable() {
    state = true;
  }
}

/// Toast 503 sekali per sesi halaman.
@riverpod
class PronunciationUploadToastShown extends _$PronunciationUploadToastShown {
  @override
  bool build(String wordId) => false;

  bool markShown() {
    if (state) return false;
    state = true;
    return true;
  }
}

class DialectOption {
  const DialectOption({
    required this.id,
    required this.name,
    this.isDefault = false,
  });

  final String id;
  final String name;
  final bool isDefault;
}

@riverpod
Future<List<DialectOption>> wordDialects(Ref ref, String languageId) async {
  final dio = ref.watch(dioProvider);
  final resp = await dio.get<dynamic>(
    '/api/v1/dialects',
    queryParameters: <String, dynamic>{'language_id': languageId},
  );
  final data = resp.data;
  if (data is! Map<String, dynamic>) return [];
  final arr = data['data'];
  if (arr is! List) return [];
  return arr
      .whereType<Map<String, dynamic>>()
      .map(
        (e) => DialectOption(
          id: e['id']?.toString() ?? '',
          name: e['name']?.toString() ?? '(?)',
          isDefault: e['is_default'] == true,
        ),
      )
      .where((e) => e.id.isNotEmpty)
      .toList(growable: false);
}
