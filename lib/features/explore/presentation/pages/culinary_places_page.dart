import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/culinary_contribution_api.dart';
import '../../domain/entities/culinary_place.dart';
import '../../explore_router.dart';
import '../providers/cuisine_providers.dart';
import '../widgets/culinary_action_sheets.dart';

void _back(BuildContext context) =>
    context.canPop() ? context.pop() : context.go('/explore');

/// Daftar tempat/penjual kuliner (`/api/v1/culinary/places`).
///
/// Aksi per tempat: klaim pengelolaan, usul status buka/tutup, lapor.
/// Semua butuh akun - guest dapat arahan masuk dulu.
class CulinaryPlacesPage extends ConsumerStatefulWidget {
  const CulinaryPlacesPage({super.key});

  @override
  ConsumerState<CulinaryPlacesPage> createState() => _CulinaryPlacesPageState();
}

class _CulinaryPlacesPageState extends ConsumerState<CulinaryPlacesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final placesAsync = ref.watch(culinaryPlacesProvider(q: _query));

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: const Text('Tempat kuliner'),
        prefixes: [FHeaderAction.back(onPress: () => _back(context))],
        suffixes: [
          FHeaderAction(
            icon: const Icon(FLucideIcons.plus),
            onPress: () =>
                context.push(ExploreRouter.cuisinePlaceContribute.path),
            semanticsLabel: 'Usulkan tempat kuliner',
          ),
        ],
      ),
      child: placesAsync.when(
        loading: () => const Center(child: FCircularProgress(size: .sm)),
        error: (_, _) =>
            _ErrorBody(onRetry: () => ref.invalidate(culinaryPlacesProvider)),
        data: (page) {
          if (page == null) {
            return _ErrorBody(
              onRetry: () => ref.invalidate(culinaryPlacesProvider),
            );
          }
          final items = page.items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FTextField(
                control: FTextFieldControl.managed(
                  onChange: (value) =>
                      setState(() => _query = value.text.trim()),
                ),
                hint: 'Cari tempat atau penjual...',
                prefixBuilder: (context, style, variants) =>
                    FTextField.prefixIconBuilder(
                      context,
                      style,
                      variants,
                      const Icon(FLucideIcons.search),
                    ),
              ),
              const Gap(12),
              if (items.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Belum ada tempat yang cocok.',
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _PlaceTile(place: items[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlaceTile extends ConsumerWidget {
  const _PlaceTile({required this.place});

  final CulinaryPlace place;

  Future<void> _actions(BuildContext context, WidgetRef ref) async {
    final authed = ref.read(authStatusProvider).value?.isAuth == true;
    if (!authed) {
      await showAppErrorSheet(
        context,
        title: 'Masuk dulu ya',
        message:
            'Klaim, usul status, dan laporan butuh akun supaya bisa ditindak lanjuti.',
      );
      return;
    }
    final action = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            FTile(
              title: const Text('Klaim tempat ini'),
              subtitle: const Text('Kamu pemilik atau pengelola sah?'),
              onPress: () => Navigator.pop(ctx, 'claim'),
            ),
            FTile(
              title: const Text('Usul perbaikan data'),
              subtitle: const Text('Nama, deskripsi, atau alamat salah?'),
              onPress: () => Navigator.pop(ctx, 'edit'),
            ),
            FTile(
              title: const Text('Usulkan status buka/tutup'),
              onPress: () => Navigator.pop(ctx, 'operational'),
            ),
            FTile(
              title: const Text('Laporkan masalah'),
              onPress: () => Navigator.pop(ctx, 'report'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case 'claim':
        await _claim(context, ref);
      case 'edit':
        await showCulinaryEditSheet(
          context,
          ref,
          target: CulinaryEditTarget.place(
            id: place.id,
            name: place.name,
            description: place.description ?? '',
            addressText: place.addressText,
          ),
        );
      case 'operational':
        await _operational(context, ref);
      case 'report':
        await _report(context, ref);
    }
  }

  Future<void> _claim(BuildContext context, WidgetRef ref) async {
    final evidence = await _askText(
      context,
      title: 'Klaim pengelolaan',
      hint: 'Nomor WhatsApp atau akun media sosial pengelola',
    );
    if (evidence == null) return;
    if (evidence.length < 5) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: 'Bukti kurang',
        message: 'Tulis bukti minimal 5 karakter ya.',
      );
      return;
    }
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .claimPlace(place.slug, contactEvidence: evidence);
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: 'Klaim terkirim',
        message:
            'Admin akan memeriksa buktinya dulu. Kamu bisa pantau statusnya nanti.',
      );
    } on CulinaryException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: 'Klaim gagal',
        message: e.message,
      );
    }
  }

  Future<void> _operational(BuildContext context, WidgetRef ref) async {
    const labels = {
      'operating': 'Buka',
      'temporarily_closed': 'Tutup sementara',
      'permanently_closed': 'Tutup permanen',
      'unknown': 'Belum diketahui',
    };
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          children: [
            for (final entry in labels.entries)
              FTile(
                title: Text(entry.value),
                suffix: entry.key == place.operationalStatus
                    ? const Icon(FLucideIcons.check, size: 18)
                    : null,
                onPress: () => Navigator.pop(ctx, entry.key),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .submitChange(
            kind: 'place_operational',
            placeId: place.id,
            payload: {'operationalStatus': picked},
            fields: const ['operationalStatus'],
          );
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: 'Usulan terkirim',
        message: 'Status baru akan tayang setelah admin setujui.',
      );
    } on CulinaryException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: 'Usulan gagal',
        message: e.message,
      );
    }
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    const reasons = {
      'closed': 'Tempat sudah tutup',
      'wrong_location': 'Lokasi tidak sesuai',
      'invalid_contact': 'Kontak tidak valid',
      'misleading': 'Informasi menyesatkan',
      'duplicate': 'Dugaan duplikat',
      'abuse': 'Dugaan pelanggaran',
    };
    final picked = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => SafeArea(
        top: false,
        child: FTileGroup(
          label: const Text('Apa yang salah?'),
          children: [
            for (final entry in reasons.entries)
              FTile(
                title: Text(entry.value),
                onPress: () => Navigator.pop(ctx, entry.key),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !context.mounted) return;
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .reportPlace(place.slug, reasonCode: picked);
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: 'Laporan terkirim',
        message: 'Terima kasih. Admin akan memeriksa tempat ini.',
      );
    } on CulinaryException catch (e) {
      if (!context.mounted) return;
      await showAppErrorSheet(
        context,
        title: 'Gagal melapor',
        message: e.message,
      );
    }
  }

  Future<String?> _askText(
    BuildContext context, {
    required String title,
    required String hint,
  }) {
    final controller = TextEditingController();
    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  style: ctx.theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Gap(8),
                Text(
                  'Tulis bukti bahwa kamu pemilik atau pengelola sah.',
                  style: ctx.theme.typography.body.sm.copyWith(
                    color: ctx.theme.colors.mutedForeground,
                  ),
                ),
                const Gap(12),
                FTextField.multiline(
                  control: FTextFieldControl.managed(controller: controller),
                  hint: hint,
                  maxLines: 4,
                ),
                const Gap(16),
                FButton(
                  onPress: () => Navigator.pop(ctx, controller.text.trim()),
                  child: const Text('Kirim klaim'),
                ),
                const Gap(8),
                FButton(
                  variant: FButtonVariant.outline,
                  onPress: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final place = this.place;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => _actions(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: 64,
                  child: place.coverUrl == null
                      ? ColoredBox(
                          color: theme.colors.muted,
                          child: Icon(
                            FLucideIcons.store,
                            color: theme.colors.mutedForeground,
                          ),
                        )
                      : Image.network(
                          place.coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: theme.colors.muted,
                            child: Icon(
                              FLucideIcons.store,
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
                      place.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      culinaryOperationalLabel(place.operationalStatus),
                      style: theme.typography.body.xs.copyWith(
                        color: place.operationalStatus == 'operating'
                            ? theme.colors.primary
                            : theme.colors.mutedForeground,
                      ),
                    ),
                    if (place.addressText != null || place.locationHint != null)
                      Text(
                        place.addressText ?? place.locationHint!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                FLucideIcons.chevronRight,
                size: 18,
                color: theme.colors.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FAlert(
              title: Text('Gagal memuat'),
              subtitle: Text(
                'Gagal terhubung ke server. Coba lagi dalam beberapa saat.',
              ),
            ),
            const Gap(16),
            FButton(onPress: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
