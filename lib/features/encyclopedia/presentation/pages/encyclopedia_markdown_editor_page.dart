import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/markdown_editor/markdown_editor_page.dart';
import '../../data/encyclopedia_markdown_upload.dart';

/// Wrapper editor Markdown untuk usulan ensiklopedia (upload purpose=encyclopedia).
class EncyclopediaMarkdownEditorPage extends ConsumerWidget {
  const EncyclopediaMarkdownEditorPage({
    super.key,
    this.initialMarkdown = '',
  });

  final String initialMarkdown;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final uploader = ref.watch(encyclopediaMarkdownUploadProvider(l10n));
    return MarkdownEditorPage(
      initialMarkdown: initialMarkdown,
      title: l10n.mdEditorTitle,
      uploadImage: uploader.upload,
    );
  }
}
