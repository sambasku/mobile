import 'package:flutter_test/flutter_test.dart';
import 'package:sambasku_mobile/features/about/data/datasources/about_api_datasource.dart';

void main() {
  test('parseTeamNoteLines max 5 baris', () {
    final lines = parseTeamNoteLines('a\n\nb\nc\nd\ne\nf');
    expect(lines, ['a', 'b', 'c', 'd', 'e']);
  });

  test('AboutTeamMember.teamNoteLines', () {
    const m = AboutTeamMember(
      username: 'u',
      displayName: 'U',
      teamNote: 'satu\ndua',
    );
    expect(m.teamNoteLines, ['satu', 'dua']);
  });
}