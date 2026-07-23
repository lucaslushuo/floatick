import 'dart:convert';
import 'dart:io';

import 'package:floatick/features/settings/data/settings_repository.dart';
import 'package:floatick/features/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late LocalSettingsRepository repository;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'floatick-settings-repository-test-',
    );
    repository = LocalSettingsRepository(
      rootDirectory: Directory('${temporaryDirectory.path}/.floatick'),
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('missing storage creates the directory and uses system theme', () async {
    final settings = await repository.load();

    expect(settings, const AppSettings());
    expect(settings.themePreference, AppThemePreference.system);
    expect(await repository.rootDirectory.exists(), isTrue);
  });

  test('save and load preserve the versioned settings schema', () async {
    const settings = AppSettings(themePreference: AppThemePreference.light);

    await repository.save(settings);
    final loadedSettings = await repository.load();
    final json = jsonDecode(await File(repository.storagePath).readAsString());

    expect(loadedSettings, settings);
    expect(json, <String, Object?>{'version': 1, 'theme': 'light'});
  });

  test('damaged storage is reported and left unchanged', () async {
    await repository.rootDirectory.create(recursive: true);
    final file = File(repository.storagePath);
    const damagedContent = '{"version": 1, "theme": "sepia"}';
    await file.writeAsString(damagedContent);

    await expectLater(
      repository.load(),
      throwsA(
        isA<SettingsStorageException>().having(
          (error) => error.message,
          'message',
          contains('damaged'),
        ),
      ),
    );
    expect(await file.readAsString(), damagedContent);
  });

  test('legacy settings move to the Floatick directory', () async {
    final legacyDirectory = Directory('${temporaryDirectory.path}/.flow2do');
    final destinationDirectory = Directory(
      '${temporaryDirectory.path}/.floatick',
    );
    final legacyFile = File('${legacyDirectory.path}/settings.json');
    await legacyDirectory.create(recursive: true);
    await legacyFile.writeAsString(
      jsonEncode(<String, Object?>{'version': 1, 'theme': 'dark'}),
    );
    repository = LocalSettingsRepository(
      rootDirectory: destinationDirectory,
      legacyRootDirectory: legacyDirectory,
    );

    final settings = await repository.load();

    expect(settings.themePreference, AppThemePreference.dark);
    expect(
      repository.storagePath,
      '${destinationDirectory.path}/settings.json',
    );
    expect(await File(repository.storagePath).exists(), isTrue);
    expect(await legacyFile.exists(), isFalse);
  });
}
