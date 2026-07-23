import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @applicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Floatick'**
  String get applicationTitle;

  /// No description provided for @openApp.
  ///
  /// In en, this message translates to:
  /// **'Open Floatick'**
  String get openApp;

  /// No description provided for @openAppHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reposition; click to open the todo list'**
  String get openAppHint;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearanceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSectionTitle;

  /// No description provided for @workingDirectorySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Working directory'**
  String get workingDirectorySectionTitle;

  /// No description provided for @workingDirectorySemantics.
  ///
  /// In en, this message translates to:
  /// **'Working directory: {path}'**
  String workingDirectorySemantics(String path);

  /// No description provided for @closeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close settings'**
  String get closeSettingsTooltip;

  /// No description provided for @themeSystemTooltip.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeSystemTooltip;

  /// No description provided for @themeLightTooltip.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get themeLightTooltip;

  /// No description provided for @themeDarkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDarkTooltip;

  /// No description provided for @searchTodosHint.
  ///
  /// In en, this message translates to:
  /// **'Search todos'**
  String get searchTodosHint;

  /// No description provided for @searchArchiveHint.
  ///
  /// In en, this message translates to:
  /// **'Search archive'**
  String get searchArchiveHint;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// No description provided for @addTodoHint.
  ///
  /// In en, this message translates to:
  /// **'Add something to do…'**
  String get addTodoHint;

  /// No description provided for @allClearToday.
  ///
  /// In en, this message translates to:
  /// **'All clear for today'**
  String get allClearToday;

  /// No description provided for @activeTodoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task remaining} other{{count} tasks remaining}}'**
  String activeTodoCount(int count);

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @collapseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Collapse (Esc)'**
  String get collapseTooltip;

  /// No description provided for @activeScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Todos'**
  String get activeScopeLabel;

  /// No description provided for @archiveScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveScopeLabel;

  /// No description provided for @addTodoSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'Add todo'**
  String get addTodoSemanticsLabel;

  /// No description provided for @addTodoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add todo (Return)'**
  String get addTodoTooltip;

  /// No description provided for @dismissErrorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Dismiss error'**
  String get dismissErrorTooltip;

  /// No description provided for @completedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedStatus;

  /// No description provided for @incompleteStatus.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get incompleteStatus;

  /// No description provided for @markIncompleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark incomplete'**
  String get markIncompleteTooltip;

  /// No description provided for @markCompleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mark complete'**
  String get markCompleteTooltip;

  /// No description provided for @todoTitleRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Todo title cannot be empty'**
  String get todoTitleRequiredHint;

  /// No description provided for @saveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveTooltip;

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// No description provided for @cancelEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel editing'**
  String get cancelEditTooltip;

  /// No description provided for @restoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore to todos'**
  String get restoreTooltip;

  /// No description provided for @archiveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archiveTooltip;

  /// No description provided for @noSearchResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get noSearchResultsTitle;

  /// No description provided for @emptyArchiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive is empty'**
  String get emptyArchiveTitle;

  /// No description provided for @emptyTodosTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to do—enjoy the moment'**
  String get emptyTodosTitle;

  /// No description provided for @noSearchResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword'**
  String get noSearchResultsMessage;

  /// No description provided for @emptyArchiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Archived items will appear here'**
  String get emptyArchiveMessage;

  /// No description provided for @emptyTodosMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a new item above whenever you like'**
  String get emptyTodosMessage;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;

  /// No description provided for @storageInvalidDataError.
  ///
  /// In en, this message translates to:
  /// **'The local data file is damaged and was left unchanged.'**
  String get storageInvalidDataError;

  /// No description provided for @storageReadError.
  ///
  /// In en, this message translates to:
  /// **'Floatick couldn\'t read {path}.'**
  String storageReadError(String path);

  /// No description provided for @storageWriteError.
  ///
  /// In en, this message translates to:
  /// **'Floatick couldn\'t save to {path}.'**
  String storageWriteError(String path);

  /// No description provided for @storageHomeError.
  ///
  /// In en, this message translates to:
  /// **'Floatick couldn\'t resolve your macOS home directory.'**
  String get storageHomeError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
