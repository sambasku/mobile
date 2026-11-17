import 'dart:io';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/attachment_images_field.dart';
import '../../data/datasources/event_remote_datasource.dart';
import '../../domain/entities/event_contribution.dart';
import '../../event_router.dart';

/// Halaman upload foto galeri acara (login).
/// Pola: AttachmentImagesField + submit URL ke API.
/// Max: 4 foto per kiriman, 5 per hari per user.
class EventPhotosAddPage extends ConsumerStatefulWidget {
  const EventPhotosAddPage({super.key, required this.slug});

  final String slug;

  @override
  ConsumerState<EventPhotosAddPage> createState() => _EventPhotosAddPageState();
}

class _EventPhotosAddPageState extends ConsumerState<EventPhotosAddPage> {
  var _images = <AttachmentImageSlot>[];
  bool _submitting = false;

  static const _maxPerBatch = 4;

  EventImageUploadApi get _api =>
      EventImageUploadApi(ref.read(dioProvider));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canSubmit =
        _images.any((s) => s.isReady) &&
        _images.every((s) => s.isReady || s.localPath.isEmpty) &&
        !_submitting;

    return FScaffold(
      header: FHeader.nested(
        title: Text(l10n.eventPhotosAddTitle),
        prefixes: [
          FHeaderAction.back(
            onPress: () => context.canPop() ? context.pop() : context.go('/acara'),
          ),
        ],
      ),
      footer: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: FButton(
            onPress: canSubmit ? _submit : null,
            prefix: _submitting
                ? const FCircularProgress(size: .sm)
                : null,
            child: Text(
              _submitting
                  ? l10n.eventPhotosSubmitting
                  : l10n.eventPhotosSubmit,
            ),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            l10n.eventPhotosMaxInfo(_maxPerBatch),
            style: context.theme.typography.body.sm,
          ),
          const SizedBox(height: 12),
          AttachmentImagesField(
            enabled: !_submitting,
            maxImages: _maxPerBatch,
            maxSizeMb: 5,
            images: _images,
            onChanged: (next) => setState(() => _images = next),
            upload: _upload,
          ),
        ],
      ),
    );
  }

  Future<Either<AttachmentUploadFailure, AttachmentUploadedImage>> _upload(
    File file, {
    required bool isPrimary,
  }) async {
    // l10n diambil sebelum await (hindari BuildContext across async gap).
    final l10n = AppLocalizations.of(context);
    try {
      final url = await _api.uploadImage(file);
      return Either.right(AttachmentUploadedImage(
        url: url,
        providerFileId: url.split('/').last,
      ));
    } catch (e) {
      return Either.left(AttachmentUploadFailure(
        e is EventContributionException
            ? e.message
            : l10n.eventPhotoUploadFailed,
      ));
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final urls = [
        for (final s in _images)
          if (s.isReady) s.uploaded!.url,
      ];
      if (urls.isEmpty) return;
      await _api.append(widget.slug, urls);
      if (!mounted) return;
      showFToast(
        context: context,
        title: Text(AppLocalizations.of(context).eventPhotosSuccess),
      );
      context.go(EventRouter.photosPath(widget.slug));
    } catch (e) {
      if (!mounted) return;
      final msg = e is EventContributionException
          ? e.message
          : AppLocalizations.of(context).eventSaveFailed;
      showFToast(
        context: context,
        title: Text(msg),
        variant: FToastVariant.destructive,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
