import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../shared/stickers/sticker_providers.dart';
import '../../../../shared/stickers/sticker_view.dart';

/// Adapter chat → katalog API (lookup by id + cache).
class ChatStickerView extends ConsumerWidget {
  const ChatStickerView({
    super.key,
    required this.stickerId,
    this.size = 96,
  });

  final String stickerId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(stickerLookupProvider(stickerId));
    final sticker = async.asData?.value;
    return StickerIdView(
      stickerId: stickerId,
      sticker: sticker,
      size: size,
    );
  }
}
