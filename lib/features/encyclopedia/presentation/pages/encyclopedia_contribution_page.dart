import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/state/local_form_draft_store.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
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
  const EncyclopediaContributionPage({
    super.key,
    this.articleSlug,
    this.contributionId,
  });

  /// Mode usul perbaikan artikel published (query `article_slug`).
  final String? articleSlug;

  /// Mode ubah usulan yang belum diverifikasi (query `contribution_id`).
  final String? contributionId;

  @override
  ConsumerState<EncyclopediaContributionPage> createState() =>
      _EncyclopediaContributionPageState();
}

class _EncyclopediaContributionPageState
    extends ConsumerState<EncyclopediaContributionPage>
    with LocalDraftKeeper<_EncyclopediaDraft> {
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  String _bodyMd = '';
  String? _categoryId;

  /// ULID artikel target (mode edit artikel published).
  String? _articleId;

  bool _prefilled = false;
  bool _submitting = false;
  bool _authChecked = false;

  bool get _isEditingContribution =>
      widget.contributionId != null && widget.contributionId!.isNotEmpty;

  @override
  String get draftKey =>
      'ensiklopedia:${widget.contributionId ?? widget.articleSlug ?? 'new'}';

  @override
  bool get draftHasContent => captureDraft().hasContent;

  @override
  String get draftToken => [
    _articleId,
    _titleController.text,
    _tagsController.text,
    _sourceUrlController.text,
    _bodyMd,
    _categoryId,
  ].join('\u0001');

  @override
  _EncyclopediaDraft captureDraft() => _EncyclopediaDraft(
    articleId: _articleId,
    title: _titleController.text,
    tags: _tagsController.text,
    sourceUrl: _sourceUrlController.text,
    bodyMd: _bodyMd,
    categoryId: _categoryId,
  );

  @override
  void restoreDraft(_EncyclopediaDraft draft) {
    _articleId = draft.articleId;
    _titleController.text = draft.title;
    _tagsController.text = draft.tags;
    _sourceUrlController.text = draft.sourceUrl;
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
    _sourceUrlController.dispose();
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
    _sourceUrlController.text = article.sourceUrl ?? '';
    sealDraftBaseline();
  }

  void _applyContribution(MyContributionItem item) {
    _prefilled = true;
    _articleId = item.articleId;
    final p = item.payload;
    if (p != null) {
      _titleController.text = p.title;
      _bodyMd = p.bodyMd;
      _categoryId = p.categoryId;
      _tagsController.text = p.tags.join(', ');
      _sourceUrlController.text = p.sourceUrl ?? '';
    }
    sealDraftBaseline();
  }

  Map<String, dynamic> _payloadBody() {
    final source = _sourceUrlController.text.trim();
    return {
      'title': _titleController.text.trim(),
      'excerpt': '',
      'body_md': _bodyMd.trim(),
      'category_id': _categoryId!,
      'tags': _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      if (source.isNotEmpty) 'source_url': source,
    };
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
    final source = _sourceUrlController.text.trim();
    if (source.isNotEmpty && !source.startsWith('https://')) {
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaFieldSourceUrlHttpsRequired),
      );
      return;
    }

    if (_isEditingContribution) {
      final id = widget.contributionId!;
      setState(() => _submitting = true);
      try {
        await ref
            .read(encyclopediaRepositoryProvider)
            .updateContribution(id, _payloadBody());
        commitLocalDraft();
        if (!mounted) return;
        ref.invalidate(myEncyclopediaContributionsProvider);
        context.pushReplacement(EncyclopediaRouter.myContributions.path);
      } catch (_) {
        if (!mounted) return;
        await showAppErrorSheet(
          context,
          message: l10n.encyclopediaUpdateFailed,
        );
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
      return;
    }

    final isEditArticle = widget.articleSlug != null;
    if (isEditArticle && (_articleId == null || _articleId!.isEmpty)) {
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaEditArticleMissing),
      );
      return;
    }
    final payload = SubmitEncyclopediaContributionPayload(
      kind: isEditArticle ? 'edit' : 'new',
      title: _titleController.text.trim(),
      excerpt: '',
      bodyMd: _bodyMd.trim(),
      categoryId: _categoryId!,
      tags: _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      articleId: isEditArticle ? _articleId : null,
      sourceUrl: source.isEmpty ? null : source,
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
      await showAppErrorSheet(
        context,
        message: l10n.encyclopediaSubmitFailed,
      );
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

    final contributionId = widget.contributionId;
    if (contributionId != null &&
        contributionId.isNotEmpty &&
        !_prefilled) {
      final items =
          ref.watch(myEncyclopediaContributionsProvider).asData?.value;
      if (items != null) {
        MyContributionItem? match;
        for (final item in items) {
          if (item.id == contributionId) {
            match = item;
            break;
          }
        }
        if (match != null) {
          final found = match;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _prefilled) return;
            setState(() => _applyContribution(found));
          });
        }
      }
    }

    final slug = widget.articleSlug;
    if (slug != null && !_prefilled && !_isEditingContribution) {
      final article = ref.watch(encyclopediaArticleProvider(slug)).asData?.value;
      if (article != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _prefilled) return;
          setState(() => _applyArticle(article));
        });
      }
    }

    final titleText = _isEditingContribution
        ? l10n.encyclopediaContributeUpdateTitle
        : (widget.articleSlug == null
              ? l10n.encyclopediaContributeTitle
              : l10n.encyclopediaContributeEditTitle);
    final ctaText = _isEditingContribution
        ? l10n.encyclopediaUpdateButton
        : l10n.encyclopediaSubmitButton;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(titleText),
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
            child: Text(ctaText),
          ),
        ),
      ),
      // Horizontal dari childPad FScaffold - jangan dobel padding scroll.
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 40),
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
            FTextField(
              control: FTextFieldControl.managed(
                controller: _sourceUrlController,
              ),
              label: Text(l10n.encyclopediaFieldSourceUrl),
              hint: l10n.encyclopediaFieldSourceUrlHint,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
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
    required this.sourceUrl,
    required this.bodyMd,
    required this.categoryId,
  });

  final String? articleId;
  final String title;
  final String tags;
  final String sourceUrl;
  final String bodyMd;
  final String? categoryId;

  bool get hasContent =>
      (articleId != null && articleId!.isNotEmpty) ||
      title.trim().isNotEmpty ||
      tags.trim().isNotEmpty ||
      sourceUrl.trim().isNotEmpty ||
      bodyMd.trim().isNotEmpty ||
      (categoryId != null && categoryId!.isNotEmpty);
}
