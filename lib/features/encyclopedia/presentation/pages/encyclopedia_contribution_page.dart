import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/state/local_form_draft_store.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../data/encyclopedia_providers.dart';
import '../../domain/encyclopedia.entity.dart';
import '../../encyclopedia_router.dart';
import '../providers/encyclopedia_contribution_providers.dart';
import '../providers/encyclopedia_detail_providers.dart';
import '../providers/encyclopedia_list_providers.dart';
import '../utils/encyclopedia_auth.dart';
import '../utils/encyclopedia_back.dart';

class EncyclopediaContributionPage extends ConsumerStatefulWidget {
  const EncyclopediaContributionPage({super.key, this.articleSlug});
  final String? articleSlug;

  @override
  ConsumerState<EncyclopediaContributionPage> createState() =>
      _EncyclopediaContributionPageState();
}

class _EncyclopediaContributionPageState
    extends ConsumerState<EncyclopediaContributionPage>
    with LocalDraftKeeper<_EncyclopediaDraft> {
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  String _bodyMd = '';
  String? _categoryId;

  /// ULID artikel target (mode edit). Jangan kirim slug di article_id.
  String? _articleId;
  bool _prefilled = false;
  bool _submitting = false;
  bool _authChecked = false;

  @override
  String get draftKey => 'ensiklopedia:${widget.articleSlug ?? 'new'}';

  @override
  bool get draftHasContent => captureDraft().hasContent;

  @override
  String get draftToken => [
    _articleId,
    _titleController.text,
    _tagsController.text,
    _bodyMd,
    _categoryId,
  ].join('\u0001');

  @override
  _EncyclopediaDraft captureDraft() => _EncyclopediaDraft(
    articleId: _articleId,
    title: _titleController.text,
    tags: _tagsController.text,
    bodyMd: _bodyMd,
    categoryId: _categoryId,
  );

  @override
  void restoreDraft(_EncyclopediaDraft draft) {
    _articleId = draft.articleId;
    _titleController.text = draft.title;
    _tagsController.text = draft.tags;
    _bodyMd = draft.bodyMd;
    _categoryId = draft.categoryId;
    if (draft.articleId != null || draft.hasContent) {
      _prefilled = true;
    }
  }

  @override
  void initState() {
    super.initState();
    loadLocalDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAuth());
  }

  Future<void> _ensureAuth() async {
    if (!mounted || _authChecked) return;
    _authChecked = true;
    final l10n = AppLocalizations.of(context);
    final ok = await ensureEncyclopediaAuth(
      context,
      ref,
      body: l10n.encyclopediaLoginContributeBody,
    );
    if (!ok && mounted) {
      encyclopediaPopOrGoExplore(context);
    }
  }

  @override
  void dispose() {
    flushLocalDraft();
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  String? _selectedCategoryName(List<EncyclopediaCategory> categories) {
    final id = _categoryId;
    if (id == null || id.isEmpty) return null;
    for (final category in categories) {
      if (category.id == id) return category.name;
    }
    return null;
  }

  Future<void> _pickCategory(List<EncyclopediaCategory> categories) async {
    if (_submitting || categories.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final picked = await showOptionPickerSheet<String>(
      context,
      title: l10n.encyclopediaFieldCategory,
      icon: FLucideIcons.listFilter,
      items: [
        for (final category in categories)
          OptionPickerItem(
            value: category.id,
            label: category.name,
            selected: category.id == _categoryId,
          ),
      ],
    );
    if (!mounted || picked == null || picked.isEmpty) return;
    setState(() => _categoryId = picked);
  }

  Future<void> _openBodyEditor() async {
    final result = await context.push<String>(
      EncyclopediaRouter.editor.path,
      extra: _bodyMd,
    );
    if (!mounted || result == null) return;
    setState(() => _bodyMd = result);
  }

  void _applyArticle(EncyclopediaArticle article) {
    _prefilled = true;
    _articleId = article.id;
    _titleController.text = article.title;
    _bodyMd = article.bodyMd;
    _categoryId = article.category.id;
    _tagsController.text = article.tags.join(', ');
    sealDraftBaseline();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final l10n = AppLocalizations.of(context);
    if (_categoryId == null || _categoryId!.isEmpty) {
      showFToast(context: context, title: Text(l10n.encyclopediaCategoryEmpty));
      return;
    }
    if (_titleController.text.trim().isEmpty || _bodyMd.trim().isEmpty) {
      showFToast(context: context, title: Text(l10n.encyclopediaFieldRequired));
      return;
    }
    final isEdit = widget.articleSlug != null;
    if (isEdit && (_articleId == null || _articleId!.isEmpty)) {
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaEditArticleMissing),
      );
      return;
    }
    final payload = SubmitEncyclopediaContributionPayload(
      kind: isEdit ? 'edit' : 'new',
      title: _titleController.text.trim(),
      // API boleh kosong; ringkasan tidak ditampilkan di form usulan.
      excerpt: '',
      bodyMd: _bodyMd.trim(),
      categoryId: _categoryId!,
      tags: _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      articleId: isEdit ? _articleId : null,
    );
    setState(() => _submitting = true);
    try {
      await ref
          .read(encyclopediaRepositoryProvider)
          .submitContribution(payload);
      commitLocalDraft();
      if (!mounted) return;
      ref.invalidate(myEncyclopediaContributionsProvider);
      context.pushReplacement(EncyclopediaRouter.myContributions.path);
    } catch (_) {
      if (!mounted) return;
      showFToast(context: context, title: Text(l10n.encyclopediaSubmitFailed));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final categories = ref.watch(encyclopediaCategoriesProvider).value ?? [];
    final selectedCategory = _selectedCategoryName(categories);
    final bodyEmpty = _bodyMd.trim().isEmpty;
    final bodyPreview = bodyEmpty
        ? null
        : _bodyMd.trim().replaceAll(RegExp(r'\s+'), ' ');
    final slug = widget.articleSlug;
    if (slug != null && !_prefilled) {
      final article = ref.watch(encyclopediaArticleProvider(slug)).asData?.value;
      if (article != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _prefilled) return;
          setState(() => _applyArticle(article));
        });
      }
    }

    return FScaffold(
      header: FHeader.nested(
        title: Text(
          widget.articleSlug == null
              ? l10n.encyclopediaContributeTitle
              : l10n.encyclopediaContributeEditTitle,
        ),
        prefixes: [
          FHeaderAction.back(
            onPress: () => encyclopediaPopOrGoExplore(context),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: _submitting ? null : _submit,
            prefix: _submitting ? const FCircularProgress() : null,
            child: Text(l10n.encyclopediaSubmitButton),
          ),
        ),
      ),
      // childPad FScaffold sudah memberi gutter horizontal - jangan pad lagi.
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FTextField(
              control: FTextFieldControl.managed(controller: _titleController),
              label: Text(l10n.encyclopediaFieldTitle),
              hint: l10n.encyclopediaFieldTitlePlaceholder,
              textInputAction: TextInputAction.next,
            ),
            const Gap(12),
            if (categories.isEmpty)
              Text(
                l10n.encyclopediaLoadFailed,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              )
            else ...[
              Text(
                l10n.encyclopediaFieldCategory,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              const Gap(6),
              FTileGroup(
                children: [
                  FTile(
                    title: Text(
                      selectedCategory ??
                          l10n.encyclopediaFieldCategoryPlaceholder,
                      style: selectedCategory == null
                          ? theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            )
                          : null,
                    ),
                    suffix: Icon(
                      FLucideIcons.chevronDown,
                      color: theme.colors.mutedForeground,
                    ),
                    onPress: _submitting
                        ? null
                        : () => _pickCategory(categories),
                  ),
                ],
              ),
            ],
            const Gap(12),
            FTextField(
              control: FTextFieldControl.managed(controller: _tagsController),
              label: Text(l10n.encyclopediaFieldTags),
              hint: l10n.encyclopediaFieldTagsPlaceholder,
            ),
            const Gap(12),
            Text(
              l10n.encyclopediaFieldBody,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
            const Gap(6),
            FTileGroup(
              children: [
                FTile(
                  title: Text(l10n.encyclopediaBodyTapToEdit),
                  subtitle: Text(
                    bodyEmpty
                        ? l10n.encyclopediaBodyTapHint
                        : (bodyPreview!.length > 120
                              ? '${bodyPreview.substring(0, 120)}...'
                              : bodyPreview),
                  ),
                  suffix: Icon(
                    FLucideIcons.chevronRight,
                    color: theme.colors.mutedForeground,
                  ),
                  onPress: _submitting ? null : _openBodyEditor,
                ),
              ],
            ),
            if (!bodyEmpty) ...[
              const Gap(4),
              Text(
                l10n.encyclopediaBodyHasContentHint,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EncyclopediaDraft {
  const _EncyclopediaDraft({
    required this.articleId,
    required this.title,
    required this.tags,
    required this.bodyMd,
    required this.categoryId,
  });

  final String? articleId;
  final String title;
  final String tags;
  final String bodyMd;
  final String? categoryId;

  bool get hasContent =>
      (articleId != null && articleId!.isNotEmpty) ||
      title.trim().isNotEmpty ||
      tags.trim().isNotEmpty ||
      bodyMd.trim().isNotEmpty ||
      (categoryId != null && categoryId!.isNotEmpty);
}
