enum AppThemePreference {
  system('system'),
  light('light'),
  dark('dark');

  const AppThemePreference(this.storageValue);

  final String storageValue;

  static AppThemePreference fromStorageValue(String value) {
    return values.firstWhere(
      (preference) => preference.storageValue == value,
      orElse: () {
        throw FormatException('Unknown theme preference: $value');
      },
    );
  }
}

enum AppLanguagePreference {
  system('system'),
  simplifiedChinese('zh'),
  english('en');

  const AppLanguagePreference(this.storageValue);

  final String storageValue;

  static AppLanguagePreference fromStorageValue(String value) {
    return values.firstWhere(
      (preference) => preference.storageValue == value,
      orElse: () {
        throw FormatException('Unknown language preference: $value');
      },
    );
  }
}

class AppSettings {
  const AppSettings({
    this.themePreference = AppThemePreference.system,
    this.languagePreference = AppLanguagePreference.system,
  });

  final AppThemePreference themePreference;
  final AppLanguagePreference languagePreference;

  AppSettings copyWith({
    AppThemePreference? themePreference,
    AppLanguagePreference? languagePreference,
  }) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
      languagePreference: languagePreference ?? this.languagePreference,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawTheme = json['theme'];
    if (rawTheme != null && rawTheme is! String) {
      throw const FormatException('Settings theme must be a string.');
    }

    final rawLanguage = json['language'];
    if (rawLanguage != null && rawLanguage is! String) {
      throw const FormatException('Settings language must be a string.');
    }

    return AppSettings(
      themePreference: rawTheme == null
          ? AppThemePreference.system
          : AppThemePreference.fromStorageValue(rawTheme),
      languagePreference: rawLanguage == null
          ? AppLanguagePreference.system
          : AppLanguagePreference.fromStorageValue(rawLanguage),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': 2,
      'theme': themePreference.storageValue,
      'language': languagePreference.storageValue,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings &&
        themePreference == other.themePreference &&
        languagePreference == other.languagePreference;
  }

  @override
  int get hashCode => Object.hash(themePreference, languagePreference);
}
