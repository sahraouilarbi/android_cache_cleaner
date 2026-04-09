import 'package:flutter_test/flutter_test.dart';

// Logic simulation of what we implemented in Kotlin
bool simulateAccessibilityFilter(String? packageName, List<String> allowedPackages) {
  if (packageName == null) return false;
  return allowedPackages.contains(packageName);
}

void main() {
  group('Accessibility Security Filter Logic', () {
    final allowedPackages = ['com.android.settings', 'com.google.android.settings'];

    test('should allow system settings events', () {
      expect(simulateAccessibilityFilter('com.android.settings', allowedPackages), isTrue);
      expect(simulateAccessibilityFilter('com.google.android.settings', allowedPackages), isTrue);
    });

    test('should REJECT events from other apps (Spyware prevention)', () {
      expect(simulateAccessibilityFilter('com.whatsapp', allowedPackages), isFalse);
      expect(simulateAccessibilityFilter('com.android.vending', allowedPackages), isFalse);
      expect(simulateAccessibilityFilter('com.sahraouilarbi.android_cache_cleaner', allowedPackages), isFalse);
      expect(simulateAccessibilityFilter(null, allowedPackages), isFalse);
    });
  });
}
