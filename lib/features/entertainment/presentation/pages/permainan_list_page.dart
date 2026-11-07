import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../explore/presentation/widgets/explore_cover_card.dart';

/// Satu permainan di hub. Tambah entri baru cukup di [_items].
/// Judul/subtitle diambil dari ARB lewat [id] saat render.
class _Permainan {
  const _Permainan({
    required this.id,
    required this.icon,
    this.path,
    this.coverAsset,
  });

  final String id;
  final IconData icon;

  /// Null = belum tersedia (kartu tampil, tap diabaikan).
  final String? path;

  /// Cover WebP opsional (`assets/images/explore_covers/…`).
  final String? coverAsset;
}

const _items = <_Permainan>[
  _Permainan(
    id: 'pantun',
    icon: FLucideIcons.feather,
    path: '/entertainment/pantun',
    coverAsset: 'assets/images/explore_covers/pantun.webp',
  ),
];

({String title, String subtitle}) _labelsFor(
  AppLocalizations l10n,
  String id,
) => switch (id) {
  'pantun' => (title: l10n.pantunTitle, subtitle: l10n.pantunListSubtitle),
  _ => (title: id, subtitle: ''),
};

/// Hub Permainan: grid 3 kolom berisi semua permainan Sambas.
/// Permainan baru tinggal ditambah ke [_items] - halaman ini tidak berubah.
class PermainanListPage extends StatelessWidget {
  const PermainanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(AppLocalizations.of(context).permainanTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final childAspectRatio = ExploreCoverCard.gridChildAspectRatio(
            maxWidth: constraints.maxWidth,
          );
          return GridView.builder(
            padding: const EdgeInsets.only(top: 0, bottom: 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final item = _items[i];
              return _PermainanCard(
                item: item,
                onTap: item.path == null
                    ? null
                    : () => context.push(item.path!),
              );
            },
          );
        },
      ),
    );
  }
}

class _PermainanCard extends StatelessWidget {
  const _PermainanCard({required this.item, this.onTap});

  final _Permainan item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = _labelsFor(l10n, item.id);
    return ExploreCoverCard(
      title: labels.title,
      onTap: onTap,
      coverAsset: item.coverAsset,
      badge: item.path == null ? Text(l10n.pantunComingSoon) : null,
    );
  }
}
