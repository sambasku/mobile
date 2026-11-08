import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/option_picker_sheet.dart';
import '../../auth/presentation/providers/auth_status_providers.dart';
import '../../explore/domain/entities/region.dart';
import '../../explore/explore_router.dart';
import '../../explore/presentation/providers/regions_providers.dart';
import '../domain/layanan.dart';
import '../layanan_router.dart';
import 'layanan_logo.dart';
import 'layanan_phone_actions.dart';
import 'layanan_providers.dart';

class LayananPage extends ConsumerStatefulWidget {
  const LayananPage({super.key});

  @override
  ConsumerState<LayananPage> createState() => _LayananPageState();
}

class _LayananPageState extends ConsumerState<LayananPage> {
  String? _regionId;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(layananKecamatanPrefKey);
    if (!mounted) return;
    setState(() => _regionId = saved);
  }

  Future<void> _pick(List<Region> kecamatan) async {
    final l10n = AppLocalizations.of(context);
    final id = await showOptionPickerSheet<String>(
      context,
      title: l10n.layananPickKecamatan,
      searchable: true,
      searchHint: l10n.layananPickKecamatan,
      items: [
        for (final region in kecamatan)
          OptionPickerItem(
            value: region.id,
            label: region.name,
            selected: region.id == _regionId,
          ),
      ],
    );
    if (id == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(layananKecamatanPrefKey, id);
    if (!mounted) return;
    setState(() => _regionId = id);
  }

  Future<void> _propose(String? regionId) async {
    final authed = ref.read(authStatusProvider).value?.isAuth ?? false;
    if (!authed) {
      context.push('/login');
      return;
    }
    context.push(LayananRouter.contributePath(regionId: regionId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final kecamatan = ref.watch(regionsKecamatanProvider);
    return kecamatan.when(
      loading: () => _shell(l10n, const Center(child: FCircularProgress())),
      error: (_, _) => _shell(l10n, Center(child: Text(l10n.layananLoadFailed))),
      data: (regions) {
        final selected = regions.cast<Region?>().firstWhere(
          (r) => r!.id == _regionId,
          orElse: () => regions.isEmpty ? null : regions.first,
        );
        final regionId = selected?.id;
        return _shell(
          l10n,
          regionId == null
              ? Center(child: Text(l10n.layananEmpty))
              : _body(l10n, regions, selected!, regionId),
          onPropose: () => _propose(regionId),
        );
      },
    );
  }

  Widget _shell(AppLocalizations l10n, Widget child, {VoidCallback? onPropose}) {
    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.layananTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () =>
                context.canPop() ? context.pop() : context.go(ExploreRouter.hub.path),
          ),
        ],
        suffixes: [
          if (onPropose != null)
            FHeaderAction(
              icon: const Icon(FLucideIcons.plus),
              onPress: onPropose,
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _body(
    AppLocalizations l10n,
    List<Region> regions,
    Region selected,
    String regionId,
  ) {
    final list = ref.watch(layananByRegionProvider(regionId));
    return list.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (_, _) => Center(child: Text(l10n.layananLoadFailed)),
      data: (items) {
        final ambulans = items.where((e) => e.isAmbulance).toList();
        final pemadam = items.where((e) => !e.isAmbulance).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            FTileGroup(
              children: [
                FTile(
                  title: Text(selected.name),
                  subtitle: Text(l10n.layananPickKecamatan),
                  suffix: const Icon(FLucideIcons.chevronRight),
                  onPress: () => _pick(regions),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(l10n.layananEmpty, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FButton(
                      onPress: () => _propose(regionId),
                      child: Text(l10n.layananPropose),
                    ),
                  ],
                ),
              )
            else ...[
              _group(l10n, l10n.layananAmbulance, ambulans),
              const SizedBox(height: 12),
              _group(l10n, l10n.layananFire, pemadam),
            ],
          ],
        );
      },
    );
  }

  Widget _group(AppLocalizations l10n, String title, List<LayananEntry> items) {
    return FTileGroup(
      label: Text(title),
      children: [
        if (items.isEmpty)
          FTile(title: Text(l10n.layananCategoryEmpty))
        else
          for (final item in items)
            FTile(
              prefix: LayananLogo(
                logoUrl: item.logoUrl,
                isAmbulance: item.isAmbulance,
                onTap: () => context.push(LayananRouter.detailPath(item.slug)),
              ),
              title: Text(item.name),
              subtitle: Text(
                '${layananPhonesSubtitle(l10n, item.phones)}\n${l10n.layananCheckedOn(_day(item.updatedAt))}',
              ),
              suffix: FButton(
                onPress: () => callOrPickLayananPhones(
                  context,
                  phones: item.phones,
                ),
                child: Text(l10n.layananCall),
              ),
              onPress: () => context.push(LayananRouter.detailPath(item.slug)),
            ),
      ],
    );
  }

  String _day(DateTime value) {
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    return '$d-$m-${value.year}';
  }
}
