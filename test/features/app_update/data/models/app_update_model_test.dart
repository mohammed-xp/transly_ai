import 'package:flutter_test/flutter_test.dart';
import 'package:transly_ai/features/app_update/data/models/app_update_model.dart';

void main() {
  AppUpdateModel modelWithNotes(String? notes) => AppUpdateModel(
    installedVersion: '2.1.0',
    latestVersion: '2.4.0',
    isRequired: false,
    releaseNotes: notes,
  );

  test('toEntity copies the versions and the required flag', () {
    const model = AppUpdateModel(
      installedVersion: '2.1.0',
      latestVersion: '2.4.0',
      isRequired: true,
    );

    final entity = model.toEntity();

    expect(entity.installedVersion, '2.1.0');
    expect(entity.latestVersion, '2.4.0');
    expect(entity.isRequired, isTrue);
  });

  test('null release notes become an empty list', () {
    expect(modelWithNotes(null).toEntity().releaseNotes, isEmpty);
  });

  test('whitespace-only release notes become an empty list', () {
    expect(modelWithNotes('  \n \r\n\t').toEntity().releaseNotes, isEmpty);
  });

  test('release notes split on LF and CRLF, trimmed', () {
    final notes = modelWithNotes(
      ' Faster voice \r\nNew tone\n Bug fixes ',
    ).toEntity().releaseNotes;

    expect(notes, ['Faster voice', 'New tone', 'Bug fixes']);
  });

  test('leading bullets are stripped from each note', () {
    final notes = modelWithNotes(
      '- Dash\n• Dot\n* Star\n·Middle dot',
    ).toEntity().releaseNotes;

    expect(notes, ['Dash', 'Dot', 'Star', 'Middle dot']);
  });

  test('blank lines and bare bullets between notes are dropped', () {
    final notes = modelWithNotes(
      'First\n\n-\n   \nSecond',
    ).toEntity().releaseNotes;

    expect(notes, ['First', 'Second']);
  });
}
