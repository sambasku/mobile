import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../../core/models/external_link.dart';
import '../../../../core/utils/display_image_url.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';
import '../../../explore/domain/sambas_map_config.dart';
import '../../../explore/presentation/widgets/sambas_map_view.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../providers/usaha_providers.dart';
import '../widgets/usaha_ui.dart';

/// Peta internal satu pin usaha + CTA Google Maps.
class UsahaMapPage extends ConsumerWidget {
  const UsahaMapPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(usahaBySlugProvider(slug));

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text(l10n.usahaActionViewOnMap),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(UsahaRouter.detailPath(slug)),
          ),
        ],
      ),
      child: async.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => Center(child: Text(l10n.usahaNotFound)),
        data: (usaha) {
          if (usaha == null || !usaha.hasCoordinates) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.usahaNoCoordinatesBody,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _MapBody(usaha: usaha);
        },
      ),
    );
  }
}

class _MapBody extends StatefulWidget {
  const _MapBody({required this.usaha});

  final Usaha usaha;

  @override
  State<_MapBody> createState() => _MapBodyState();
}

class _MapBodyState extends State<_MapBody> {
  MapLibreMapController? _controller;
  bool _pinAdded = false;

  LatLng get _target => LatLng(widget.usaha.lat!, widget.usaha.lng!);

  Future<void> _addPin() async {
    final controller = _controller;
    if (controller == null || _pinAdded || !mounted) return;
    _pinAdded = true;
    final colors = context.theme.colors;
    String hex(Color c) =>
        '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    await controller.addCircles([
      CircleOptions(
        geometry: _target,
        circleRadius: 20,
        circleColor: hex(colors.primary),
        circleOpacity: 0.2,
      ),
      CircleOptions(
        geometry: _target,
        circleRadius: 9,
        circleColor: hex(colors.primary),
        circleStrokeWidth: 3,
        circleStrokeColor: '#FFFFFF',
      ),
    ]);
    await controller.addSymbols([
      SymbolOptions(
        geometry: _target,
        textField: widget.usaha.name,
        textSize: 14,
        textOffset: const Offset(0, 1.6),
        textAnchor: 'top',
        textColor: hex(colors.foreground),
        textHaloColor: hex(colors.background),
        textHaloWidth: 2,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final usaha = widget.usaha;
    final cover = usaha.coverUrl;
    final mapsUri = usahaGoogleMapsUri(usaha);
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        Positioned.fill(
          child: SambasMapView(
            initialCameraPosition: CameraPosition(
              target: _target,
              zoom: SambasMapConfig.placeZoom,
            ),
            interactive: true,
            annotationOrder: const [
              AnnotationType.circle,
              AnnotationType.symbol,
            ],
            analyticsEntry: 'usaha',
            onMapCreated: (c) => _controller = c,
            onStyleLoaded: _addPin,
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12 + bottomPad,
          child: Material(
            type: MaterialType.transparency,
            child: FCard(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cover != null && cover.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: CachedNetworkImageWithFallback(
                            imageUrl:
                                displayImageUrl(cover, width: 160) ?? cover,
                            fallbackUrl: cover,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Gap(10),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            usaha.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.body.sm.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                          if (usaha.region != null || usaha.village != null) ...[
                            const Gap(4),
                            Text(
                              [
                                if (usaha.village != null)
                                  usaha.village!.name,
                                if (usaha.region != null) usaha.region!.name,
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.body.xs.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                          if (mapsUri != null) ...[
                            const Gap(8),
                            FButton(
                              onPress: () => launchExternalUrl(mapsUri),
                              size: FButtonSizeVariant.xs,
                              prefix: const Icon(FLucideIcons.navigation),
                              child: Text(l10n.exploreOpenInGoogleMaps),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
