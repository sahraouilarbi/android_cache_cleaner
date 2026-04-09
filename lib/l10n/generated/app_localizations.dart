import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'CacheFlow'**
  String get appTitle;

  /// Tooltip for the refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Tooltip for the info button
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// Message shown when cache cleaning is finished
  ///
  /// In en, this message translates to:
  /// **'Cache cleaning completed!'**
  String get cacheCleaningCompleted;

  /// Message shown when accessibility permission is needed
  ///
  /// In en, this message translates to:
  /// **'Please enable Accessibility Service to automate cleaning.'**
  String get accessibilityRequired;

  /// Generic error message with a placeholder
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorMessage(String message);

  /// Message shown when no apps are detected
  ///
  /// In en, this message translates to:
  /// **'No apps found.'**
  String get noAppsFound;

  /// Label for the total cache size section
  ///
  /// In en, this message translates to:
  /// **'Total Cache Size'**
  String get totalCacheSize;

  /// Title for the top offenders section
  ///
  /// In en, this message translates to:
  /// **'Top Offenders'**
  String get topOffenders;

  /// Title for the all applications list
  ///
  /// In en, this message translates to:
  /// **'All Applications'**
  String get allApplications;

  /// Label showing the size of an app
  ///
  /// In en, this message translates to:
  /// **'App Size: {size}'**
  String appSize(String size);

  /// Label for the floating action button to clean all cache
  ///
  /// In en, this message translates to:
  /// **'Clean All Cache'**
  String get cleanAllCache;

  /// Title for the about page
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Title for the developer section in about page
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Title for the open source section in about page
  ///
  /// In en, this message translates to:
  /// **'Open Source'**
  String get openSource;

  /// Label for the GitHub link
  ///
  /// In en, this message translates to:
  /// **'Source code on GitHub'**
  String get sourceCodeGithub;

  /// Label for the privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Label showing the app version
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// Short description of the app
  ///
  /// In en, this message translates to:
  /// **'CacheFlow is an open-source utility designed to optimize your storage space by intelligently cleaning cache files from your applications.'**
  String get appDescription;

  /// Label for the official website link
  ///
  /// In en, this message translates to:
  /// **'Official Site'**
  String get officialSite;

  /// Label for the support/contact link
  ///
  /// In en, this message translates to:
  /// **'Support & Contact'**
  String get supportContact;

  /// Label for the GitHub contribution link
  ///
  /// In en, this message translates to:
  /// **'Contribute to the project'**
  String get contributeToProject;

  /// Label for the open source licenses page link
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// Copyright notice
  ///
  /// In en, this message translates to:
  /// **'© 2026 Larbi Sahraoui. Distributed under GPL v3 license.'**
  String get copyright;

  /// Footer text
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ by Larbi Sahraoui'**
  String get madeWithLove;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
