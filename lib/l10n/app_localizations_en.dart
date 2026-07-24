// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get applicationTitle => 'Floatick';

  @override
  String get openApp => 'Open Floatick';

  @override
  String get openAppHint => 'Drag to reposition; click to open the todo list';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSectionTitle => 'Appearance';

  @override
  String get languageSectionTitle => 'Language';

  @override
  String get languageSystemTooltip => 'Follow system';

  @override
  String get languageSimplifiedChineseTooltip => 'Simplified Chinese';

  @override
  String get languageEnglishTooltip => 'English';

  @override
  String get updatesSectionTitle => 'Updates';

  @override
  String currentVersionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get automaticUpdateChecksLabel => 'Automatically check for updates';

  @override
  String get automaticUpdateChecksDescription =>
      'Checks daily and asks before installing';

  @override
  String get checkForUpdatesButton => 'Check for updates';

  @override
  String get checkingForUpdatesButton => 'Checking…';

  @override
  String get updateSettingsLoadError => 'Update settings are unavailable.';

  @override
  String get updateSettingsSaveError => 'Couldn\'t change update settings.';

  @override
  String get updateCheckError => 'Couldn\'t check for updates.';

  @override
  String get workingDirectorySectionTitle => 'Working directory';

  @override
  String workingDirectorySemantics(String path) {
    return 'Working directory: $path';
  }

  @override
  String get closeSettingsTooltip => 'Close settings';

  @override
  String get themeSystemTooltip => 'Follow system';

  @override
  String get themeLightTooltip => 'Light theme';

  @override
  String get themeDarkTooltip => 'Dark theme';

  @override
  String get searchTodosHint => 'Search todos';

  @override
  String get searchArchiveHint => 'Search archive';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get addTodoHint => 'Add something to do…';

  @override
  String get allClearToday => 'All clear for today';

  @override
  String activeTodoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks remaining',
      one: '1 task remaining',
    );
    return '$_temp0';
  }

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get collapseTooltip => 'Collapse (Esc)';

  @override
  String get activeScopeLabel => 'Todos';

  @override
  String get archiveScopeLabel => 'Archive';

  @override
  String get addTodoSemanticsLabel => 'Add todo';

  @override
  String get addTodoTooltip => 'Add todo (Return)';

  @override
  String get dismissErrorTooltip => 'Dismiss error';

  @override
  String get completedStatus => 'Completed';

  @override
  String get incompleteStatus => 'Incomplete';

  @override
  String get markIncompleteTooltip => 'Mark incomplete';

  @override
  String get markCompleteTooltip => 'Mark complete';

  @override
  String get todoTitleRequiredHint => 'Todo title cannot be empty';

  @override
  String get saveTooltip => 'Save';

  @override
  String get editTooltip => 'Edit';

  @override
  String get cancelEditTooltip => 'Cancel editing';

  @override
  String get restoreTooltip => 'Restore to todos';

  @override
  String get archiveTooltip => 'Archive';

  @override
  String get noSearchResultsTitle => 'No matching results';

  @override
  String get emptyArchiveTitle => 'Archive is empty';

  @override
  String get emptyTodosTitle => 'Nothing to do—enjoy the moment';

  @override
  String get noSearchResultsMessage => 'Try another keyword';

  @override
  String get emptyArchiveMessage => 'Archived items will appear here';

  @override
  String get emptyTodosMessage => 'Add a new item above whenever you like';

  @override
  String get todayLabel => 'Today';

  @override
  String get yesterdayLabel => 'Yesterday';

  @override
  String get storageInvalidDataError =>
      'The local data file is damaged and was left unchanged.';

  @override
  String storageReadError(String path) {
    return 'Floatick couldn\'t read $path.';
  }

  @override
  String storageWriteError(String path) {
    return 'Floatick couldn\'t save to $path.';
  }

  @override
  String get storageHomeError =>
      'Floatick couldn\'t resolve your macOS home directory.';
}
