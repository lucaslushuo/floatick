import 'package:flutter/foundation.dart';

import '../data/settings_repository.dart';
import '../domain/app_settings.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel({required SettingsRepository settingsRepository})
    : _repository = settingsRepository;

  final SettingsRepository _repository;

  AppSettings _settings = const AppSettings();
  String? _errorMessage;
  bool _isLoading = false;
  bool _isSaving = false;

  AppSettings get settings => _settings;
  AppThemePreference get themePreference => _settings.themePreference;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get storagePath => _repository.storagePath;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _settings = await _repository.load();
    } on SettingsStorageException catch (error) {
      _settings = const AppSettings();
      _errorMessage = error.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    if (_isSaving || preference == _settings.themePreference) {
      return;
    }

    final previousSettings = _settings;
    _settings = _settings.copyWith(themePreference: preference);
    _errorMessage = null;
    _isSaving = true;
    notifyListeners();

    try {
      await _repository.save(_settings);
    } on SettingsStorageException catch (error) {
      _settings = previousSettings;
      _errorMessage = error.message;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void dismissError() {
    if (_errorMessage == null) {
      return;
    }
    _errorMessage = null;
    notifyListeners();
  }
}
