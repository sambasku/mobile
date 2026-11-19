import 'dart:async';

import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../auth/auth_router.dart';
import '../../../auth/presentation/providers/auth_status_providers.dart';
import '../../data/culinary_contribution_api.dart';
import '../../explore_router.dart';
import '../providers/cuisine_providers.dart';

/// #281: tambah foto ke kuliner published (mirror wisata PlaceContributeMode.photo).
class CuisineAddPhotoPage extends ConsumerStatefulWidget {
  const CuisineAddPhotoPage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<CuisineAddPhotoPage> createState() =>
      _CuisineAddPhotoPageState();
}

class _CuisineAddPhotoPageState extends ConsumerState<CuisineAddPhotoPage> {
  static const _ccBySa = 'CC BY-SA 4.0';
  static const _maxImages = 5;

  List<AttachmentImageSlot> _images = const [];
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context);
    if (_images.any((s) => s.uploading)) {
      showFToast(
        context: context,
        title: Text(l10n.usahaFormWaitUpload),
      );
      return;
    }
    if (_images.any((s) => s.error)) {
      showFToast(
        context: context,
        title: Text(l10n.usahaFormRemoveFailedPhoto),
        variant: FToastVariant.destructive,
      );
      return;
    }
    final urls = [
      for (final s in _images)
        if (s.isReady && s.uploaded != null) s.uploaded!.url,
    ];
    if (urls.isEmpty) {
      await showAppErrorSheet(
        context,
        title: l10n.usahaFormIncompleteTitle,
        message: l10n.cuisineAddPhotoRequired,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(culinaryContributionApiProvider)
          .appendImages(widget.slug, urls);
      ref.invalidate(cuisineBySlugProvider(widget.slug));
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.cuisineAddPhotoSentTitle,
        message: l10n.cuisineAddPhotoSentBody,
      );
      if (!mounted) return;
      context.canPop()
          ? context.pop()
          : context.go(ExploreRouter.cuisineDetailPath(widget.slug));
    } on CulinaryException catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        title: l10n.exploreEditFailed,
        message: e.message,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = ref.watch(authStatusProvider);
    final loggedIn = auth.value?.isAuth == true;
    final showForm = !auth.isLoading && loggedIn;

    return FScaffold(
      childPad: true,
      resizeToAvoidBottomInset: true,
      header: FHeader.nested(
        title: Text(l10n.cuisineActionAddPhoto),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(ExploreRouter.cuisineDetailPath(widget.slug)),
          ),
        ],
      ),
      footer: !showForm
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: FButton(
                  onPress: _busy || _images.isEmpty ? null : _submit,
                  prefix: _busy ? const FCircularProgress() : null,
                  child: Text(
                    _busy ? l10n.placeFormSending : l10n.placeFormSubmitPhoto,
                  ),
                ),
              ),
            ),
      child: auth.isLoading
          ? const Center(child: FCircularProgress())
          : !loggedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.placeAddPhotoLoginGate,
                      textAlign: TextAlign.center,
                    ),
                    const Gap(16),
                    FButton(
                      onPress: () => context.push(AuthRouter.login.path),
                      child: Text(l10n.voteDeckLoginCta),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              children: [
                Text(l10n.cuisineAddPhotoIntro),
                const Gap(16),
                AttachmentImagesField(
                  enabled: !_busy,
                  maxImages: _maxImages,
                  maxSizeMb: 5,
                  images: _images,
                  onChanged: (next) => setState(() => _images = next),
                  upload: (file, {required bool isPrimary}) async {
                    try {
                      final url = await ref
                          .read(culinaryContributionApiProvider)
                          .uploadImage(file);
                      return Either.right(
                        AttachmentUploadedImage(
                          url: url,
                          providerFileId: url,
                          isPrimary: isPrimary,
                        ),
                      );
                    } on CulinaryException catch (e) {
                      return Either.left(
                        AttachmentUploadFailure(
                          e.message,
                          errorCode: e.code,
                        ),
                      );
                    }
                  },
                ),
                if (_images.isNotEmpty) ...[
                  const Gap(8),
                  Text(l10n.culinaryFormPhotoAttribution(_ccBySa)),
                ],
              ],
            ),
    );
  }
}
