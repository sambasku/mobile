import 'dart:async';

import 'package:forui/forui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/utils/error_bottom_sheet.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../../../shared/widgets/option_picker_sheet.dart';
import '../../../explore/domain/entities/region.dart';
import '../../../explore/presentation/pages/place_pin_picker_page.dart';
import '../../../explore/presentation/providers/regions_providers.dart';
import '../../domain/entities/usaha.dart';
import '../../usaha_router.dart';
import '../providers/usaha_providers.dart';
import '../usaha_labels.dart';

enum UsahaContributeMode { create, edit }

/// Form usulan usaha baru ATAU usulan perubahan (prefill).
/// Create: boleh anonim. Edit: wajib login, data dari detail.
class UsahaContributePage extends ConsumerStatefulWidget {
  const UsahaContributePage({
    super.key,
    this.mode = UsahaContributeMode.create,
    this.slug,
  });

  final UsahaContributeMode mode;
  final String? slug;

  @override
  ConsumerState<UsahaContributePage> createState() =>
      _UsahaContributePageState();
}

class _UsahaContributePageState extends ConsumerState<UsahaContributePage> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _website = TextEditingController();
  final _social = TextEditingController();

  String? _categoryId;
  String? _categoryName;
  UsahaKind _kind = UsahaKind.product;
  Region? _kecamatan;
  Region? _desa;
  LatLng? _point;
  List<AttachmentImageSlot> _cover = const [];
  bool _wantsClaim = false;
  bool _submitting = false;
  bool _prefilled = false;
  /// Snapshot field awal (mode edit) untuk deteksi `fields` yang berubah.
  Map<String, String?> _baseline = const {};

  bool get _isEdit => widget.mode == UsahaContributeMode.edit;

  @override
  void initState() {
    super.initState();
    unawaited(AnalyticsService.instance.logUsahaContributeOpen());
  }

  void _applyUsaha(Usaha usaha) {
    if (_prefilled) return;
    _prefilled = true;
    _name.text = usaha.name;
    _description.text = usaha.description ?? '';
    _address.text = usaha.addressText ?? '';
    _phone.text = usaha.phone ?? usaha.whatsapp ?? '';
    _website.text = usaha.website ?? '';
    _social.text = usaha.socialUrl ?? '';
    _categoryId = usaha.categoryId ?? usaha.category?.id;
    _categoryName = usaha.category?.name;
    _kind = usaha.kind;
    if (usaha.hasCoordinates) {
      _point = LatLng(usaha.lat!, usaha.lng!);
    }
    if (usaha.coverUrl != null && usaha.coverUrl!.trim().isNotEmpty) {
      _cover = [
        AttachmentImageSlot(
          id: 'cover-existing',
          localPath: '',
          uploaded: AttachmentUploadedImage(
            url: usaha.coverUrl!,
            providerFileId: usaha.coverUrl!,
            isPrimary: true,
          ),
        ),
      ];
    }
    _baseline = {
      'name': _name.text.trim(),
      'description': _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      'categoryId': _categoryId,
      'kind': _kind.name,
      'addressText': _address.text.trim().isEmpty ? null : _address.text.trim(),
      'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      'website': _website.text.trim().isEmpty ? null : _website.text.trim(),
      'socialUrl': _social.text.trim().isEmpty ? null : _social.text.trim(),
      'coverUrl': usaha.coverUrl,
      'regionId': usaha.regionId,
      'villageId': usaha.villageId,
      'lat': usaha.lat?.toString(),
      'lng': usaha.lng?.toString(),
    };
  }

  Future<void> _resolveRegionsForEdit(Usaha usaha) async {
    final regionsAsync = await ref.read(regionsProvider.future);
    final regions = regionsAsync ?? const <Region>[];
    if (!mounted) return;
    Region? kec;
    for (final r in regions.where((r) => r.type == RegionType.kecamatan)) {
      if (r.id == usaha.regionId) {
        kec = r;
        break;
      }
    }
    Region? desa;
    if (kec != null && usaha.villageId != null) {
      for (final v in regions.where(
        (r) => r.type == RegionType.desa && r.parentId == kec!.id,
      )) {
        if (v.id == usaha.villageId) {
          desa = v;
          break;
        }
      }
    }
    setState(() {
      _kecamatan = kec;
      _desa = desa;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _address.dispose();
    _phone.dispose();
    _website.dispose();
    _social.dispose();
    super.dispose();
  }

  void _warn(String message) {
    showAppErrorSheet(
      context,
      title: AppLocalizations.of(context).usahaFormIncompleteTitle,
      message: message,
    );
  }

  Future<void> _pickCategory() async {
    // Tunggu kategori selesai load (ref.read(.value) bisa null kalau
    // provider belum resolve - list jadi kosong padahal data ada).
    final l10n = AppLocalizations.of(context);
    final categories = await ref.read(usahaCategoriesProvider.future);
    if (!mounted) return;
    final picked = await showOptionPickerSheet<UsahaCategoryRef>(
      context,
      title: l10n.usahaFormPickCategory,
      icon: FLucideIcons.tags,
      searchable: true,
      searchHint: l10n.usahaFormSearchCategory,
      items: [
        for (final c in categories)
          OptionPickerItem(
            value: c,
            label: c.name,
            selected: c.id == _categoryId,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() {
      _categoryId = picked.id;
      _categoryName = picked.name;
    });
  }

  Future<void> _pickKind() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showOptionPickerSheet<UsahaKind>(
      context,
      title: l10n.usahaFormKind,
      icon: FLucideIcons.store,
      items: [
        for (final kind in UsahaKind.values)
          OptionPickerItem(
            value: kind,
            label: usahaKindLabel(l10n, kind),
            selected: kind == _kind,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() => _kind = picked);
  }

  Future<void> _pickKecamatan() async {
    // Tunggu regions selesai load (ref.read(.value) bisa null kalau belum
    // pernah buka explore - list jadi kosong padahal data ada).
    final l10n = AppLocalizations.of(context);
    final regionsAsync = await ref.read(regionsProvider.future);
    final regions = regionsAsync ?? const <Region>[];
    if (!mounted) return;
    final picked = await showOptionPickerSheet<Region>(
      context,
      title: l10n.usahaFormPickDistrict,
      icon: FLucideIcons.mapPin,
      searchable: true,
      searchHint: l10n.usahaFormSearchDistrict,
      items: [
        for (final r in regions.where((r) => r.type == RegionType.kecamatan))
          OptionPickerItem(
            value: r,
            label: r.name,
            selected: r.id == _kecamatan?.id,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() {
      _kecamatan = picked;
      _desa = null;
    });
  }

  Future<void> _pickDesa() async {
    final l10n = AppLocalizations.of(context);
    final kecamatan = _kecamatan;
    if (kecamatan == null) {
      _warn(l10n.usahaFormDistrictRequired);
      return;
    }
    // Tunggu regions selesai load (ref.read(.value) bisa null kalau belum
    // pernah buka explore - list jadi kosong padahal data ada).
    final regionsAsync = await ref.read(regionsProvider.future);
    final regions = regionsAsync ?? const <Region>[];
    if (!mounted) return;
    final picked = await showOptionPickerSheet<Region>(
      context,
      title: l10n.usahaFormPickVillage,
      icon: FLucideIcons.mapPin,
      searchable: true,
      searchHint: l10n.usahaFormSearchVillage,
      items: [
        for (final r in regions.where(
          (r) => r.type == RegionType.desa && r.parentId == kecamatan.id,
        ))
          OptionPickerItem(
            value: r,
            label: r.name,
            selected: r.id == _desa?.id,
          ),
      ],
    );
    if (picked == null || !mounted) return;
    setState(() => _desa = picked);
  }

  Future<void> _openMap() async {
    final result = await Navigator.of(context, rootNavigator: true)
        .push<PlacePinPick>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => PlacePinPickerPage(initial: _point),
          ),
        );
    if (result == null || !mounted) return;
    setState(() => _point = result.point);
  }

  List<String> _changedFields({
    required String name,
    required String? description,
    required String? categoryId,
    required UsahaKind kind,
    required String? regionId,
    required String? villageId,
    required String? addressText,
    required double? lat,
    required double? lng,
    required String? phone,
    required String? website,
    required String? socialUrl,
    required String? coverUrl,
  }) {
    String? norm(String? v) {
      final t = v?.trim();
      return (t == null || t.isEmpty) ? null : t;
    }

    final current = <String, String?>{
      'name': name,
      'description': norm(description),
      'categoryId': categoryId,
      'kind': kind.name,
      'regionId': regionId,
      'villageId': villageId,
      'addressText': norm(addressText),
      'lat': lat?.toString(),
      'lng': lng?.toString(),
      'phone': norm(phone),
      'whatsapp': norm(phone),
      'website': norm(website),
      'socialUrl': norm(socialUrl),
      'coverUrl': coverUrl,
    };
    final changed = <String>[];
    for (final entry in current.entries) {
      if (_baseline[entry.key] != entry.value) {
        changed.add(entry.key);
      }
    }
    // phone berubah -> whatsapp ikut (satu nomor di form).
    if (changed.contains('phone') && !changed.contains('whatsapp')) {
      changed.add('whatsapp');
    }
    return changed;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.length < 3) {
      _warn(l10n.usahaFormNameTooShort);
      return;
    }
    final kecamatan = _kecamatan;
    if (kecamatan == null) {
      _warn(l10n.usahaFormDistrictMissing);
      return;
    }
    // Foto utama diunggah segera oleh AttachmentImagesField; guard supaya
    // cover yang masih upload/gagal tidak didrop diam-diam saat submit.
    if (_cover.any((s) => s.uploading)) {
      showFToast(context: context, title: Text(l10n.usahaFormWaitUpload));
      return;
    }
    if (_cover.any((s) => s.error)) {
      showFToast(
        context: context,
        title: Text(l10n.usahaFormRemoveFailedPhoto),
        variant: FToastVariant.destructive,
      );
      return;
    }
    setState(() => _submitting = true);
    final api = ref.read(usahaContributionApiProvider);
    // Submit hanya memakai URL hasil upload (upload-then-submit).
    final coverUrl = _cover.isNotEmpty && _cover.first.isReady
        ? _cover.first.uploaded?.url
        : null;
    final description = _description.text.trim();
    final phone = _phone.text.trim();
    final website = _website.text.trim();
    final social = _social.text.trim();
    final address = _address.text.trim();
    try {
      if (_isEdit) {
        final slug = widget.slug;
        if (slug == null || slug.isEmpty) {
          throw UsahaException(l10n.usahaSuggestEditFailed);
        }
        final fields = _changedFields(
          name: name,
          description: description,
          categoryId: _categoryId,
          kind: _kind,
          regionId: kecamatan.id,
          villageId: _desa?.id,
          addressText: address,
          lat: _point?.latitude,
          lng: _point?.longitude,
          phone: phone,
          website: website,
          socialUrl: social,
          coverUrl: coverUrl,
        );
        if (fields.isEmpty) {
          _warn(l10n.usahaFormIncompleteTitle);
          return;
        }
        await api.suggestEdit(
          slug: slug,
          body: {
            if (fields.contains('name')) 'name': name,
            if (fields.contains('description'))
              'description': description.isEmpty ? null : description,
            if (fields.contains('categoryId')) 'category_id': _categoryId,
            if (fields.contains('kind')) 'kind': _kind.name,
            if (fields.contains('regionId')) 'region_id': kecamatan.id,
            if (fields.contains('villageId')) 'village_id': _desa?.id,
            if (fields.contains('addressText'))
              'address_text': address.isEmpty ? null : address,
            if (fields.contains('lat')) 'lat': _point?.latitude,
            if (fields.contains('lng')) 'lng': _point?.longitude,
            if (fields.contains('phone'))
              'phone': phone.isEmpty ? null : phone,
            if (fields.contains('whatsapp'))
              'whatsapp': phone.isEmpty ? null : phone,
            if (fields.contains('website'))
              'website': website.isEmpty ? null : website,
            if (fields.contains('socialUrl'))
              'social_url': social.isEmpty ? null : social,
            if (fields.contains('coverUrl')) 'cover_url': coverUrl,
            'fields': fields,
          },
        );
      } else {
        await api.submit(
          UsahaContributionDraft(
            name: name,
            regionId: kecamatan.id,
            description: description,
            categoryId: _categoryId,
            kind: _kind,
            villageId: _desa?.id,
            addressText: address,
            lat: _point?.latitude,
            lng: _point?.longitude,
            phone: phone,
            website: website,
            socialUrl: social,
            coverUrl: coverUrl,
            wantsClaim: _wantsClaim,
          ),
        );
      }
      unawaited(AnalyticsService.instance.logUsahaContributeSubmit());
      if (!mounted) return;
      final goProposals = await showModalBottomSheet<bool>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (ctx) => SafeArea(
          top: false,
          child: FTileGroup(
            children: [
              FTile(
                title: Text(
                  _isEdit ? l10n.usahaSuggestEditSent : l10n.usahaProposalSent,
                ),
                subtitle: Text(
                  _isEdit
                      ? l10n.usahaSuggestEditSentBody
                      : l10n.usahaProposalSentBody,
                ),
              ),
              FTile(
                title: Text(l10n.usahaSeeProposals),
                onPress: () => Navigator.pop(ctx, true),
              ),
              FTile(
                title: Text(l10n.usahaBackToList),
                onPress: () => Navigator.pop(ctx, false),
              ),
            ],
          ),
        ),
      );
      if (!mounted) return;
      if (goProposals == true) {
        context.pushReplacement(UsahaRouter.proposals.path);
      } else if (_isEdit && widget.slug != null) {
        context.go(UsahaRouter.detailPath(widget.slug!));
      } else {
        context.go(UsahaRouter.list.path);
      }
    } on UsahaException catch (e) {
      if (!mounted) return;
      await showAppErrorSheet(
        context,
        message: e.message,
        title: _isEdit ? l10n.usahaSuggestEditFailed : l10n.usahaProposalFailed,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;

    if (_isEdit) {
      final slug = widget.slug ?? '';
      final usahaAsync = ref.watch(usahaBySlugProvider(slug));
      usahaAsync.whenData((usaha) {
        if (usaha == null || _prefilled) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _prefilled) return;
          _applyUsaha(usaha);
          unawaited(_resolveRegionsForEdit(usaha));
          setState(() {});
        });
      });
    }

    final title = _isEdit
        ? l10n.usahaSuggestEditTitle
        : l10n.usahaContributeAction;
    final intro = _isEdit ? l10n.usahaSuggestEditIntro : l10n.usahaFormIntro;
    final ctaBusy = _isEdit
        ? l10n.usahaSuggestEditSubmitting
        : l10n.placeFormSending;
    final ctaIdle = _isEdit
        ? l10n.usahaSuggestEditSubmit
        : l10n.usahaSubmitProposal;

    return FScaffold(
      childPad: true,
      header: FHeader.nested(
        title: Text(title),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop()
                ? context.pop()
                : context.go(UsahaRouter.list.path),
          ),
        ],
      ),
      // CTA sticky: pola lemma (spinner di prefix, label tetap di child).
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: _submitting ? null : _submit,
            prefix: _submitting ? const FCircularProgress() : null,
            child: Text(_submitting ? ctaBusy : ctaIdle),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          Text(
            intro,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          const Gap(16),
          FTextField(
            control: FTextFieldControl.managed(controller: _name),
            label: Text(l10n.usahaFormName),
            hint: l10n.usahaFormNameHint,
            textCapitalization: TextCapitalization.words,
          ),
          const Gap(10),
          FTextField(
            control: FTextFieldControl.managed(controller: _description),
            label: Text(l10n.usahaFormDescription),
            hint: l10n.usahaFormDescriptionHint,
            maxLines: 4,
          ),
          const Gap(16),
          FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.tags, size: 18),
                title: Text(l10n.usahaFormCategory),
                subtitle: Text(_categoryName ?? l10n.usahaFormNotSelected),
                onPress: _pickCategory,
              ),
              FTile(
                prefix: const Icon(FLucideIcons.store, size: 18),
                title: Text(l10n.usahaFormKindLabel),
                subtitle: Text(usahaKindLabel(l10n, _kind)),
                onPress: _pickKind,
              ),
              FTile(
                prefix: const Icon(FLucideIcons.mapPin, size: 18),
                title: Text(l10n.usahaFormDistrict),
                subtitle: Text(_kecamatan?.name ?? l10n.usahaFormRequired),
                onPress: _pickKecamatan,
              ),
              FTile(
                prefix: const Icon(FLucideIcons.signpost, size: 18),
                title: Text(l10n.usahaFormVillage),
                subtitle: Text(_desa?.name ?? l10n.usahaFormNotSelected),
                onPress: _pickDesa,
              ),
            ],
          ),
          const Gap(10),
          FTextField(
            control: FTextFieldControl.managed(controller: _address),
            label: Text(l10n.usahaFormAddress),
            hint: l10n.usahaFormAddressHint,
            maxLines: 2,
          ),
          const Gap(10),
          FTileGroup(
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.mapPinned, size: 18),
                title: Text(l10n.usahaFormMapPin),
                subtitle: Text(
                  _point == null
                      ? l10n.usahaFormMapPinHint
                      : '${_point!.latitude.toStringAsFixed(5)}, ${_point!.longitude.toStringAsFixed(5)}',
                ),
                onPress: _openMap,
              ),
            ],
          ),
          const Gap(16),
          Text(
            l10n.usahaFormContactSection,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(8),
          // Satu nomor untuk telepon + WhatsApp; backend mengisi whatsapp
          // dari phone (lihat toNewPayload di usaha-contribution.controller).
          FTextField(
            control: FTextFieldControl.managed(controller: _phone),
            label: Text(l10n.usahaFormPhone),
            hint: '0812xxxxxxx',
            keyboardType: TextInputType.phone,
          ),
          const Gap(10),
          FTextField(
            control: FTextFieldControl.managed(controller: _website),
            label: Text(l10n.usahaFormWebsite),
            hint: 'https://...',
            keyboardType: TextInputType.url,
          ),
          const Gap(10),
          FTextField(
            control: FTextFieldControl.managed(controller: _social),
            label: Text(l10n.usahaFormSocial),
            hint: 'https://instagram.com/...',
            keyboardType: TextInputType.url,
          ),
          if (!_isEdit) ...[
            const Gap(16),
            FTileGroup(
              children: [
                FTile(
                  prefix: const Icon(FLucideIcons.keyRound, size: 18),
                  title: Text(l10n.usahaFormClaim),
                  subtitle: Text(l10n.usahaFormClaimBody),
                  suffix: FSwitch(
                    semanticsLabel: l10n.usahaFormClaim,
                    value: _wantsClaim,
                    onChange: (value) => setState(() => _wantsClaim = value),
                  ),
                ),
              ],
            ),
          ],
          const Gap(12),
          // Panel foto seragam dengan form usul kata / diskusi
          // (AttachmentImagesField kanonik: sheet kamera/galeri, upload
          // segera, thumbnail + status upload + hapus di pojok).
          AttachmentImagesField(
            enabled: !_submitting,
            maxImages: 1,
            maxSizeMb: 5,
            images: _cover,
            onChanged: (next) => setState(() => _cover = next),
            upload: (file, {required bool isPrimary}) async {
              try {
                final url = await ref
                    .read(usahaContributionApiProvider)
                    .uploadImage(file);
                return Either.right(
                  AttachmentUploadedImage(
                    url: url,
                    providerFileId: url,
                    isPrimary: true,
                  ),
                );
              } on UsahaException catch (e) {
                return Either.left(AttachmentUploadFailure(e.message));
              }
            },
          ),
        ],
      ),
    );
  }
}
