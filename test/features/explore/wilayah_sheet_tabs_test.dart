import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sambasku_mobile/core/theme/forui_palettes.dart';
import 'package:sambasku_mobile/features/event/domain/entities/event.dart';
import 'package:sambasku_mobile/features/event/presentation/providers/event_browse_providers.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/place.dart';
import 'package:sambasku_mobile/features/explore/domain/entities/region.dart';
import 'package:sambasku_mobile/features/explore/presentation/pages/wilayah_page.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/places_providers.dart';
import 'package:sambasku_mobile/features/explore/presentation/providers/regions_providers.dart';
import 'package:sambasku_mobile/features/usaha/domain/entities/usaha.dart';
import 'package:sambasku_mobile/features/usaha/presentation/providers/usaha_browse_providers.dart';

const _kec = Region(
  id: 'pemangkat',
  name: 'Pemangkat',
  type: RegionType.kecamatan,
  lat: 1.1,
  lng: 109.1,
);

final _desa = List.generate(
  3,
  (i) => Region(
    id: 'pemangkat/desa-$i',
    name: 'Desa $i',
    type: RegionType.desa,
    parentId: 'pemangkat',
    code: '610201000$i',
  ),
);

Place _place(String name, PlaceCategory category) => Place(
  id: name,
  slug: name.toLowerCase().replaceAll(' ', '-'),
  name: name,
  category: category,
  type: null,
  shortDescription: 'Deskripsi $name',
  regionId: 'pemangkat',
  images: const [],
  hours: null,
  contact: null,
  related: const [],
  sources: const [],
);

final _places = [
  _place('Pantai Temajuk', PlaceCategory.wisata),
  _place('Bubur Pedas', PlaceCategory.kuliner),
];

const _usaha = Usaha(
  id: 'u1',
  slug: 'warung-mak-jam',
  name: 'Warung Mak Jam',
  kind: UsahaKind.product,
  publishStatus: UsahaPublishStatus.published,
  operationalStatus: UsahaOperationalStatus.open,
);

final _event = Event(
  id: 'e1',
  slug: 'pawai-taiping',
  name: 'Pawai Taiping',
  description: 'Acara tahunan.',
  categoryId: 'festival-hiburan',
  startsAt: DateTime(2030, 1, 1),
  endsAt: DateTime(2030, 1, 2),
  occurrenceStatus: EventOccurrenceStatus.upcoming,
  locationText: 'Jalan utama',
  status: EventStatus.published,
);

class _UsahaBrowseFake extends UsahaBrowse {
  _UsahaBrowseFake(super.query);

  @override
  Future<UsahaBrowseState> build() async =>
      UsahaBrowseState(items: const [_usaha]);
}

class _EventBrowseFake extends EventBrowse {
  _EventBrowseFake(super.query);

  @override
  Future<EventBrowseState> build() async =>
      EventBrowseState(items: [_event]);
}

Widget _app() => ProviderScope(
  overrides: [
    regionsProvider.overrideWith((ref) async => [_kec, ..._desa]),
    regionsKecamatanProvider.overrideWith((ref) async => [_kec]),
    placesProvider.overrideWith((ref) async => _places),
    usahaBrowseProvider.overrideWith2(
      (query) => _UsahaBrowseFake(query),
    ),
    eventBrowseProvider.overrideWith2((query) => _EventBrowseFake(query)),
  ],
  child: MaterialApp(
    home: FTheme(
      data: foruiPalettes['zinc']!.light.touch,
      child: const WilayahSheet(
        selected: _kec,
        initialDesaId: null,
        onPickSearchedDesa: _noopPick,
        onDesaTap: _noopTap,
      ),
    ),
  ),
);

Future<void> _noopPick(Region desa, Region kec) async {}
void _noopTap(Region desa) {}

void main() {
  testWidgets('default tab = Desa: listing desa tampil', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Desa 0'), findsOneWidget);
    expect(find.text('Desa 1'), findsOneWidget);
    expect(find.text('3 desa'), findsOneWidget);
  });

  testWidgets('chip Wisata: hanya wisata, kuliner tidak tampil', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wisata'));
    await tester.pumpAndSettle();

    expect(find.text('Pantai Temajuk'), findsOneWidget);
    expect(find.text('Bubur Pedas'), findsNothing);
    expect(find.text('1 wisata'), findsOneWidget);
  });

  testWidgets('chip Usaha: item usaha dari provider region', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Usaha'));
    await tester.pumpAndSettle();

    expect(find.text('Warung Mak Jam'), findsOneWidget);
  });

  testWidgets('chip Acara: item acara dari provider region', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Acara'));
    await tester.pumpAndSettle();

    expect(find.text('Pawai Taiping'), findsOneWidget);
  });
}
