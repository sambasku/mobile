import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/cached_network_image_with_fallback.dart';

/// Bottom sheet pilih 1 sampai 4 foto Jinye untuk dijadikan foto lemma.
/// Kembali daftar `public_url` terpilih via Navigator.pop.
Future<List<String>?> showJinyePromoteImageSheet(
  BuildContext context, {
  required List<String> imageUrls,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => _JinyePromoteImageSheet(imageUrls: imageUrls),
  );
}

class _JinyePromoteImageSheet extends StatefulWidget {
  const _JinyePromoteImageSheet({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_JinyePromoteImageSheet> createState() =>
      _JinyePromoteImageSheetState();
}

class _JinyePromoteImageSheetState extends State<_JinyePromoteImageSheet> {
  late final Set<String> _selected = {widget.imageUrls.first};

  void _toggle(String url, bool on) {
    setState(() {
      if (on) {
        _selected.add(url);
      } else if (_selected.length > 1) {
        _selected.remove(url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.jinyePromoteImagePickTitle,
              style: context.theme.typography.body.lg,
            ),
            const Gap(8),
            FTileGroup(
              children: [
                for (final url in widget.imageUrls)
                  FTile(
                    prefix: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: CachedNetworkImageWithFallback(imageUrl: url),
                      ),
                    ),
                    title: Text(
                      '${widget.imageUrls.indexOf(url) + 1}',
                    ),
                    suffix: FCheckbox(
                      value: _selected.contains(url),
                      onChange: (v) => _toggle(url, v),
                    ),
                    onPress: () => _toggle(url, !_selected.contains(url)),
                  ),
              ],
            ),
            const Gap(8),
            FButton(
              onPress: () => Navigator.pop(
                context,
                widget.imageUrls.where(_selected.contains).toList(),
              ),
              child: Text(l10n.jinyePromoteImagePickConfirm),
            ),
          ],
        ),
      ),
    );
  }
}
