import 'package:flutter/foundation.dart';

import 'event.dart';

/// Error usulan acara - pesan siap tampil ke user.
class EventContributionException implements Exception {
  const EventContributionException(this.message, {this.code});

  final String message;
  final String? code;
}

/// Status usulan acara.
enum EventContributionStatus { pending, needsRevision, approved, rejected }

/// Parse status dari wire API (snake_case).
EventContributionStatus? eventContributionStatusFromWire(String? raw) =>
    switch (raw) {
      'pending' => EventContributionStatus.pending,
      'needs_revision' => EventContributionStatus.needsRevision,
      'approved' => EventContributionStatus.approved,
      'rejected' => EventContributionStatus.rejected,
      _ => null,
    };

/// Usulan acara milik user (bisa anonim).
@immutable
class EventContribution {
  const EventContribution({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    this.eventId,
    this.categoryId,
    this.startsAt,
    this.endsAt,
    this.locationText,
    this.revisionNote,
    this.rejectReason,
  });

  final String id;
  final String name;
  final EventContributionStatus status;

  /// Event resmi hasil approval. Null = usulan murni.
  final String? eventId;

  final String? categoryId;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? locationText;

  /// Catatan revisi dari admin (status `needs_revision`).
  final String? revisionNote;

  /// Alasan penolakan siap tampil (label + catatan).
  final String? rejectReason;

  final DateTime createdAt;

  bool get isPending => status == EventContributionStatus.pending;

  bool get needsRevision => status == EventContributionStatus.needsRevision;

  bool get canCancel =>
      status == EventContributionStatus.pending ||
      status == EventContributionStatus.needsRevision;
}

/// Draft usulan yang siap dikirim.
class EventContributionDraft {
  const EventContributionDraft({
    required this.name,
    required this.description,
    required this.categoryId,
    required this.startsAt,
    required this.endsAt,
    required this.locationText,
    this.lat,
    this.lng,
    this.organizer,
    this.sourceUrl,
    this.sourceType,
    this.sourceAttribution,
    this.regionId,
    this.villageId,
    this.placeIds = const [],
    this.posterUrls = const [],
  });

  final String name;
  final String description;
  final String categoryId;
  final DateTime startsAt;
  final DateTime endsAt;
  final String locationText;
  final double? lat;
  final double? lng;
  final String? organizer;

  /// Link original konten. Disimpan BERSIH tanpa UTM.
  final String? sourceUrl;
  final EventSourceType? sourceType;
  final String? sourceAttribution;

  final String? regionId;
  final String? villageId;
  final List<String> placeIds;

  /// URL poster hasil unggah (mobile wajib upload file, tidak input URL).
  /// Urutan = urutan unggah; [0] dipakai sebagai sampul.
  final List<String> posterUrls;

  /// Body wire untuk `POST /api/v1/event-contributions`.
  Map<String, dynamic> toBody() => {
    'name': name,
    'description': description,
    'category_id': categoryId,
    'starts_at': startsAt.toUtc().toIso8601String(),
    'ends_at': endsAt.toUtc().toIso8601String(),
    'location_text': locationText,
    if (lat != null && lng != null) 'lat': lat,
    if (lat != null && lng != null) 'lng': lng,
    if (organizer != null && organizer!.isNotEmpty) 'organizer': organizer,
    if (sourceUrl != null && sourceUrl!.isNotEmpty) 'source_url': sourceUrl,
    if (sourceType != null) 'source_type': sourceType!.name,
    if (sourceAttribution != null && sourceAttribution!.isNotEmpty)
      'source_attribution': sourceAttribution,
    if (regionId != null) 'region_id': regionId,
    if (villageId != null) 'village_id': villageId,
    if (placeIds.isNotEmpty) 'place_ids': placeIds,
    if (posterUrls.isNotEmpty) 'poster_urls': posterUrls,
  };
}
