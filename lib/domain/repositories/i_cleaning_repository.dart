abstract class ICleaningRepository {
  /// Attempts to clear the cache for a given list of package names.
  /// Returns a boolean indicating success of the operation trigger.
  Future<bool> clearCache(List<String> packageNames);
  
  /// Checks if the accessibility service is enabled.
  Future<bool> isAccessibilityServiceEnabled();
  
  /// Prompts the user to enable the accessibility service.
  Future<void> requestAccessibilityService();

  /// Triggers the actual automation process using the accessibility service.
  Future<bool> triggerAccessibilityCleaning(List<String> packageNames);
}
