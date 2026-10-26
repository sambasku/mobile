import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/event/data/models/event_dto.dart';
import 'package:sambasku_mobile/features/event/domain/entities/event.dart';
import 'package:sambasku_mobile/features/event/presentation/widgets/event_ui.dart';

void main() {
  group('EventDto', () {
    test('parse wire snake_case ke domain camelCase', () {
      final event = EventDto.fromJson(const {
        'id': '01EV0000000000000000000001',
        'slug': 'pawai-blocks-2026',
        'name': 'Pawai Blocks Keywords 2026',
        'description': 'Pawai tahunan.',
        'category_id': 'budaya-tradisi',
        'category': {'id': 'budaya-tradisi', 'name': 'Budaya dan Tradisi'},
        'starts_at': '2026-11-17T13:00:00.000Z',
        'ends_at': '2026-11-17T16:00:00.000Z',
        'occurrence_status': 'upcoming',
        'location_text': 'Lapangan utama Pemangkat',
        'lat': 1.35,
        'lng': 109.2,
        'maps_url': null,
        'poster_urls': <String>[],
        'organizer': 'Panitia Pawai',
        'source_url': 'https://facebook.com/pawai.blocks',
        'source_type': 'facebook',
        'source_attribution': '@panitia_pawai',
        'region_id': '01KEC00000000000000000001',
        'village_id': '01DES00000000000000000001',
        'village': {
          'id': '01DES00000000000000000001',
          'name': 'Perapakan',
          'slug': 'pemangkat/perapakan',
        },
        'places': [
          {
            'id': '01PLC00000000000000000001',
            'slug': 'museum-negeri-sambas',
            'name': 'Museum Negeri Sambas',
            'category': 'wisata',
          },
        ],
        'status': 'published',
        'cancelled_at': null,
        'published_at': '2026-10-01T00:00:00.000Z',
        'created_at': '2026-10-01T00:00:00.000Z',
        'updated_at': null,
      });

      expect(event, isNotNull);
      expect(event!.slug, 'pawai-blocks-2026');
      expect(event.category?.name, 'Budaya dan Tradisi');
      expect(event.village?.name, 'Perapakan');
      expect(event.village?.slug, 'pemangkat/perapakan');
      expect(event.places, hasLength(1));
      expect(event.places.first.slug, 'museum-negeri-sambas');
      expect(event.sourceType, EventSourceType.facebook);
      expect(event.sourceAttribution, '@panitia_pawai');
      expect(event.occurrenceStatus, EventOccurrenceStatus.upcoming);
      expect(event.status, EventStatus.published);
    });

    test('field wajib absen -> item di-skip (null), bukan crash', () {
      expect(EventDto.fromJson(const {'id': 'x'}), isNull);
      expect(
        EventDto.fromJson(const {
          'id': '01EV0000000000000000000001',
          'slug': 's',
          'name': 'n',
          'category_id': 'c',
          'starts_at': 'bukan tanggal',
          'ends_at': '2026-11-17T16:00:00.000Z',
        }),
        isNull,
      );
    });

    test('source_type tak dikenal -> null (badge dilewati)', () {
      final event = EventDto.fromJson(const {
        'id': '01EV0000000000000000000001',
        'slug': 's',
        'name': 'n',
        'category_id': 'c',
        'starts_at': '2026-11-17T13:00:00.000Z',
        'ends_at': '2026-11-17T16:00:00.000Z',
        'source_type': 'tiktok-live',
      });
      expect(event?.sourceType, isNull);
    });
  });

  group('effectiveOccurrenceStatus', () {
    Event makeEvent({
      required DateTime startsAt,
      required DateTime endsAt,
      DateTime? cancelledAt,
    }) => Event(
      id: '01EV0000000000000000000001',
      slug: 's',
      name: 'n',
      description: 'd',
      categoryId: 'c',
      startsAt: startsAt,
      endsAt: endsAt,
      occurrenceStatus: EventOccurrenceStatus.upcoming,
      locationText: 'l',
      status: EventStatus.published,
      cancelledAt: cancelledAt,
    );

    test('belum mulai -> upcoming', () {
      final now = DateTime.now();
      final event = makeEvent(
        startsAt: now.add(const Duration(hours: 2)),
        endsAt: now.add(const Duration(hours: 3)),
      );
      expect(event.effectiveOccurrenceStatus, EventOccurrenceStatus.upcoming);
    });

    test('sedang berjalan -> ongoing', () {
      final now = DateTime.now();
      final event = makeEvent(
        startsAt: now.subtract(const Duration(hours: 1)),
        endsAt: now.add(const Duration(hours: 1)),
      );
      expect(event.effectiveOccurrenceStatus, EventOccurrenceStatus.ongoing);
    });

    test('sudah lewat -> completed', () {
      final now = DateTime.now();
      final event = makeEvent(
        startsAt: now.subtract(const Duration(hours: 3)),
        endsAt: now.subtract(const Duration(hours: 1)),
      );
      expect(event.effectiveOccurrenceStatus, EventOccurrenceStatus.completed);
    });

    test('dibatalkan -> cancelled (bukan upcoming walau masih di masa depan)', () {
      final now = DateTime.now();
      final event = makeEvent(
        startsAt: now.add(const Duration(hours: 2)),
        endsAt: now.add(const Duration(hours: 3)),
        cancelledAt: now,
      );
      expect(event.effectiveOccurrenceStatus, EventOccurrenceStatus.cancelled);
    });
  });

  group('eventMetaLine', () {
    test('gabung kategori + desa + jadwal pakai pemisah', () {
      final event = Event(
        id: '01EV0000000000000000000001',
        slug: 's',
        name: 'n',
        description: 'd',
        categoryId: 'c',
        category: const EventCategoryRef(id: 'c', name: 'Budaya dan Tradisi'),
        startsAt: DateTime(2026, 11, 17, 21),
        endsAt: DateTime(2026, 11, 17, 23),
        occurrenceStatus: EventOccurrenceStatus.upcoming,
        locationText: 'l',
        status: EventStatus.published,
        village: const EventVillageRef(id: 'v', name: 'Perapakan'),
      );
      final line = eventMetaLine(event);
      expect(line, contains('Budaya dan Tradisi'));
      expect(line, contains('Perapakan'));
      expect(line, contains(' - '));
    });

    test('kategori/desa kosong -> label tidak dikosongkan', () {
      final event = Event(
        id: '01EV0000000000000000000001',
        slug: 's',
        name: 'n',
        description: 'd',
        categoryId: 'c',
        startsAt: DateTime(2026, 11, 17, 21),
        endsAt: DateTime(2026, 11, 17, 23),
        occurrenceStatus: EventOccurrenceStatus.upcoming,
        locationText: 'l',
        status: EventStatus.published,
      );
      expect(eventMetaLine(event), isNot(contains('·')));
    });
  });

  group('formatEventSchedule', () {
    test('tanggal sama -> jam saja di bagian kedua', () {
      final event = Event(
        id: '01EV0000000000000000000001',
        slug: 's',
        name: 'n',
        description: 'd',
        categoryId: 'c',
        startsAt: DateTime(2026, 11, 17, 21),
        endsAt: DateTime(2026, 11, 17, 23),
        occurrenceStatus: EventOccurrenceStatus.upcoming,
        locationText: 'l',
        status: EventStatus.published,
      );
      final text = formatEventSchedule(event);
      expect(text.contains(' - '), isTrue);
      // Bagian kedua tidak mengulang tanggal.
      expect(text.split(' - ').last.contains('17'), isFalse);
    });

    test('tanggal beda -> tanggal penuh di kedua bagian', () {
      final event = Event(
        id: '01EV0000000000000000000001',
        slug: 's',
        name: 'n',
        description: 'd',
        categoryId: 'c',
        startsAt: DateTime(2026, 11, 17, 21),
        endsAt: DateTime(2026, 11, 18, 23),
        occurrenceStatus: EventOccurrenceStatus.upcoming,
        locationText: 'l',
        status: EventStatus.published,
      );
      final text = formatEventSchedule(event);
      expect(text.split(' - ').last.contains('18'), isTrue);
      expect(text.split(' - ').last.contains('Nov'), isTrue);
    });
  });

  group('eventSourceTypeLabel', () {
    test('null -> null (UI skip badge, tanpa label kosong)', () {
      expect(eventSourceTypeLabel(null), isNull);
    });

    test('platform dikenal -> label Bahasa Indonesia', () {
      expect(eventSourceTypeLabel(EventSourceType.facebook), 'Facebook');
      expect(eventSourceTypeLabel(EventSourceType.instagram), 'Instagram');
      expect(eventSourceTypeLabel(EventSourceType.website), 'Website');
    });
  });
}
