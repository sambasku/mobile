// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EditProfileNotifier)
final editProfileProvider = EditProfileNotifierProvider._();

final class EditProfileNotifierProvider
    extends $NotifierProvider<EditProfileNotifier, EditProfileState> {
  EditProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'editProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$editProfileNotifierHash();

  @$internal
  @override
  EditProfileNotifier create() => EditProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EditProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EditProfileState>(value),
    );
  }
}

String _$editProfileNotifierHash() =>
    r'efd1187b938d1b9f22126d0a91b28239573e6dac';

abstract class _$EditProfileNotifier extends $Notifier<EditProfileState> {
  EditProfileState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<EditProfileState, EditProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EditProfileState, EditProfileState>,
              EditProfileState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
