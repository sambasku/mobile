import '../../features/jinye/domain/jinye_models.dart';

List<JinyeLemmaLink> parseLemmaLinksWire(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => JinyeLemmaLink.fromJson(Map<String, dynamic>.from(e)))
      .toList(growable: false);
}