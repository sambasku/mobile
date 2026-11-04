import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/encyclopedia_providers.dart';
import '../../domain/encyclopedia.entity.dart';
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
    extends ConsumerState<EncyclopediaContributionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _excerptController = TextEditingController();
  final _tagsController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _categoryId;
  bool _submitting = false;
  bool _success = false;
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
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
    _titleController.dispose();
    _excerptController.dispose();
    _tagsController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final l10n = AppLocalizations.of(context);
    if (_categoryId == null || _categoryId!.isEmpty) {
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaCategoryEmpty),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) {
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaFieldRequired),
      );
      return;
    }
    final payload = SubmitEncyclopediaContributionPayload(
      kind: widget.articleSlug == null ? 'new' : 'edit',
      title: _titleController.text.trim(),
      excerpt: _excerptController.text.trim(),
      bodyMd: _bodyController.text.trim(),
      categoryId: _categoryId!,
      tags: _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      articleId: widget.articleSlug,
    );
    setState(() => _submitting = true);
    try {
      await ref
          .read(encyclopediaRepositoryProvider)
          .submitContribution(payload);
      if (!mounted) return;
      setState(() => _success = true);
    } catch (_) {
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(l10n.encyclopediaSubmitFailed),
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
            onPress: _submitting || _success ? null : _submit,
            prefix: _submitting ? const FCircularProgress() : null,
            child: Text(l10n.encyclopediaSubmitButton),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.encyclopediaFieldTitle,
                  hintText: l10n.encyclopediaFieldTitlePlaceholder,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? l10n.encyclopediaFieldRequired
                        : null,
              ),
              const Gap(12),
              TextFormField(
                controller: _excerptController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.encyclopediaFieldExcerpt,
                  hintText: l10n.encyclopediaFieldExcerptPlaceholder,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? l10n.encyclopediaFieldRequired
                        : null,
              ),
              const Gap(12),
              if (categories.isEmpty)
                Text(
                  l10n.encyclopediaLoadFailed,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                )
              else
                FSelect<String>(
                  items: {for (final c in categories) c.name: c.id},
                  label: Text(l10n.encyclopediaFieldCategory),
                  hint: l10n.encyclopediaFieldCategoryPlaceholder,
                  control: FSelectControl.managed(
                    initial: _categoryId,
                    onChange: (value) => setState(() => _categoryId = value),
                  ),
                ),
              const Gap(12),
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: l10n.encyclopediaFieldTags,
                  hintText: l10n.encyclopediaFieldTagsPlaceholder,
                ),
              ),
              const Gap(12),
              TextFormField(
                controller: _bodyController,
                minLines: 12,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: l10n.encyclopediaFieldBody,
                  hintText: l10n.encyclopediaFieldBodyPlaceholder,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? l10n.encyclopediaFieldRequired
                        : null,
              ),
              if (_success)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.encyclopediaSubmitSuccessTitle,
                          style: theme.typography.body.lg.copyWith(
                            color: theme.colors.primaryForeground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          l10n.encyclopediaSubmitSuccessBody,
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.primaryForeground,
                          ),
                        ),
                        const Gap(12),
                        FButton(
                          onPress: () => encyclopediaPopOrGoExplore(context),
                          child: Text(l10n.encyclopediaContributeTitle),
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
