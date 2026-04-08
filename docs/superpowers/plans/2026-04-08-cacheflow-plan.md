# Implementation Plan: CacheFlow

## Phase 1: Project Setup & Infrastructure
1. Initialize Flutter project (if not done).
2. Add necessary dependencies to `pubspec.yaml` (flutter_bloc, get_it, injectable, build_runner, injectable_generator).
3. Create the Clean Architecture folder structure (`lib/core`, `lib/data`, `lib/domain`, `lib/presentation`).
4. Set up Dependency Injection (`get_it` + `injectable`).
5. Configure Material 3 Theme.

## Phase 2: Domain Layer
1. Create Entities: `AppStorageStats`.
2. Create Repository Interfaces: `IStorageRepository`, `ICleaningRepository`.
3. Create Use Cases: `GetAppStatsUseCase`, `CleanCacheUseCase`.

## Phase 3: Data Layer & Native Bridge (Dart)
1. Create `MethodChannel` definitions for `CacheFlowChannel`.
2. Implement `StorageRepository` and `CleaningRepository` calling the Native Bridge.

## Phase 4: Native Android Implementation (Kotlin)
1. Implement `StorageStatsManager` logic in `MainActivity.kt` to retrieve app storage data.
2. Implement Root command execution (`su`) for clearing cache.
3. Create the `CacheAccessibilityService.kt` for non-root automation.
4. Update `AndroidManifest.xml` with required permissions and service declarations.

## Phase 5: Presentation Layer (UI & State)
1. Create BLoCs: `StorageBloc` (scanning), `CleaningBloc` (execution).
2. Build UI: Dashboard with storage chart and "Top Offenders" list.
3. Build UI: Complete App List.
4. Integrate animations (Lottie or implicit animations).

## Phase 6: Validation & Polish
1. Test Scanning logic (with >100 apps to ensure Isolate works).
2. Test Root mode cleaning.
3. Test Accessibility mode automation.
4. Finalize UI spacing, typography, and dark mode.