# PRD : App "CacheFlow" (Android Cache Cleaner)

## 1. Vision du Projet
**Objectif :** Développer une application utilitaire Android permettant d'analyser l'espace occupé par le cache des applications tierces et d'automatiser leur nettoyage via les services d'accessibilité (non-root) ou via des commandes shell (root).

---

## 2. Architecture Technique
Pour garantir la maintenabilité et l'évolutivité, le projet suivra les standards suivants :
* **Framework :** Flutter 3.x
* **Architecture :** Clean Architecture (Data, Domain, Presentation).
* **State Management :** BLoC (Business Logic Component).
* **Local Storage :** Isar Database ou Hive (pour le tracking des statistiques de nettoyage).
* **Native Bridge :** MethodChannels pour interagir avec les API Android (`StorageStatsManager`, `AccessibilityService`).

---

## 3. Spécifications Fonctionnelles

### F1. Analyse du Stockage
* Lister toutes les applications installées par l'utilisateur.
* Récupérer la taille du cache, des données et de l'APK pour chaque application.
* Trier les applications par "Taille du cache" décroissante.

### F2. Mode Non-Root (Accessibilité)
* Implémenter un `AccessibilityService` personnalisé.
* Scénario d'automatisation : 
    1. Ouvrir `Settings.ACTION_APPLICATION_DETAILS_SETTINGS`.
    2. Cliquer sur "Espace de stockage et cache".
    3. Cliquer sur "Vider le cache".
    4. Retourner sur l'application.

### F3. Mode Root (Optionnel)
* Vérifier le statut Root au démarrage.
* Exécuter des commandes `su` pour vider les répertoires `/cache` et `/data/user/0/*/cache` de manière globale.

### F4. Interface Utilisateur (UI)
* **Dashboard :** Visualisation graphique de l'espace total vs espace occupé (Style Material 3).
* **App List :** Liste filtrable avec indicateurs visuels pour les applications dépassant un certain seuil.
* **Action Floating Button :** Bouton unique "Nettoyage Rapide".

---

## 4. Structure des Dossiers (Clean Architecture)

```text
lib/
├── core/              # Utilitaires, constantes, thèmes
├── data/              # Implémentations des sources de données (Native/Local)
│   ├── datasources/   # MethodChannel calls, Local DB
│   ├── models/        # DTOs (Data Transfer Objects)
│   └── repositories/  # Implémentation des contrats
├── domain/            # Logique métier pure
│   ├── entities/      # Objets métier (AppInfo, StorageStats)
│   ├── repositories/  # Interfaces des contrats
│   └── usecases/      # GetAppsList, ClearCache, RequestPermissions
├── presentation/      # UI et Logique d'état
│   ├── bloc/          # Fichiers BLoC (Events, States)
│   ├── pages/         # Écrans principaux
│   └── widgets/       # Composants réutilisables
└── main.dart
```

---

## 5. Exigences de Permissions (Manifest)
* `PACKAGE_USAGE_STATS` (Requis pour `StorageStatsManager`).
* `QUERY_ALL_PACKAGES` (Requis sur Android 11+ pour lister les apps).
* `BIND_ACCESSIBILITY_SERVICE` (Pour l'automatisation).

---

## 6. Feuille de Route (Milestones)

### Phase 1 : Infrastructure (Core)
* Configuration du boilerplate Clean Architecture.
* Mise en place de `flutter_bloc` et `get_it` pour l'injection de dépendances.
* Définition du `MethodChannel` côté Kotlin.

### Phase 2 : Scan & Native Bridge
* Implémentation Kotlin pour récupérer les statistiques de stockage via `StorageStatsManager`.
* Mapping des données vers les entités Dart.
* Affichage de la liste triée.

### Phase 3 : Moteur de Nettoyage
* Développement du `AccessibilityService` en Kotlin.
* Gestion des permissions système (demander l'accès aux stats et à l'accessibilité).
* Logique de boucle pour traiter plusieurs applications à la suite.

### Phase 4 : UI/UX & Polissage
* Design Material 3 avec support du Dark Mode.
* Ajout d'animations (Lottie) pendant le scan et le nettoyage.

---

## 7. Directives pour gemini-cli
Lors de l'utilisation de ce PRD, respecte les consignes suivantes :
1.  **Code de qualité :** Utilise toujours le typage fort de Dart et évite les `dynamic`.
2.  **Sécurité :** Ne propose pas de méthodes qui contournent les autorisations utilisateur sans explication.
3.  **Performance :** Utilise des `Isolate` pour le scan des applications si la liste dépasse 100 éléments pour éviter les lags de l'UI.
4.  **Commentaires :** Documente chaque `MethodChannel` avec les exceptions possibles (ex: `Permission denied`).