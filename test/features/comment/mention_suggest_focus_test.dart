import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sambasku_mobile/features/comment/presentation/widgets/mention_suggest_overlay.dart';
import 'package:sambasku_mobile/features/comment/presentation/providers/mention_suggest_providers.dart';
import 'package:sambasku_mobile/features/user_profile/domain/entities/public_profile.dart';
import 'package:sambasku_mobile/features/user_profile/domain/failures/user_profile_failure.dart';
import 'package:sambasku_mobile/features/user_profile/domain/providers/user_profile_domain_providers.dart';
import 'package:sambasku_mobile/features/user_profile/domain/usecases/suggest_mentions_use_case.dart';

/// #129: overlay saran mention tampil di atas kolom komentar, tapi TIDAK
/// boleh mencuri fokus dari TextField - kalau curi, ketikan lanjutan user
/// nyasar / keyboard nutup dan mention gagal.
void main() {
  testWidgets('#129 overlay tidak mencuri fokus kolom komentar', (tester) async {
    final container = ProviderContainer(
      overrides: [
        suggestMentionsUseCaseProvider.overrideWith((ref) => _FakeSuggest()),
      ],
    );
    addTearDown(container.dispose);

    final controller = TextEditingController();
    addTearDown(controller.dispose);
    // Wiring sama dengan pemilik composer (word_comments_section /
    // discussion_detail_page).
    controller.addListener(
      () => container.read(mentionSuggestControllerProvider.notifier).onTextChanged(
            controller.text,
            controller.selection.baseOffset,
          ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MentionSuggestOverlay(
                  onSelect: (username) => insertIntoComposer(controller, username),
                ),
                TextField(controller: controller, autofocus: true),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(); // TextField ambil fokus (autofocus).

    // Ketik @bu → debounce 300ms → fetch fake → overlay tampil.
    await tester.enterText(find.byType(TextField), '@bu');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('@budi'), findsOneWidget, reason: 'overlay saran tampil');

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(
      editable.focusNode.hasFocus,
      isTrue,
      reason: '#129: overlay tidak boleh mencuri fokus - kalau curi, '
          'ketikan user setelah saran muncul nyasar dan mention gagal',
    );
  });
}

class _FakeSuggest implements SuggestMentionsUseCase {
  @override
  Future<Either<UserProfileFailure, List<MentionSuggestion>>> call(String query) async =>
      Either.right(const [
        MentionSuggestion(id: '1', username: 'budi', displayName: 'Budi'),
      ]);
}
