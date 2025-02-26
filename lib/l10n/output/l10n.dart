// GENERATED CODE - DO NOT MODIFY BY HAND

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'output/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
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
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// App title
  ///
  /// In en, this message translates to:
  /// **'ATerminal'**
  String get appTitle;

  /// Exit tip
  ///
  /// In en, this message translates to:
  /// **'Press once more to exit.'**
  String get exitTip;

  /// Add new terminal
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get addNew;

  ///
  ///
  /// In en, this message translates to:
  /// **'{action, select, create{Create } edit{Edit } other{}}{type}{lower, plural, other{T} =1{ t}}erminal'**
  String terminal(String action, String type, int lower);

  /// Terminal name
  ///
  /// In en, this message translates to:
  /// **'Terminal name'**
  String get terminalName;

  /// Terminal shell
  ///
  /// In en, this message translates to:
  /// **'Terminal shell'**
  String get terminalShell;

  /// Terminal host
  ///
  /// In en, this message translates to:
  /// **'Terminal host'**
  String get terminalHost;

  /// Terminal port
  ///
  /// In en, this message translates to:
  /// **'Terminal port'**
  String get terminalPort;

  /// Terminal username
  ///
  /// In en, this message translates to:
  /// **'Terminal username'**
  String get terminalUser;

  /// Terminal password
  ///
  /// In en, this message translates to:
  /// **'Terminal password'**
  String get terminalPass;

  /// Local
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// Remote
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// Required
  ///
  /// In en, this message translates to:
  /// **'{name} is required.'**
  String isRequired(String name);

  /// Selected item count
  ///
  /// In en, this message translates to:
  /// **'Selected {count, plural, =0{no item} =1{1 item} other{{count} items}}'**
  String inSelecting(int count);

  /// Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No terminal
  ///
  /// In en, this message translates to:
  /// **'No terminal'**
  String get emptyTerminal;

  /// SFTP
  ///
  /// In en, this message translates to:
  /// **'SFTP'**
  String get sftp;

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// General group
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// System default theme
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Color setting
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// Use system accent color
  ///
  /// In en, this message translates to:
  /// **'Dynamic color'**
  String get systemColor;

  /// Select color tip
  ///
  /// In en, this message translates to:
  /// **'Select color'**
  String get switchColor;

  /// Max lines setting
  ///
  /// In en, this message translates to:
  /// **'Max lines'**
  String get maxLines;

  /// Unknown page title
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Go back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
  }

  throw FlutterError(
      'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
