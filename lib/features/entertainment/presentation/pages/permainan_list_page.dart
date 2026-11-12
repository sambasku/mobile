import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';

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

  /// Null = belum tersedia (baris tampil, tap diabaikan).
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

/// Ukuran cover sama daftar artikel ensiklopedia.
const _kCoverSize = 64.0;

({String title, String subtitle}) _labelsFor(
  AppLocalizations l10n,
  String id,
) => switch (id) {
  'pantun' => (title: l10n.pantunTitle, subtitle: l10n.pantunListSubtitle),
  _ => (title: id, subtitle: ''),
};

/// Hub Permainan: daftar vertikal (pola item ensiklopedia).
/// Permainan baru tinggal ditambah ke [_items] - halaman ini tidak berubah.
class PermainanListPage extends StatelessWidget {
  const PermainanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(l10n.permainanTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      child: ListView.builder(
        // Tanpa top: FHeader sudah SafeArea (sama ensiklopedia).
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final item = _items[i];
          return _PermainanListTile(
            item: item,
            onTap: item.path == null ? null : () => context.push(item.path!),
          );
        },
      ),
    );
  }
}

/// Baris permainan: cover 64 + judul/subtitle + chevron (mirror ensiklopedia).
class _PermainanListTile extends StatelessWidget {
  const _PermainanListTile({required this.item, this.onTap});

  final _Permainan item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final labels = _labelsFor(l10n, item.id);
    final comingSoon = item.path == null;
    final cover = item.coverAsset;

    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _kCoverSize,
              height: _kCoverSize,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: cover != null
                    ? Image.asset(
                        cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: theme.colors.muted,
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 28,
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ),
                      )
                    : ColoredBox(
                        color: theme.colors.muted,
                        child: Center(
                          child: Icon(
                            item.icon,
                            size: 28,
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    labels.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (comingSoon) ...[
                    const Gap(4),
                    Text(
                      l10n.pantunComingSoon,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ] else if (labels.subtitle.isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      labels.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!comingSoon) ...[
              const Gap(8),
              Icon(
                FLucideIcons.chevronRight,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
