# CacheFlow (Android Cache Cleaner)

<div align="center">
  <img src="assets/images/cacheflow.png" alt="CacheFlow App Icon" width="150" style="border-radius: 20%;" />
  <br><br>
  
  [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
  [![Security Policy](https://img.shields.io/badge/Security-Policy-brightgreen.svg)](SECURITY.md)
  [![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)](https://flutter.dev)
  [![Android](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)](https://www.android.com)
  [![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.svg?v=103)](https://github.com/ellerbrock/open-source-badges/)
</div>

CacheFlow est une application utilitaire Android moderne et **Open-Source** développée avec Flutter. Elle est conçue pour analyser intelligemment l'utilisation du stockage et automatiser le nettoyage des caches des applications tierces, offrant une expérience fluide, sécurisée et transparente.

> *Note : L'identifiant de package officiel est `com.sahraouilarbi.android_cache_cleaner`.*

## 🚀 Vision du Projet

L'objectif de CacheFlow est de redonner le contrôle aux utilisateurs sur leur stockage Android via une solution éthique, sans trackers et performante :
- **Mode Non-Root :** Automatisation du nettoyage via les **Services d'Accessibilité** (simule les clics utilisateur).
- **Mode Root :** Nettoyage direct et instantané via des commandes shell `su`.

## 🛡️ Sécurité & Éthique (Audit Complété)

L'application a subi un audit de sécurité rigoureux pour garantir un usage sain et empêcher tout détournement malveillant :
- **Protection Anti-Injection** : Validation par Regex stricte de tous les noms de packages avant exécution shell.
- **Isolation du Service d'Accessibilité** : Le service est restreint exclusivement aux paramètres système (`com.android.settings`).
- **Transparence Totale** : Une notification de service au premier plan est obligatoire pendant tout le processus de nettoyage.
- **Anti-Spyware** : Aucune donnée d'événement d'accessibilité n'est logguée ou transmise.

## ⚠️ Usage Policy

CacheFlow is designed exclusively for legitimate cache management on Android devices with the user's full consent and knowledge. Any fork, modification, or redistribution of this code for the purpose of surveillance, data exfiltration, unauthorized device control, or any malicious use is **strictly prohibited** and constitutes a violation of the GPL-v3 terms.

The authors reserve the right to pursue legal action against misuse.

## ✨ Fonctionnalités Clés

- **🔍 Analyse du Stockage :** Liste complète des applications avec détails (Cache, Données, APK) via `StorageStatsManager`.
- **🤖 Automatisation :** Nettoyage intelligent sans répétition manuelle pour les utilisateurs non-root.
- **⚡ Performance :** Support du mode Root pour un nettoyage en un clic.
- **🎨 Design Material 3 :** Interface moderne, support natif des thèmes **Clair et Sombre**.
- **🌍 Multilingue :** Support complet du **Français**, **Anglais** et **Arabe** (incluant le support RTL).

## 📖 Guide d'Utilisation

### 1. Autoriser l'accès aux statistiques
Au premier lancement, l'application vous demandera l'autorisation **"Accès aux données d'utilisation"**. Elle est indispensable pour calculer la taille réelle du cache de chaque application.
- Cliquez sur "Autoriser" dans la boîte de dialogue.
- Cherchez **CacheFlow** dans la liste des paramètres Android qui s'affiche.
- Activez l'option **"Autoriser l'accès aux données d'utilisation"**.

### 2. Activer le Service d'Accessibilité (Mode Non-Root)
Pour automatiser le nettoyage sans accès Root, CacheFlow a besoin de simuler des clics dans les menus système.
- Cliquez sur le bouton **"Nettoyer tout le cache"** sur le tableau de bord.
- Si le service n'est pas actif, vous serez redirigé vers les paramètres d'**Accessibilité**.
- Allez dans **"Applications installées"** (ou "Services téléchargés").
- Sélectionnez **CacheFlow** et activez l'interrupteur.

### 3. Lancer le nettoyage
Une fois les permissions accordées :
- Cliquez sur le bouton flottant **"Nettoyer tout le cache"**.
- Laissez votre téléphone travailler quelques secondes. Il reviendra sur CacheFlow une fois terminé.

## 🛠 Architecture & Stack Technique

Le projet suit rigoureusement la **Clean Architecture** :
- **Framework :** Flutter 3.x (Dart)
- **State Management :** BLoC
- **DI :** GetIt & Injectable
- **Localisation :** Fichiers ARB avec `flutter_localizations`.
- **Bridge :** Kotlin MethodChannels pour les API système (`StorageStatsManager`, `AccessibilityService`).

## 🧪 Tests & Qualité

Le projet inclut une suite de tests complète (14+ tests) couvrant :
- **Tests Unitaires & BLoC** : Logique métier et gestion d'état.
- **Tests de Widgets** : Intégrité de l'interface utilisateur.
- **Security Audit Tests** : Vérification de la protection contre les injections et les accès non autorisés.

```bash
flutter test
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Que ce soit pour signaler un bug, proposer une fonctionnalité ou améliorer le code, veuillez consulter notre [SECURITY.md](SECURITY.md) pour les directives de sécurité.

## 📄 Licence

Distribué sous la licence **GNU GPL v3**. Voir le fichier `LICENSE` pour plus d'informations.

---
*Fait avec ❤️ par Larbi Sahraoui. CacheFlow est un logiciel libre.*
