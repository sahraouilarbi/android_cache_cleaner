# Design Spec: CacheFlow (Android Cache Cleaner)

## 1. Overview
CacheFlow is an Android utility application built with Flutter that analyzes storage and automates clearing the cache of third-party applications. It uses Kotlin Native MethodChannels for system integrations.

## 2. Architecture & Tech Stack
* **Framework:** Flutter 3.x
* **Pattern:** Clean Architecture (Data, Domain, Presentation)
* **State Management:** `flutter_bloc`
* **Dependency Injection:** `get_it` and `injectable`
* **Design System:** Material 3 (with custom themes, dark mode support)

## 3. Data Flow & Core Logic

### 3.1. Scanning Phase
1. **Trigger:** User opens the app or pulls to refresh.
2. **Native Call:** Dart invokes a `MethodChannel` (`CacheFlowChannel`) requesting app storage statistics.
3. **Kotlin Implementation:** Uses `StorageStatsManager` and `PackageManager` to fetch the installed apps and their respective `cacheSize`, `dataSize`, and `apkSize`.
4. **Isolate Processing:** The raw JSON/Map list returned to Dart is processed inside an `Isolate` (using Flutter's `compute`) to instantiate domain models and sort them by cache size descending, preventing UI thread blockage.

### 3.2. Cleaning Engine (Auto-Detect Strategy)
When the user taps "Clean Cache":
1. **Root Detection:** The app attempts to run a silent `su` command (`su -c 'echo test'`).
2. **Root Mode (Fast Path):** If root is granted, the app executes shell commands to clear `/cache` and `/data/user/0/*/cache` directly.
3. **Accessibility Mode (Fallback):** If root is denied or unavailable, the app checks if its custom `AccessibilityService` is enabled.
   * If not enabled, it prompts the user to enable it in Android Settings.
   * If enabled, it triggers the automation loop: Dart passes the list of target package names to Kotlin. Kotlin loops through them, firing Intents to open `Settings.ACTION_APPLICATION_DETAILS_SETTINGS`.
   * **Automation Logic:** The `AccessibilityService` listens for `TYPE_WINDOW_STATE_CHANGED`. It identifies the "Storage & cache" (or "Storage" on older Android versions) button by ID or localized text, clicks it, then waits for the "Clear cache" button to become enabled and clicks it.
   * **Stop Condition:** The service detects the change in cache size text to "0 B" or "Cached: 0 B" and proceeds to the next package in the queue.

### 3.3. Error Handling & Edge Cases
* **Permission Revoked:** If `PACKAGE_USAGE_STATS` is revoked mid-session, the app must gracefully transition back to the "Request Permission" screen.
* **Service Interruption:** If the user manually closes the Settings app during Accessibility automation, the app should detect the focus change and pause/cancel the queue with a notification.
* **UI Variability:** Handle variations in Samsung, Pixel, and MIUI Settings UI layouts by using a fallback strategy (searching by text labels if resource IDs are not found).

## 4. UI / UX Design
* **Dashboard (Material 3):**
  * **Top Section:** An analytical breakdown of total storage (System vs. Data vs. Cache) using a horizontal stacked bar chart.
  * **Highlights:** A dedicated row highlighting the "Top Offenders" (the apps consuming the most cache).
  * **Action:** A prominent primary button to initiate the cleaning process.
  * **List:** A scrollable list of all scanned apps below the highlights.
* **Statistics View:**
  * Displays a historical line chart of "Space Recovered" over time (Daily/Weekly/Monthly).
  * Lists total cumulative cache cleared since installation.

## 5. Security & Privacy
* **Data Localism:** All scanned app names and storage data remain on the device. No data is sent to external servers.
* **Root Safety:** Shell commands are strictly limited to cache directories. No system-level modifications or deletions are performed outside of those paths.
* **Accessibility Privacy:** The `AccessibilityService` is scoped to only interact with the `com.android.settings` package to prevent accidental interaction with sensitive user data in other apps.

## 6. Required Permissions
* `android.permission.PACKAGE_USAGE_STATS` (Requires explicit user grant via Settings)
* `android.permission.QUERY_ALL_PACKAGES` (For listing installed apps on Android 11+)
* `android.permission.BIND_ACCESSIBILITY_SERVICE` (defined in service manifest)

## 7. Testing Strategy
* **Unit Tests:** Mock `MethodChannel` responses to test the Isolate parsing logic and BLoC state transitions.
* **Widget Tests:** Verify the analytical dashboard renders correctly based on mock storage data.