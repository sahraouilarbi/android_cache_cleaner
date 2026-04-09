// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'CacheFlow';

  @override
  String get refresh => 'Actualiser';

  @override
  String get info => 'Infos';

  @override
  String get cacheCleaningCompleted => 'Nettoyage du cache terminé !';

  @override
  String get accessibilityRequired =>
      'Veuillez activer le service d\'accessibilité pour automatiser le nettoyage.';

  @override
  String errorMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get noAppsFound => 'Aucune application trouvée.';

  @override
  String get totalCacheSize => 'Taille totale du cache';

  @override
  String get topOffenders => 'Plus gros consommateurs';

  @override
  String get allApplications => 'Toutes les applications';

  @override
  String appSize(String size) {
    return 'Taille de l\'app : $size';
  }

  @override
  String get cleanAllCache => 'Nettoyer tout le cache';

  @override
  String get about => 'À propos';

  @override
  String get developer => 'Développeur';

  @override
  String get openSource => 'Open Source';

  @override
  String get sourceCodeGithub => 'Code source sur GitHub';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get appDescription =>
      'CacheFlow est un utilitaire open-source conçu pour optimiser votre espace de stockage en nettoyant intelligemment les fichiers cache de vos applications.';

  @override
  String get officialSite => 'Site officiel';

  @override
  String get supportContact => 'Support & Contact';

  @override
  String get contributeToProject => 'Contribuez au projet';

  @override
  String get openSourceLicenses => 'Licences Open Source';

  @override
  String get copyright =>
      '© 2026 Larbi Sahraoui. Distribué sous licence GPL v3.';

  @override
  String get madeWithLove => 'Fait avec ❤️ par Larbi Sahraoui';
}
