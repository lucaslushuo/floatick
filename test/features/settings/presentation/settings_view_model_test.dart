import 'dart:async';

import 'package:floatick/features/settings/data/settings_repository.dart';
import 'package:floatick/features/settings/domain/app_settings.dart';
import 'package:floatick/features/settings/presentation/settings_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late _MemorySettingsRepository repository;
  late SettingsViewModel controller;

  setUp(() {
    repository = _MemorySettingsRepository();
    controller = SettingsViewModel(settingsRepository: repository);
  });

  test('load exposes the persisted theme preference', () async {
    repository.savedSettings = const AppSettings(
      themePreference: AppThemePreference.dark,
    );

    await controller.load();

    expect(controller.themePreference, AppThemePreference.dark);
    expect(controller.errorMessage, isNull);
  });

  test('theme changes immediately and persists the new preference', () async {
    await controller.load();
    final saveCompleter = Completer<void>();
    repository.pendingSave = saveCompleter;

    final operation = controller.setThemePreference(AppThemePreference.light);

    expect(controller.themePreference, AppThemePreference.light);
    expect(controller.isSaving, isTrue);

    saveCompleter.complete();
    await operation;

    expect(repository.savedSettings.themePreference, AppThemePreference.light);
    expect(controller.isSaving, isFalse);
    expect(controller.errorMessage, isNull);
  });

  test('a failed save rolls the visible preference back', () async {
    repository.savedSettings = const AppSettings(
      themePreference: AppThemePreference.dark,
    );
    await controller.load();
    repository.failNextSave = true;

    await controller.setThemePreference(AppThemePreference.light);

    expect(controller.themePreference, AppThemePreference.dark);
    expect(controller.errorMessage, contains('test settings save failure'));
    expect(controller.isSaving, isFalse);
  });
}

class _MemorySettingsRepository implements SettingsRepository {
  AppSettings savedSettings = const AppSettings();
  Completer<void>? pendingSave;
  bool failNextSave = false;

  @override
  String get storagePath => '/tmp/floatick-settings-test/settings.json';

  @override
  Future<AppSettings> load() async => savedSettings;

  @override
  Future<void> save(AppSettings settings) async {
    if (failNextSave) {
      failNextSave = false;
      throw const SettingsStorageException('test settings save failure');
    }
    final pendingSave = this.pendingSave;
    if (pendingSave != null) {
      await pendingSave.future;
      this.pendingSave = null;
    }
    savedSettings = settings;
  }
}
