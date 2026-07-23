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

class AppSettings {
  const AppSettings({this.themePreference = AppThemePreference.system});

  final AppThemePreference themePreference;

  AppSettings copyWith({AppThemePreference? themePreference}) {
    return AppSettings(
      themePreference: themePreference ?? this.themePreference,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    final rawTheme = json['theme'];
    if (rawTheme == null) {
      return const AppSettings();
    }
    if (rawTheme is! String) {
      throw const FormatException('Settings theme must be a string.');
    }
    return AppSettings(
      themePreference: AppThemePreference.fromStorageValue(rawTheme),
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'version': 1,
      'theme': themePreference.storageValue,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettings && themePreference == other.themePreference;
  }

  @override
  int get hashCode => themePreference.hashCode;
}
