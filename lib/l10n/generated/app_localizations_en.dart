// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CacheFlow';

  @override
  String get refresh => 'Refresh';

  @override
  String get info => 'Info';

  @override
  String get cacheCleaningCompleted => 'Cache cleaning completed!';

  @override
  String get accessibilityRequired =>
      'Please enable Accessibility Service to automate cleaning.';

  @override
  String errorMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get noAppsFound => 'No apps found.';

  @override
  String get totalCacheSize => 'Total Cache Size';

  @override
  String get topOffenders => 'Top Offenders';

  @override
  String get allApplications => 'All Applications';

  @override
  String appSize(String size) {
    return 'App Size: $size';
  }

  @override
  String get cleanAllCache => 'Clean All Cache';

  @override
  String get about => 'About';

  @override
  String get developer => 'Developer';

  @override
  String get openSource => 'Open Source';

  @override
  String get sourceCodeGithub => 'Source code on GitHub';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get appDescription =>
      'CacheFlow is an open-source utility designed to optimize your storage space by intelligently cleaning cache files from your applications.';

  @override
  String get officialSite => 'Official Site';

  @override
  String get supportContact => 'Support & Contact';

  @override
  String get contributeToProject => 'Contribute to the project';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get copyright =>
      '© 2026 Larbi Sahraoui. Distributed under GPL v3 license.';

  @override
  String get madeWithLove => 'Made with ❤️ by Larbi Sahraoui';
}
