import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/compress_image_for_upload.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/utils/image_sheet_drawer.dart';
import '../../../../shared/widgets/image_crop_page.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../../explore/explore_router.dart';
import '../../data/community_api.dart';
import '../../domain/community_org.dart';
import '../providers/community_providers.dart';

class CommunityContributePage extends ConsumerStatefulWidget {
  const CommunityContributePage({super.key});

  @override
  ConsumerState<CommunityContributePage> createState() =>
      _CommunityContributePageState();
}

class _CommunityContributePageState
    extends ConsumerState<CommunityContributePage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();
  File? _logo;
  String _categoryId = CommunityCategory.lain.id;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _pickLogo() {
    showImageSheetDrawer(
      context,
      picker: _picker,
      filePicker: false,
      lockedAspectRatio: const CropAspectRatio(label: '1:1', ratio: 1),
      onPicked: (file) {
        if (mounted) setState(() => _logo = file);
      },
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final description = _description.text.trim();
    if (name.length < 2) {
      showFToast(
        context: context,
        title: Text(l10n.communityContributeNameRequired),
      );
      return;
    }
    if (description.length < 10) {
      showFToast(
        context: context,
        title: Text(l10n.communityContributeDescRequired),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      String? logoUrl;
      final logo = _logo;
      if (logo != null) {
        final compressed = await compressImageForUpload(
          logo,
          maxWidth: 512,
          maxHeight: 512,
        );
        if (!mounted) return;
        logoUrl = await ref.read(
          uploadCommunityLogoProvider(compressed).future,
        );
      }
      if (!mounted) return;
      await ref.read(communityMineControllerProvider.notifier).submit(
        name: name,
        description: description,
        category: _categoryId,
        logoUrl: logoUrl,
      );
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(l10n.communityContributeSuccess),
      );
      context.pushReplacement(ExploreRouter.communityProposals.path);
    } on CommunityException catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.communityContributeFailed,
        message: e.message,
      );
    } catch (_) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.communityContributeFailed,
        message: l10n.communitySaveFailed,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final auth = ref.watch(authStatusProvider);
    final authed = auth.value?.isAuth == true;
    final catsAsync = ref.watch(communityCategoriesProvider);

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.communityContributeTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go('/explore/komunitas'),
          ),
        ],
      ),
      footer: authed
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: FButton(
                  onPress: _submitting ? null : _submit,
                  prefix: _submitting
                      ? const FCircularProgress(size: .sm)
                      : null,
                  child: Text(
                    _submitting
                        ? l10n.communityContributeSubmitting
                        : l10n.communityContributeSubmit,
                  ),
                ),
              ),
            )
          : null,
      child: auth.when(
        loading: () => const Center(child: FCircularProgress()),
        error: (_, _) => _LoginGate(l10n: l10n),
        data: (_) => authed
            ? _FormBody(
                theme: theme,
                logo: _logo,
                name: _name,
                description: _description,
                categoryId: _categoryId,
                categories: catsAsync.asData?.value ??
                    [
                      for (final c in CommunityCategory.formValues)
                        CommunityCategoryRef(
                          id: c.id,
                          name: _fallbackCategoryLabel(l10n, c),
                        ),
                    ],
                onCategory: (id) => setState(() => _categoryId = id),
                onPickLogo: _pickLogo,
              )
            : _LoginGate(l10n: l10n),
      ),
    );
  }
}

String _fallbackCategoryLabel(AppLocalizations l10n, CommunityCategory c) =>
    switch (c) {
      CommunityCategory.seni => l10n.communityCategorySeni,
      CommunityCategory.bahasa => l10n.communityCategoryBahasa,
      CommunityCategory.pendidikan => l10n.communityCategoryPendidikan,
      CommunityCategory.ukm => l10n.communityCategoryUkm,
      CommunityCategory.lain => l10n.communityCategoryLain,
      CommunityCategory.semua => l10n.communityCategoryAll,
    };

class _FormBody extends StatelessWidget {
  const _FormBody({
    required this.theme,
    required this.logo,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categories,
    required this.onCategory,
    required this.onPickLogo,
  });

  final FThemeData theme;
  final File? logo;
  final TextEditingController name;
  final TextEditingController description;
  final String categoryId;
  final List<CommunityCategoryRef> categories;
  final ValueChanged<String> onCategory;
  final VoidCallback onPickLogo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = categories.cast<CommunityCategoryRef?>().firstWhere(
      (c) => c!.id == categoryId,
      orElse: () => categories.isEmpty
          ? const CommunityCategoryRef(id: 'lain', name: 'Lainnya')
          : categories.first,
    )!;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: onPickLogo,
                child: Semantics(
                  button: true,
                  label: l10n.communityContributePickLogo,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: logo == null
                          ? Image.asset(
                              'assets/images/placeholder_512.png',
                              fit: BoxFit.cover,
                            )
                          : Image.file(logo!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const Gap(4),
              Text(
                l10n.communityContributePickLogo,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const Gap(16),
        Text(
          l10n.communityContributeName,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(6),
        FTextField(
          control: FTextFieldControl.managed(controller: name),
          hint: l10n.communityContributeNameHint,
          maxLength: 100,
        ),
        const Gap(16),
        FTileGroup(
          children: [
            FSelectMenuTile<String>(
              key: ValueKey(selected.id),
              title: Text(l10n.communityContributeCategory),
              details: Text(selected.name),
              selectControl: FMultiValueControl.managedRadio(
                initial: selected.id,
                onChange: (values) {
                  if (values.length == 1) onCategory(values.first);
                },
              ),
              menu: [
                for (final c in categories)
                  FSelectTile(value: c.id, title: Text(c.name)),
              ],
            ),
          ],
        ),
        const Gap(16),
        Text(
          l10n.communityContributeDesc,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(6),
        FTextField(
          control: FTextFieldControl.managed(controller: description),
          hint: l10n.communityContributeDescHint,
          maxLines: 4,
          maxLength: 320,
        ),
        const Gap(8),
        Text(
          l10n.communityContributeNote,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _LoginGate extends StatelessWidget {
  const _LoginGate({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FLucideIcons.users,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            const Gap(10),
            Text(
              l10n.communityContributeLoginGate,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            FButton(
              variant: FButtonVariant.outline,
              onPress: () => context.push('/login'),
              child: Text(l10n.commonLoginRequiredShort),
            ),
          ],
        ),
      ),
    );
  }
}
