import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Satu permainan di hub. Tambah entri baru cukup di [_items].
class _Permainan {
  const _Permainan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.path,
  });

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  /// Null = belum tersedia (kartu tampil, tap diabaikan).
  final String? path;
}

const _items = <_Permainan>[
  _Permainan(
    id: 'pantun',
    title: 'Pantun',
    subtitle: 'Balas pantun 4 baris',
    icon: FLucideIcons.feather,
    path: '/entertainment/pantun',
  ),
];

/// Hub Permainan: grid 3 kolom berisi semua permainan Sambas.
/// Permainan baru tinggal ditambah ke [_items] - halaman ini tidak berubah.
class PermainanListPage extends StatelessWidget {
  const PermainanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Permainan'),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/explore'),
          ),
        ],
      ),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.98,
        ),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final item = _items[i];
          return _PermainanCard(
            item: item,
            onTap: item.path == null ? null : () => context.push(item.path!),
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
    final theme = context.theme;
    return Material(
      color: theme.colors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.icon, size: 20, color: theme.colors.primary),
                  if (item.path == null) ...[
                    const Gap(6),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Segera'),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.sm.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.sm.copyWith(
                          fontSize: 9,
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
