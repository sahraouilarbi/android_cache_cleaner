# GEMINI.md - Instructional Context for CacheFlow (Android Cache Cleaner)

## 1. Project Overview
**CacheFlow** is a Flutter-based Android utility application designed to analyze storage usage and automate the clearing of third-party application caches. It supports both Non-Root (via Accessibility Services) and Root (via shell commands) modes.

- **Primary Framework:** Flutter 3.x
- **Target Platform:** Android
- **Language:** Dart (Flutter), Kotlin (Native Bridge)
- **Architecture:** Clean Architecture (Data, Domain, Presentation)
- **State Management:** BLoC (Business Logic Component)
- **Design System:** Material 3

## 2. Technical Architecture & Conventions

### 2.1. Clean Architecture Structure
Adhere strictly to the following directory structure:
- `lib/core/`: Utilities, constants, themes, and shared components.
- `lib/data/`: Implementations of data sources (Native/Local), DTOs (Models), and Repository implementations.
- `lib/domain/`: Pure business logic, Entities, and Repository interfaces.
- `lib/presentation/`: UI screens (Pages), Widgets, and BLoC files.

### 2.2. Development Mandates
- **Type Safety:** Use strong typing in Dart; avoid `dynamic`.
- **State Management:** Use `flutter_bloc` for all state-related logic.
- **Dependency Injection:** Use `get_it` and `injectable`.
- **Native Interop:** Use `MethodChannel` for interacting with Android APIs (`StorageStatsManager`, `AccessibilityService`). Document every `MethodChannel` with potential exceptions (e.g., `Permission denied`).
- **Performance:** Offload heavy tasks (like scanning >100 apps) to a background `Isolate`.
- **Security:** Do not bypass user permissions without clear technical justification and explanation.

## 3. Key Features & Specifications

- **F1. Storage Analysis:** List apps, retrieve cache/data/APK sizes, and sort by cache size.
- **F2. Non-Root Mode:** Implement a custom `AccessibilityService` to automate navigating system settings and clicking "Clear Cache".
- **F3. Root Mode (Optional):** Use `su` commands to clear `/cache` and `/data/user/0/*/cache`.
- **F4. UI/UX:** Material 3 Dashboard with graphical usage stats and a "Quick Clean" Action Floating Button.

## 4. Required Android Permissions
- `PACKAGE_USAGE_STATS`: For storage statistics.
- `QUERY_ALL_PACKAGES`: For listing installed apps (Android 11+).
- `BIND_ACCESSIBILITY_SERVICE`: For automation logic.

## 5. Building and Running (Standard Flutter)
- **Initialization:** `flutter create .` (if not already initialized)
- **Dependencies:** `flutter pub get`
- **Run App:** `flutter run`
- **Build Runner:** `dart run build_runner build --delete-conflicting-outputs` (for Isar/Injectable)

## 6. Documentation References
- Product Requirements Document: `ressources/prd-android-cache-cleaner.md`
