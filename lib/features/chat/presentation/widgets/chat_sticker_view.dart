import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../shared/stickers/sticker_detail_sheet.dart';
import '../../../../shared/stickers/sticker_providers.dart';
import '../../../../shared/stickers/sticker_view.dart';

/// Adapter chat -> katalog API (lookup by id + cache) + tap-to-favorite.
class ChatStickerView extends ConsumerWidget {
  const ChatStickerView({
    super.key,
    required this.stickerId,
    this.size = 110,
    this.tappable = true,
    this.onSendSticker,
  });

  final String stickerId;
  final double size;
  final bool tappable;
  final VoidCallback? onSendSticker;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stickerLookupProvider(stickerId));
    final sticker = async.asData?.value;
    return StickerIdView(
      stickerId: stickerId,
      sticker: sticker,
      size: size,
      enableDetailSheet: tappable,
      onTap: (tappable && sticker != null)
          ? () => showStickerDetailSheet(
                context,
                sticker,
                onSend: onSendSticker,
              )
          : null,
    );
  }
}
